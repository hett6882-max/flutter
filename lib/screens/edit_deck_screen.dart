import 'package:flutter/material.dart';
import '../models/deck.dart';

class EditDeckScreen extends StatefulWidget {
  final Deck? existing;

  const EditDeckScreen({super.key, this.existing});

  @override
  State<EditDeckScreen> createState() => _EditDeckScreenState();
}

class _EditDeckScreenState extends State<EditDeckScreen> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _category;
  late int _color;

  static const _colors = [
    0xFF3F51B5,
    0xFF00897B,
    0xFFE65100,
    0xFF6A1B9A,
    0xFFC62828,
    0xFF1565C0,
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _desc = TextEditingController(text: widget.existing?.description ?? '');
    _category =
        TextEditingController(text: widget.existing?.category ?? 'General');
    _color = widget.existing?.colorValue ?? _colors.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _category.dispose();
    super.dispose();
  }

  void _save() {
    if (_name.text.trim().isEmpty) return;
    final base = widget.existing;
    final deck = Deck(
      id: base?.id,
      name: _name.text.trim(),
      description: _desc.text.trim(),
      category: _category.text.trim().isEmpty ? 'General' : _category.text.trim(),
      colorValue: _color,
      createdAt: base?.createdAt,
    );
    Navigator.pop(context, deck);
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Edit deck' : 'New deck')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'Deck name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Color'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _colors.map((c) {
              final selected = c == _color;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: CircleAvatar(
                  backgroundColor: Color(c),
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: Text(editing ? 'Save' : 'Create deck'),
          ),
        ],
      ),
    );
  }
}
