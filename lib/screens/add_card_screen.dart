import 'package:flutter/material.dart';
import '../models/flashcard.dart';

class AddCardScreen extends StatefulWidget {
  final String deckId;
  final Flashcard? existing;

  const AddCardScreen({
    super.key,
    required this.deckId,
    this.existing,
  });

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  late final TextEditingController _question;
  late final TextEditingController _answer;
  late final TextEditingController _tags;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _question = TextEditingController(text: widget.existing?.question ?? '');
    _answer = TextEditingController(text: widget.existing?.answer ?? '');
    _tags = TextEditingController(
      text: widget.existing?.tags.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _question.dispose();
    _answer.dispose();
    _tags.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final existing = widget.existing;
    final card = existing == null
        ? Flashcard(
            question: _question.text.trim(),
            answer: _answer.text.trim(),
            deckId: widget.deckId,
            tags: tags,
          )
        : existing.copyWith(
            question: _question.text.trim(),
            answer: _answer.text.trim(),
            tags: tags,
          );

    Navigator.pop(context, card);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit card' : 'Add card')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _question,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Question / Front',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _answer,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Answer / Back',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tags,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                hintText: 'basics, exam, chapter1',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              child: Text(editing ? 'Save changes' : 'Add card'),
            ),
          ],
        ),
      ),
    );
  }
}
