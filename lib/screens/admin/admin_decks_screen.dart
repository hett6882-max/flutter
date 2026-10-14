import 'package:flutter/material.dart';

import '../../data/models/deck.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/deck_repository.dart';
import 'admin_cards_screen.dart';
import 'admin_deck_form_screen.dart';

class AdminDecksScreen extends StatefulWidget {
  const AdminDecksScreen({super.key});

  @override
  State<AdminDecksScreen> createState() => _AdminDecksScreenState();
}

class _AdminDecksScreenState extends State<AdminDecksScreen> {
  final _deckRepo = DeckRepository();
  final _cardRepo = CardRepository();
  bool _loading = true;
  List<Deck> _decks = [];
  Map<String, int> _cardCounts = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final decks = await _deckRepo.getAll();
    final counts = <String, int>{};
    for (final d in decks) {
      counts[d.id] = await _cardRepo.countByDeck(d.id);
    }
    if (!mounted) return;
    setState(() {
      _decks = decks;
      _cardCounts = counts;
      _loading = false;
    });
  }

  Future<void> _delete(Deck deck) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete deck?'),
        content: Text('Delete "${deck.title}" and all its cards?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await _deckRepo.delete(deck.id);
      _load();
    }
  }

  Future<void> _openForm({Deck? deck}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminDeckFormScreen(deck: deck)),
    );
    if (changed == true) _load();
  }

  Future<void> _openCards(Deck deck) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminCardsScreen(deck: deck)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Decks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (_, i) {
                  final d = _decks[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(d.title),
                      subtitle: Text('${d.category} • ${_cardCounts[d.id] ?? 0} cards'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.credit_card),
                              tooltip: 'Cards',
                              onPressed: () => _openCards(d)),
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _openForm(deck: d)),
                          IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(d)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
