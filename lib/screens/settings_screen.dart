import 'package:flutter/material.dart';
import '../widgets/app_scope.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Appearance'),
            dense: true,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (s) => state.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Daily review goal'),
            subtitle: Text('${state.dailyGoal} cards'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => state.setDailyGoal(state.dailyGoal - 5),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  onPressed: () => state.setDailyGoal(state.dailyGoal + 5),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About FlashMaster'),
            subtitle: const Text(
              'Decks · tags · search · spaced repetition · quiz · streaks · dark mode',
            ),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'FlashMaster',
              applicationVersion: '1.0.0',
              applicationLegalese: 'Learn. Revise. Master.',
            ),
          ),
        ],
      ),
    );
  }
}
