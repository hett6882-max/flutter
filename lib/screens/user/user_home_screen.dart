import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/deck.dart';
import '../../data/repositories/deck_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../providers/auth_provider.dart';
import 'deck_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _deckRepo = DeckRepository();
  final _progressRepo = ProgressRepository();
  bool _loading = true;
  List<Deck> _decks = [];
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
    final overall = await _progressRepo.userOverall(user.id);
    if (!mounted) return;
    setState(() {
      _decks = decks;
      _overall = overall;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Welcome, ${user?.username ?? ''}!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your progress',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: (_overall['total'] ?? 0) == 0
                                ? 0
                                : ((_overall['known'] ?? 0) /
                                    (_overall['total']!)),
                            minHeight: 8,
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Known ${_overall['known']} / ${_overall['total']} cards '
                              '(${_overall['reviewed']} reviewed)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Available decks',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_decks.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No decks available yet.'),
                      ),
                    )
                  else
                    ..._decks.take(5).map((d) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.style),
                            title: Text(d.title),
                            subtitle: Text(d.description.isEmpty
                                ? d.category
                                : d.description),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pushNamed(
                                context, '/study', arguments: d.id),
                          ),
                        )),
                  if (_decks.length > 5)
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DeckListScreen())),
                      child: const Text('View all decks'),
                    ),
                ],
              ),
      ),
    );
  }
}
