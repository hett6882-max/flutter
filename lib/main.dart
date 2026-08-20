import 'package:flutter/material.dart';
import 'screens/shell_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'widgets/app_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlashmasterRoot());
}

class FlashmasterRoot extends StatefulWidget {
  const FlashmasterRoot({super.key});

  @override
  State<FlashmasterRoot> createState() => _FlashmasterRootState();
}

class _FlashmasterRootState extends State<FlashmasterRoot> {
  final AppState _state = AppState();
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();
    _state.load();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: AnimatedBuilder(
        animation: _state,
        builder: (context, _) {
          Widget home;
          if (!_state.isLoaded) {
            home = const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (!_splashFinished) {
            home = SplashScreen(
              onFinished: () => setState(() => _splashFinished = true),
            );
          } else {
            home = const ShellScreen();
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FlashMaster',
            themeMode: _state.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.indigo,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: home,
          );
        },
      ),
    );
  }
}

class FlashmasterApp extends StatelessWidget {
  const FlashmasterApp({super.key});

  @override
  Widget build(BuildContext context) => const FlashmasterRoot();
}
