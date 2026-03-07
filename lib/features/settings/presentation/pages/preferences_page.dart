import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../ledger/presentation/pages/ledger_category_page.dart';
import '../../../todo/presentation/pages/category_page.dart';
import '../providers/settings_provider.dart';
import 'info_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 14),
          _AccountHeroCard(colors: c),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _QuickActionTile(
                    label: l10n.notifications,
                    icon: Icons.notifications_none_rounded,
                    colors: c,
                    onTap: () => _push(context, const NotificationsPage()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionTile(
                    label: l10n.todoCategory,
                    icon: Icons.checklist_rounded,
                    colors: c,
                    onTap: () => _push(context, const CategoryPage()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _QuickActionTile(
                    label: l10n.ledgerCategory,
                    icon: Icons.account_balance_wallet_outlined,
                    colors: c,
                    onTap: () => _push(context, const LedgerCategoryPage()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(label: l10n.appearance.toUpperCase(), colors: c),
          _ThemeSegmentTile(colors: c),
          const SizedBox(height: 6),
          _LanguageTile(colors: c),
          const SizedBox(height: 28),
          _SectionHeader(label: l10n.account.toUpperCase(), colors: c),
          _NavTile(
            label: l10n.profile,
            subtitle: l10n.manage,
            icon: Icons.person_outline_rounded,
            colors: c,
            onTap: () => _push(context, ProfilePage()),
          ),
          const SizedBox(height: 28),
          _SectionHeader(label: l10n.info.toUpperCase(), colors: c),
          _NavTile(
            label: l10n.info,
            subtitle: l10n.legalInfo,
            icon: Icons.info_outline_rounded,
            colors: c,
            onTap: () => _push(context, const InfoPage()),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Material(
              color: c.card,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => _logout(context, ref),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: c.destructiveRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.logout,
                        style: TextStyle(
                          color: c.destructiveRed,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page,
        transitionsBuilder: (c, animation, a1, child) => SlideTransition(
          position: animation.drive(
            Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: TextStyle(color: c.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: TextStyle(color: c.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout, style: TextStyle(color: c.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final tokenStorage = ref.read(tokenStorageProvider);
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await AuthRepository(
          ref.read(dioProvider),
        ).logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await tokenStorage.clearTokens();
    ref.read(authStateNotifierProvider).logout();
  }
}

class _ThemeSegmentTile extends ConsumerWidget {
  const _ThemeSegmentTile({required this.colors});
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Text(
              l10n.theme,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            _ThemeSegment(
              label: l10n.themeSystem,
              mode: ThemeMode.system,
              current: current,
              colors: colors,
            ),
            const SizedBox(width: 6),
            _ThemeSegment(
              label: l10n.themeDark,
              mode: ThemeMode.dark,
              current: current,
              colors: colors,
            ),
            const SizedBox(width: 6),
            _ThemeSegment(
              label: l10n.themeLight,
              mode: ThemeMode.light,
              current: current,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSegment extends ConsumerWidget {
  const _ThemeSegment({
    required this.label,
    required this.mode,
    required this.current,
    required this.colors,
  });

  final String label;
  final ThemeMode mode;
  final ThemeMode current;
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = current == mode;
    return GestureDetector(
      onTap: () => ref.read(themeModeNotifierProvider.notifier).set(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.foreground : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colors.foreground : colors.border,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.background : colors.textMuted,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile({required this.colors});
  final AppColorTheme colors;

  static const _languages = [
    (locale: Locale('ko'), label: '한국어'),
    (locale: Locale('en'), label: 'English'),
    (locale: Locale('ja'), label: '日本語'),
  ];

  String _currentLabel(Locale? locale, AppLocalizations l10n) {
    if (locale == null) return l10n.systemDefault;
    return _languages
            .where((l) => l.locale.languageCode == locale.languageCode)
            .map((l) => l.label)
            .firstOrNull ??
        l10n.systemDefault;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _showLanguageSheet(context, ref, locale, l10n),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Text(
                  l10n.language,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  _currentLabel(locale, l10n),
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textDisabled,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    Locale? current,
    AppLocalizations l10n,
  ) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(
                l10n.language,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(height: 0.5, color: c.border),
            _LanguageRow(
              label: l10n.systemDefault,
              selected: current == null,
              colors: c,
              onTap: () {
                ref.read(localeNotifierProvider.notifier).set(null);
                Navigator.of(context).pop();
              },
            ),
            for (final lang in _languages) ...[
              Divider(height: 0.5, color: c.border, indent: 20, endIndent: 20),
              _LanguageRow(
                label: lang.label,
                selected: current?.languageCode == lang.locale.languageCode,
                colors: c,
                onTap: () {
                  ref.read(localeNotifierProvider.notifier).set(lang.locale);
                  Navigator.of(context).pop();
                },
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppColorTheme colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.textPrimary : colors.textSecondary,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_rounded, color: colors.textPrimary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.colors});
  final String label;
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({required this.colors});
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Icon(
                Icons.settings_rounded,
                color: colors.textPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    l10n.loginTagline,
                    style: TextStyle(color: colors.textMuted, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: colors.textSecondary, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.onTap,
    required this.colors,
    this.subtitle,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final AppColorTheme colors;
  final String? subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.border, width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: colors.textMuted, size: 18),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.textDisabled,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
