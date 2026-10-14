import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/user/user_shell.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/user/study_screen.dart';
import 'screens/user/deck_list_screen.dart';

class FlashMasterApp extends StatelessWidget {
  const FlashMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashMaster',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/user': (_) => const UserShell(),
        '/admin': (_) => const AdminShell(),
        '/study': (ctx) => StudyScreen(
              deckId: ModalRoute.of(ctx)!.settings.arguments as String,
            ),
        '/decks': (_) => const DeckListScreen(),
      },
    );
  }
}
