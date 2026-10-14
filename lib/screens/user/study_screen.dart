import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../data/models/card.dart' as m;
import '../../data/models/deck.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/deck_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../providers/auth_provider.dart';
import 'result_screen.dart';

class StudyScreen extends StatefulWidget {
  final String deckId;
  const StudyScreen({required this.deckId, super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _cardRepo = CardRepository();
  final _deckRepo = DeckRepository();
  final _progressRepo = ProgressRepository();

  bool _loading = true;
  Deck? _deck;
  List<m.FlashCard> _cards = [];
  int _index = 0;
  bool _showBack = false;
  int _known = 0;
  int _unknown = 0;
  final List<String> _missed = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final deck = await _deckRepo.getById(widget.deckId);
    final cards = await _cardRepo.getByDeck(widget.deckId);
    if (!mounted) return;
    setState(() {
      _deck = deck;
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _mark(bool known) async {
    if (_cards.isEmpty) return;
    final user = context.read<AuthProvider>().currentUser;
    final card = _cards[_index];
    if (user != null) {
      await _progressRepo.setStatus(
        userId: user.id,
        cardId: card.id,
        status: known ? AppConstants.statusKnown : AppConstants.statusUnknown,
      );
    }
    if (known) {
      _known++;
    } else {
      _unknown++;
      _missed.add(card.id);
    }
    if (_index < _cards.length - 1) {
      setState(() {
        _index++;
        _showBack = false;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          deckId: widget.deckId,
          deckTitle: _deck?.title ?? 'Deck',
          total: _cards.length,
          known: _known,
          unknown: _unknown,
          missedCardIds: List.of(_missed),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(_deck?.title ?? 'Study')),
        body: const Center(child: Text('No cards in this deck yet.')),
      );
    }
    final card = _cards[_index];
    final progress = (_index + 1) / _cards.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(_deck?.title ?? 'Study'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(child: Text('${_index + 1}/${_cards.length}')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 24),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _showBack ? card.back : card.front,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(_showBack ? 'Answer (tap to flip back)' : 'Question (tap to reveal)',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _mark(false),
                    child: const Text('Need review'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _mark(true),
                    child: const Text('I knew it'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
