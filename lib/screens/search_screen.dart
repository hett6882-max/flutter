import 'package:flutter/material.dart';
import '../widgets/app_scope.dart';
import 'study_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final allTags = state.cards.expand((c) => c.tags).toSet().toList()..sort();
    final results = state.search(_query, tag: _tag);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search question, answer, or tag',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          if (allTags.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All tags'),
                      selected: _tag == null,
                      onSelected: (_) => setState(() => _tag = null),
                    ),
                  ),
                  ...allTags.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(t),
                        selected: _tag == t,
                        onSelected: (_) => setState(
                          () => _tag = _tag == t ? null : t,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No matches'))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final card = results[index];
                      return ListTile(
                        title: Text(card.question),
                        subtitle: Text(card.answer, maxLines: 1),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudyScreen(
                              cards: results,
                              startIndex: index,
                              title: 'Search results',
                              useSrs: false,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
