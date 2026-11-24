import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BillerApp());
}

/// Custom ScrollBehavior that completely eliminates scrollbars across all platforms
class NoScrollbarBehavior extends ScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class BillerApp extends StatelessWidget {
  const BillerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VIHA Biller POS',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const NoScrollbarBehavior(),
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}
