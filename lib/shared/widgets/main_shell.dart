import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_color_theme.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: navigationShell,
    );
  }
}
