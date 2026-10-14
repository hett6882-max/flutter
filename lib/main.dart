import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/database/database_helper.dart';
import 'providers/auth_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..init(),
      child: const FlashMasterApp(),
    ),
  );
}
