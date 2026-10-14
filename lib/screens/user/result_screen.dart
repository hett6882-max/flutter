import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String deckId;
  final String deckTitle;
  final int total;
  final int known;
  final int unknown;
  final List<String> missedCardIds;

  const ResultScreen({
    required this.deckId,
    required this.deckTitle,
    required this.total,
    required this.known,
    required this.unknown,
    required this.missedCardIds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final score = total == 0 ? 0.0 : (known / total) * 100;
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(deckTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('${score.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Known: $known   Need review: $unknown   Total: $total'),
                const SizedBox(height: 24),
                if (missedCardIds.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () => Navigator.pushNamed(context, '/study',
                        arguments: deckId),
                    child: const Text('Review deck again'),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: () => Navigator.popUntil(
                      context, (r) => r.isFirst || r.settings.name == '/user'),
                  child: const Text('Back to decks'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
