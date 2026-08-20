import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../widgets/app_scope.dart';
import 'add_card_screen.dart';
import 'edit_deck_screen.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class DeckDetailScreen extends StatelessWidget {
  final String deckId;

  const DeckDetailScreen({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    Deck? deck;
    for (final d in state.decks) {
      if (d.id == deckId) deck = d;
    }
    if (deck == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Deck not found')),
      );
    }

    final cards = state.cardsForDeck(deckId);
    final due = cards.where((c) => c.isDue).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'edit') {
                final updated = await Navigator.push<Deck>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditDeckScreen(existing: deck),
                  ),
                );
                if (updated != null) await state.updateDeck(updated);
              } else if (v == 'delete') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete deck?'),
                    content: const Text(
                      'All cards in this deck will be removed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (ok == true && context.mounted) {
                  await state.deleteDeck(deckId);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit deck')),
              PopupMenuItem(value: 'delete', child: Text('Delete deck')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deck.description.isNotEmpty)
                  Text(
                    deck.description,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: due.isEmpty
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudyScreen(
                                    cards: due,
                                    title: 'Review · ${deck!.name}',
                                    useSrs: true,
                                  ),
                                ),
                              ),
                      icon: const Icon(Icons.schedule),
                      label: Text('Review due (${due.length})'),
                    ),
                    OutlinedButton.icon(
                      onPressed: cards.isEmpty
                          ? null
                          : () {
                              final cram = List.of(cards)..shuffle();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudyScreen(
                                    cards: cram,
                                    title: 'Cram · ${deck!.name}',
                                    useSrs: false,
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Cram'),
                    ),
                    OutlinedButton.icon(
                      onPressed: cards.length < 2
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => QuizScreen(cards: cards),
                                ),
                              ),
                      icon: const Icon(Icons.quiz_outlined),
                      label: const Text('Quiz'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${cards.length} cards · ${due.length} due',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: cards.isEmpty
                ? const Center(child: Text('No cards yet. Tap + to add.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cards.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return _CardTile(card: card, allCards: cards);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final card = await Navigator.push<Flashcard>(
            context,
            MaterialPageRoute(
              builder: (_) => AddCardScreen(deckId: deckId),
            ),
          );
          if (card != null) await state.addCard(card);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  final Flashcard card;
  final List<Flashcard> allCards;

  const _CardTile({required this.card, required this.allCards});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Card(
      child: ListTile(
        title: Text(card.question, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.answer, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              card.isDue ? 'Due now · Box ${card.box}' : 'Box ${card.box}',
              style: TextStyle(
                fontSize: 12,
                color: card.isDue
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).hintColor,
              ),
            ),
            if (card.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: card.tags
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
        isThreeLine: true,
        leading: IconButton(
          icon: Icon(
            card.isFavorite ? Icons.star : Icons.star_border,
            color: card.isFavorite ? Colors.amber : null,
          ),
          onPressed: () => state.toggleFavorite(card.id),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') {
              final updated = await Navigator.push<Flashcard>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddCardScreen(
                    deckId: card.deckId,
                    existing: card,
                  ),
                ),
              );
              if (updated != null) await state.updateCard(updated);
            } else if (v == 'delete') {
              await state.deleteCard(card.id);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
        onTap: () {
          final index = allCards.indexWhere((c) => c.id == card.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudyScreen(
                cards: List.of(allCards),
                startIndex: index < 0 ? 0 : index,
                title: 'Study',
                useSrs: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
