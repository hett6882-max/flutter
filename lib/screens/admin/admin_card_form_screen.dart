import 'package:flutter/material.dart';

import '../../core/validators.dart';
import '../../data/models/card.dart' as m;
import '../../data/repositories/card_repository.dart';

class AdminCardFormScreen extends StatefulWidget {
  final String deckId;
  final m.FlashCard? card;
  const AdminCardFormScreen({required this.deckId, this.card, super.key});

  @override
  State<AdminCardFormScreen> createState() => _AdminCardFormScreenState();
}

class _AdminCardFormScreenState extends State<AdminCardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _front = TextEditingController();
  final _back = TextEditingController();
  final _repo = CardRepository();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.card;
    if (c != null) {
      _front.text = c.front;
      _back.text = c.back;
    }
  }

  @override
  void dispose() {
    _front.dispose();
    _back.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    if (widget.card == null) {
      await _repo.create(deckId: widget.deckId, front: _front.text, back: _back.text);
    } else {
      final updated = widget.card!.copyWith(front: _front.text.trim(), back: _back.text.trim());
      await _repo.update(updated);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.card == null ? 'Add Card' : 'Edit Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _front,
                decoration: const InputDecoration(labelText: 'Front (question)'),
                validator: (v) => Validators.required(v, field: 'Front'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _back,
                decoration: const InputDecoration(labelText: 'Back (answer)'),
                validator: (v) => Validators.required(v, field: 'Back'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
