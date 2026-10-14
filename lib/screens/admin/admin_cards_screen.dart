import 'package:flutter/material.dart';

import '../../data/models/card.dart' as m;
import '../../data/models/deck.dart';
import '../../data/repositories/card_repository.dart';
import 'admin_card_form_screen.dart';

class AdminCardsScreen extends StatefulWidget {
  final Deck deck;
  const AdminCardsScreen({required this.deck, super.key});

  @override
  State<AdminCardsScreen> createState() => _AdminCardsScreenState();
}

class _AdminCardsScreenState extends State<AdminCardsScreen> {
  final _repo = CardRepository();
  bool _loading = true;
  List<m.FlashCard> _cards = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cards = await _repo.getByDeck(widget.deck.id);
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
    });
  }

  Future<void> _delete(m.FlashCard card) async {
    await _repo.delete(card.id);
    _load();
  }

  Future<void> _openForm({m.FlashCard? card}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminCardFormScreen(deckId: widget.deck.id, card: card)),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cards: ${widget.deck.title}')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                itemCount: _cards.length,
                itemBuilder: (_, i) {
                  final c = _cards[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(c.front),
                      subtitle: Text(c.back),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _openForm(card: c)),
                          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(c)),
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
