import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BillerApp());
}

class BillerApp extends StatelessWidget {
  const BillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biller POS & Invoicing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
