import 'package:flutter/material.dart';
import '../widgets/app_scope.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

class ReviewHubScreen extends StatelessWidget {
  const ReviewHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final due = state.dueCards;
    final favorites = state.favorites;
    final all = List.of(state.cards);

    return Scaffold(
      appBar: AppBar(title: const Text('Study hub')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ModeCard(
            icon: Icons.schedule,
            title: 'Spaced review',
            subtitle: '${due.length} cards due now',
            enabled: due.isNotEmpty,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudyScreen(
                  cards: due,
                  title: 'Due review',
                  useSrs: true,
                ),
              ),
            ),
          ),
          _ModeCard(
            icon: Icons.shuffle,
            title: 'Cram mode',
            subtitle: 'Shuffle all cards — quick revision',
            enabled: all.isNotEmpty,
            onTap: () {
              final cram = List.of(all)..shuffle();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudyScreen(
                    cards: cram,
                    title: 'Cram',
                    useSrs: false,
                  ),
                ),
              );
            },
          ),
          _ModeCard(
            icon: Icons.quiz_outlined,
            title: 'Multiple-choice quiz',
            subtitle: 'Test yourself with 4 options',
            enabled: all.length >= 2,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuizScreen(cards: all)),
            ),
          ),
          _ModeCard(
            icon: Icons.star,
            title: 'Favorites only',
            subtitle: '${favorites.length} starred cards',
            enabled: favorites.isNotEmpty,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => StudyScreen(
                  cards: favorites,
                  title: 'Favorites',
                  useSrs: false,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: After flipping a card, tap Again / Hard / Good / Easy. '
            'FlashMaster schedules the next review automatically (spaced repetition).',
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        enabled: enabled,
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
