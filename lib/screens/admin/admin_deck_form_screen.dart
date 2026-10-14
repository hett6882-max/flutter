import 'package:flutter/material.dart';

import '../../core/validators.dart';
import '../../data/models/deck.dart';
import '../../data/repositories/deck_repository.dart';

class AdminDeckFormScreen extends StatefulWidget {
  final Deck? deck;
  const AdminDeckFormScreen({this.deck, super.key});

  @override
  State<AdminDeckFormScreen> createState() => _AdminDeckFormScreenState();
}

class _AdminDeckFormScreenState extends State<AdminDeckFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _category = TextEditingController();
  final _repo = DeckRepository();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.deck;
    if (d != null) {
      _title.text = d.title;
      _description.text = d.description;
      _category.text = d.category;
    } else {
      _category.text = 'General';
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    if (widget.deck == null) {
      await _repo.create(
        title: _title.text,
        description: _description.text,
        category: _category.text,
      );
    } else {
      final updated = widget.deck!.copyWith(
        title: _title.text.trim(),
        description: _description.text.trim(),
        category: _category.text.trim().isEmpty ? 'General' : _category.text.trim(),
      );
      await _repo.update(updated);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck == null ? 'Add Deck' : 'Edit Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => Validators.required(v, field: 'Title'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => Validators.required(v, field: 'Category'),
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
