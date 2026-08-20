import 'dart:math';
import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class QuizScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const QuizScreen({super.key, required this.cards});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Flashcard> _queue;
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _locked = false;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _queue = List.of(widget.cards)..shuffle();
    _prepareOptions();
  }

  void _prepareOptions() {
    final current = _queue[_index];
    final others = widget.cards
        .where((c) => c.id != current.id)
        .map((c) => c.answer)
        .toSet()
        .toList()
      ..shuffle(Random());
    _options = [
      current.answer,
      ...others.take(3),
    ]..shuffle(Random());
    _selected = null;
    _locked = false;
  }

  void _choose(String option) {
    if (_locked) return;
    setState(() {
      _selected = option;
      _locked = true;
      if (option == _queue[_index].answer) _score++;
    });
  }

  void _next() {
    if (_index >= _queue.length - 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Quiz finished'),
          content: Text('Score: $_score / ${_queue.length}'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _prepareOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final card = _queue[_index];
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz · ${_index + 1}/${_queue.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Score: $_score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  card.question,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._options.map((option) {
              Color? bg;
              if (_locked) {
                if (option == card.answer) {
                  bg = Colors.green.withValues(alpha: 0.2);
                } else if (option == _selected) {
                  bg = Colors.red.withValues(alpha: 0.2);
                }
              } else if (option == _selected) {
                bg = scheme.primaryContainer;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: bg ?? scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _choose(option),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(option, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: _locked ? _next : null,
              child: Text(
                _index >= _queue.length - 1 ? 'Finish' : 'Next question',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
