import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _selectedIndex(location);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: child,
      bottomNavigationBar: _PillNavigationBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/memo')) return 1;
    if (location.startsWith('/social')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/todo');
      case 1: context.go('/memo');
      case 2: context.go('/social');
    }
  }
}

class _PillNavigationBar extends StatelessWidget {
  const _PillNavigationBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (label: 'Todo',   icon: Icons.check_circle_outline, activeIcon: Icons.check_circle),
    (label: 'Memo',   icon: Icons.edit_note_outlined,   activeIcon: Icons.edit_note),
    (label: 'Social', icon: Icons.people_outline,       activeIcon: Icons.people),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, bottom: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xCC1C1C1E),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isSelected = selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(6),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.muted,
                              borderRadius: BorderRadius.circular(34),
                            )
                          : null,
                      child: Center(
                        child: Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
