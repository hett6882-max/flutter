import 'package:flutter/material.dart';
import '../widgets/app_scope.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final mastery = (state.overallMastery() * 100).round();
    final due = state.dueCards.length;
    final fav = state.favorites.length;
    final boxes = List.generate(
      6,
      (i) => state.cards.where((c) => c.box == i).length,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatTile(
                label: 'Cards',
                value: '${state.cards.length}',
                icon: Icons.style,
              ),
              _StatTile(
                label: 'Decks',
                value: '${state.decks.length}',
                icon: Icons.library_books,
              ),
              _StatTile(
                label: 'Due',
                value: '$due',
                icon: Icons.schedule,
              ),
              _StatTile(
                label: 'Streak',
                value: '${state.streak}🔥',
                icon: Icons.local_fire_department,
              ),
              _StatTile(
                label: 'Today',
                value: '${state.studiedToday}/${state.dailyGoal}',
                icon: Icons.flag,
              ),
              _StatTile(
                label: 'Mastery',
                value: '$mastery%',
                icon: Icons.emoji_events,
              ),
              _StatTile(
                label: 'Favorites',
                value: '$fav',
                icon: Icons.star,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Leitner boxes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (i) {
            final count = boxes[i];
            final max = state.cards.isEmpty ? 1 : state.cards.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Box $i · $count cards'),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: count / max,
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Text(
            'Higher boxes = cards you know better. “Again” sends a card back to box 0.',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: scheme.primary),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label, style: TextStyle(color: scheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
