import 'package:flutter/material.dart';
import '../models/deck.dart';
import '../widgets/app_scope.dart';
import 'deck_detail_screen.dart';
import 'edit_deck_screen.dart';
import 'search_screen.dart';

class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashMaster'),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          _HeroBanner(
            due: state.dueCards.length,
            streak: state.streak,
            studied: state.studiedToday,
            goal: state.dailyGoal,
          ),
          const SizedBox(height: 16),
          Text(
            'Your decks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          if (state.decks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No decks yet. Create one!')),
            )
          else
            ...state.decks.map((deck) {
              final count = state.cardsForDeck(deck.id).length;
              final due = state.dueCountForDeck(deck.id);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: deck.color.withValues(alpha: 0.15),
                    child: Icon(Icons.style, color: deck.color),
                  ),
                  title: Text(
                    deck.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${deck.category} · $count cards'
                    '${due > 0 ? ' · $due due' : ''}',
                  ),
                  trailing: Icon(Icons.chevron_right, color: scheme.outline),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeckDetailScreen(deckId: deck.id),
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final deck = await Navigator.push<Deck>(
            context,
            MaterialPageRoute(builder: (_) => const EditDeckScreen()),
          );
          if (deck != null) await state.addDeck(deck);
        },
        icon: const Icon(Icons.add),
        label: const Text('New deck'),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final int due;
  final int streak;
  final int studied;
  final int goal;

  const _HeroBanner({
    required this.due,
    required this.streak,
    required this.studied,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final progress = goal == 0 ? 0.0 : (studied / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today',
            style: TextStyle(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$due cards due · 🔥 $streak day streak',
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.onPrimary.withValues(alpha: 0.25),
              color: scheme.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Daily goal: $studied / $goal reviews',
            style: TextStyle(color: scheme.onPrimary.withValues(alpha: 0.9)),
          ),
        ],
      ),
    );
  }
}
