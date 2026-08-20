import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import '../services/srs_service.dart';
import '../widgets/app_scope.dart';

class StudyScreen extends StatefulWidget {
  final List<Flashcard> cards;
  final int startIndex;
  final String title;
  final bool useSrs;

  const StudyScreen({
    super.key,
    required this.cards,
    this.startIndex = 0,
    this.title = 'Study',
    this.useSrs = true,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  late List<Flashcard> _cards;
  late int _index;
  bool _showAnswer = false;
  int _reviewed = 0;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _cards = List.of(widget.cards);
    _index = widget.startIndex.clamp(0, _cards.isEmpty ? 0 : _cards.length - 1);
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    setState(() => _showAnswer = !_showAnswer);
    _flipController.forward(from: 0);
  }

  Future<void> _rate(ReviewQuality quality) async {
    if (_cards.isEmpty) return;
    final state = AppScope.of(context);
    final id = _cards[_index].id;
    if (widget.useSrs) {
      await state.applyReview(id, quality);
      // refresh local card from state
      final updated = state.cards.firstWhere((c) => c.id == id);
      _cards[_index] = updated;
    } else if (quality == ReviewQuality.again) {
      // in cram mode, just track wrong/correct lightly
      await state.applyReview(id, quality);
    } else {
      await state.applyReview(id, quality);
    }
    _reviewed++;
    _goNext();
  }

  void _goNext() {
    if (_index >= _cards.length - 1) {
      _showDone();
      return;
    }
    setState(() {
      _index++;
      _showAnswer = false;
    });
  }

  void _goPrev() {
    if (_index <= 0) return;
    setState(() {
      _index--;
      _showAnswer = false;
    });
  }

  void _showDone() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Session complete'),
        content: Text('You reviewed $_reviewed card(s). Great work!'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('No cards to study')),
      );
    }

    final card = _cards[_index];
    final scheme = Theme.of(context).colorScheme;
    final progress = (_index + 1) / _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title} · ${_index + 1}/${_cards.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _showAnswer
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _showAnswer ? 'ANSWER' : 'QUESTION',
                        style: TextStyle(
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        _showAnswer ? card.answer : card.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (card.tags.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          children: card.tags
                              .map((t) => Chip(label: Text(t)))
                              .toList(),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to flip · Leitner box ${card.box}',
                        style: TextStyle(color: scheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_showAnswer) ...[
              Text(
                widget.useSrs
                    ? 'How well did you remember?'
                    : 'Rate this card',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _RateBtn(
                    label: 'Again',
                    color: Colors.red.shade400,
                    onTap: () => _rate(ReviewQuality.again),
                  ),
                  _RateBtn(
                    label: 'Hard',
                    color: Colors.orange.shade400,
                    onTap: () => _rate(ReviewQuality.hard),
                  ),
                  _RateBtn(
                    label: 'Good',
                    color: Colors.green.shade500,
                    onTap: () => _rate(ReviewQuality.good),
                  ),
                  _RateBtn(
                    label: 'Easy',
                    color: Colors.blue.shade500,
                    onTap: () => _rate(ReviewQuality.easy),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _index > 0 ? _goPrev : null,
                      child: const Text('Previous'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _flip,
                      child: const Text('Show answer'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RateBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RateBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(backgroundColor: color),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
