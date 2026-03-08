import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_color_theme.dart';
import '../utils/haptics.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
    required this.currentPath,
  });

  final StatefulNavigationShell navigationShell;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const rootPaths = {'/home', '/todo', '/ledger', '/social', '/memo'};
    final showBottomNav = rootPaths.contains(currentPath);

    return Scaffold(
      extendBody: true,
      backgroundColor: colors.background,
      body: navigationShell,
      bottomNavigationBar: showBottomNav
          ? _LiquidGlassBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                if (index == navigationShell.currentIndex) {
                  Haptics.light();
                  return;
                }
                Haptics.select();
                navigationShell.goBranch(index);
              },
            )
          : null,
    );
  }
}

class _LiquidGlassBottomNav extends StatelessWidget {
  const _LiquidGlassBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.check_circle_rounded, label: 'Todo'),
    (icon: Icons.receipt_long_rounded, label: 'Ledger'),
    (icon: Icons.forum_rounded, label: 'Social'),
    (icon: Icons.edit_note_rounded, label: 'Memo'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 82,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.26)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 0.8,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          Colors.white.withValues(alpha: 0.14),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.30),
                          Colors.white.withValues(alpha: 0.14),
                        ],
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final count = _items.length;
                  const horizontalInset = 8.0;
                  final usableWidth =
                      constraints.maxWidth - (horizontalInset * 2);
                  final cellWidth = usableWidth / count;
                  final indicatorWidth = (cellWidth - 4).clamp(56.0, 72.0);
                  final indicatorLeft =
                      horizontalInset +
                      (cellWidth * currentIndex) +
                      ((cellWidth - indicatorWidth) / 2);

                  return Stack(
                    children: [
                      // 상단 유리 반사층
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(
                                    alpha: isDark ? 0.16 : 0.08,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.42],
                              ),
                            ),
                          ),
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                        left: indicatorLeft,
                        top: 8,
                        child: Container(
                          width: indicatorWidth,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isDark
                                    ? [
                                      Colors.white.withValues(alpha: 0.30),
                                      Colors.white.withValues(alpha: 0.14),
                                    ]
                                  : [
                                      Colors.white.withValues(alpha: 0.62),
                                      colors.card.withValues(alpha: 0.38),
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                spreadRadius: 0.5,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.30)
                                  : Colors.black.withValues(alpha: 0.06),
                              width: 0.8,
                            ),
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(
                                    alpha: isDark ? 0.24 : 0.12,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: List.generate(_items.length, (index) {
                          final item = _items[index];
                          final selected = index == currentIndex;
                          final color = selected
                              ? colors.textPrimary
                              : colors.textMuted.withValues(alpha: 0.92);
                          return Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                onTap: () => onTap(index),
                                child: SizedBox(
                                  height: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(item.icon, size: 21, color: color),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.label,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: selected
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
