import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/deck.dart';
import '../../data/repositories/deck_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../providers/auth_provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _deckRepo = DeckRepository();
  final _progressRepo = ProgressRepository();
  bool _loading = true;
  List<Deck> _decks = [];
  Map<String, Map<String, int>> _progress = {};
  Map<String, int> _overall = const {'total': 0, 'known': 0, 'reviewed': 0};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    final decks = await _deckRepo.getAll();
    final prog = <String, Map<String, int>>{};
    for (final d in decks) {
      prog[d.id] = await _progressRepo.deckProgress(user.id, d.id);
    }
    final overall = await _progressRepo.userOverall(user.id);
    if (!mounted) return;
    setState(() {
      _decks = decks;
      _progress = prog;
      _overall = overall;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _overall['total'] ?? 0;
    final known = _overall['known'] ?? 0;
    final reviewed = _overall['reviewed'] ?? 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: total == 0 ? 0 : known / total,
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text('Known $known / $total  (reviewed $reviewed)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('By deck', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ..._decks.map((d) {
                    final p = _progress[d.id] ??
                        const {'total': 0, 'known': 0, 'reviewed': 0};
                    final t = p['total'] ?? 0;
                    final k = p['known'] ?? 0;
                    return Card(
                      child: ListTile(
                        title: Text(d.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LinearProgressIndicator(value: t == 0 ? 0 : k / t),
                            const SizedBox(height: 4),
                            Text('$k / $t known'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
