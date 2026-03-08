import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/utils/haptics.dart';
import '../../../../shared/widgets/app_nav_menu.dart';

class MemoPage extends StatelessWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final fabBottomOffset = 90.0 + bottomInset;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Text('SENT'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: colors.textMuted,
              size: 22,
            ),
            onPressed: () => showAppNavMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note_rounded, size: 52, color: colors.textDisabled),
            const SizedBox(height: 16),
            Text(
              l10n.memoEmptyTitle,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.memoEmptySubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textDisabled,
                fontSize: 13,
                letterSpacing: -0.1,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomOffset),
        child: FloatingActionButton(
          heroTag: 'memo_fab',
          onPressed: () {
            Haptics.medium();
          },
          backgroundColor: colors.foreground,
          foregroundColor: colors.background,
          elevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }
}
