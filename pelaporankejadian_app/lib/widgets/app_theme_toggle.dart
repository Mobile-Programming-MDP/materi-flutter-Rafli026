import 'package:flutter/material.dart';

import '../state/app_state.dart';

class AppThemeToggle extends StatelessWidget {
  final AppState appState;

  const AppThemeToggle({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: appState.toggleTheme,
      icon: Icon(
        appState.themeMode == ThemeMode.dark
            ? Icons.dark_mode
            : Icons.light_mode,
      ),
      tooltip: 'Toggle Theme',
    );
  }
}
