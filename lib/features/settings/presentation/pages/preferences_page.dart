import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/notification/fcm_token_provider.dart';
import '../../../../core/notification/notification_service.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/widgets/pressable_highlight.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../ledger/presentation/pages/ledger_category_page.dart';
import '../../../social/presentation/providers/friend_provider.dart';
import '../../../todo/presentation/pages/category_page.dart';
import '../providers/settings_provider.dart';
import 'info_page.dart';
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

          // ── 프로필 카드 ──────────────────────────────────────────
          _ProfileCard(colors: c),

          const SizedBox(height: 24),

          // ── 외관 ─────────────────────────────────────────────────
          _SectionHeader(label: l10n.appearance.toUpperCase(), colors: c),
          _SettingsGroup(
            colors: c,
            children: [
              _ThemeSegmentTile(colors: c),
              _LanguageTile(colors: c),
            ],
          ),

          const SizedBox(height: 24),

          // ── 알림 ─────────────────────────────────────────────────
          _SectionHeader(label: l10n.notifications.toUpperCase(), colors: c),
          _SettingsGroup(
            colors: c,
            children: [
              _SwitchTile(
                prefKey: 'notif_friend_request',
                label: l10n.friendRequestNotification,
                colors: c,
              ),
              _SwitchTile(
                prefKey: 'notif_todo',
                label: l10n.todoReminderNotification,
                colors: c,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 카테고리 관리 ─────────────────────────────────────────
          _SectionHeader(
              label: l10n.categoryManagement.toUpperCase(), colors: c),
          _SettingsGroup(
            colors: c,
            children: [
              _NavTile(
                label: l10n.todoCategory,
                icon: Icons.checklist_rounded,
                colors: c,
                onTap: () => _push(context, const CategoryPage()),
              ),
              _NavTile(
                label: l10n.ledgerCategory,
                icon: Icons.account_balance_wallet_outlined,
                colors: c,
                onTap: () => _push(context, const LedgerCategoryPage()),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 정보 ─────────────────────────────────────────────────
          _SectionHeader(label: l10n.info.toUpperCase(), colors: c),
          _SettingsGroup(
            colors: c,
            children: [
              _NavTile(
                label: l10n.profile,
                icon: Icons.person_outline_rounded,
                colors: c,
                onTap: () => _push(context, const ProfilePage()),
              ),
              _NavTile(
                label: l10n.info,
                icon: Icons.info_outline_rounded,
                colors: c,
                onTap: () => _push(context, const InfoPage()),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── 로그아웃 ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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

          // ── 버전 캡션 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
            child: Center(
              child: Text(
                'v${AppConfig.appVersion}',
                style: TextStyle(
                  color: c.textDisabled,
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            child:
                Text(l10n.cancel, style: TextStyle(color: c.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.logout,
                style: TextStyle(color: c.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // FCM 토큰 삭제 (서버)
    try {
      final fcmRepo = ref.read(fcmTokenRepositoryProvider);
      await fcmRepo.unregisterToken();
    } catch (_) {}

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

// ══════════════════════════════════════════════════════════════════
// 프로필 카드
// ══════════════════════════════════════════════════════════════════
class _ProfileCard extends ConsumerStatefulWidget {
  const _ProfileCard({required this.colors});
  final AppColorTheme colors;

  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  bool _copied = false;

  Future<void> _onCopyCode(String code) async {
    if (_copied) return;
    await Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myProfileProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        padding: const EdgeInsets.all(16),
        child: profileAsync.when(
          loading: () => const SizedBox(
            height: 60,
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, _) => const SizedBox(height: 60),
          data: (profile) {
            if (profile == null) return const SizedBox(height: 60);
            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colors.secondary,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: colors.border, width: 0.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: profile.profileImageUrl != null
                          ? Image.network(
                              profile.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, e) => Icon(
                                Icons.person_rounded,
                                size: 24,
                                color: colors.textDisabled,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: colors.textDisabled,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            profile.email,
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _onCopyCode(profile.userCode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: colors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          l10n.myCode,
                          style: TextStyle(
                            color: colors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            profile.userCode,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                                opacity: animation, child: child),
                          ),
                          child: Icon(
                            _copied
                                ? Icons.check_rounded
                                : Icons.copy_rounded,
                            key: ValueKey(_copied),
                            size: 14,
                            color: _copied
                                ? colors.textPrimary
                                : colors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 설정 그룹 카드
// ══════════════════════════════════════════════════════════════════
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.colors, required this.children});
  final AppColorTheme colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: colors.border,
                  indent: 18,
                  endIndent: 18,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 테마 세그먼트 타일
// ══════════════════════════════════════════════════════════════════
class _ThemeSegmentTile extends ConsumerWidget {
  const _ThemeSegmentTile({required this.colors});
  final AppColorTheme colors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
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

// ══════════════════════════════════════════════════════════════════
// 언어 타일
// ══════════════════════════════════════════════════════════════════
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

    return PressableHighlight(
      onTap: () => _showLanguageSheet(context, ref, locale, l10n),
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
              Divider(
                  height: 0.5,
                  color: c.border,
                  indent: 20,
                  endIndent: 20),
              _LanguageRow(
                label: lang.label,
                selected:
                    current?.languageCode == lang.locale.languageCode,
                colors: c,
                onTap: () {
                  ref
                      .read(localeNotifierProvider.notifier)
                      .set(lang.locale);
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
    return PressableHighlight(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color:
                  selected ? colors.textPrimary : colors.textSecondary,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          const Spacer(),
          if (selected)
            Icon(Icons.check_rounded,
                color: colors.textPrimary, size: 18),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Switch 타일 (SharedPreferences 기반)
// ══════════════════════════════════════════════════════════════════
class _SwitchTile extends StatefulWidget {
  const _SwitchTile({
    required this.prefKey,
    required this.label,
    required this.colors,
  });

  final String prefKey;
  final String label;
  final AppColorTheme colors;

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  bool _value = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _value = prefs.getBool(widget.prefKey) ?? true);
  }

  Future<void> _toggle(bool v) async {
    setState(() => _value = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(widget.prefKey, v);

    // FCM 토픽 구독/해제
    final topic = widget.prefKey; // e.g. 'notif_friend_request', 'notif_todo'
    final service = NotificationService.instance;
    if (v) {
      await service.subscribeToTopic(topic);
    } else {
      await service.unsubscribeFromTopic(topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch.adaptive(
            value: _value,
            onChanged: _toggle,
            activeThumbColor: widget.colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 네비게이션 타일
// ══════════════════════════════════════════════════════════════════
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.onTap,
    required this.colors,
    this.icon,
  });
  final String label;
  final VoidCallback onTap;
  final AppColorTheme colors;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return PressableHighlight(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: colors.textMuted, size: 18),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.textDisabled,
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// 섹션 헤더
// ══════════════════════════════════════════════════════════════════
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
