import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/deck.dart';
import '../../data/repositories/deck_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../providers/auth_provider.dart';

class DeckListScreen extends StatefulWidget {
  const DeckListScreen({super.key});

  @override
  State<DeckListScreen> createState() => _DeckListScreenState();
}

class _DeckListScreenState extends State<DeckListScreen> {
  final _deckRepo = DeckRepository();
  final _progressRepo = ProgressRepository();
  final _search = TextEditingController();
  bool _loading = true;
  List<Deck> _decks = [];
  Map<String, Map<String, int>> _progress = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final decks = await _deckRepo.getAll(query: _search.text);
    final prog = <String, Map<String, int>>{};
    for (final d in decks) {
      prog[d.id] = await _progressRepo.deckProgress(user.id, d.id);
    }
    if (!mounted) return;
    setState(() {
      _decks = decks;
      _progress = prog;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search decks',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _load();
                        })
                    : null,
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: _decks.isEmpty
                        ? ListView(children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No decks found')),
                          ])
                        : ListView.builder(
                            itemCount: _decks.length,
                            itemBuilder: (_, i) {
                              final d = _decks[i];
                              final p = _progress[d.id] ??
                                  const {'total': 0, 'known': 0, 'reviewed': 0};
                              final total = p['total'] ?? 0;
                              final known = p['known'] ?? 0;
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                child: ListTile(
                                  leading: const Icon(Icons.style),
                                  title: Text(d.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (d.description.isNotEmpty)
                                        Text(d.description),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: total == 0 ? 0 : known / total,
                                      ),
                                      const SizedBox(height: 2),
                                      Text('$known / $total known',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                    ],
                                  ),
                                  trailing: FilledButton.tonal(
                                    onPressed: () => Navigator.pushNamed(
                                        context, '/study',
                                        arguments: d.id),
                                    child: const Text('Study'),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
