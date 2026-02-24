import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import 'info_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

// ── JWT → UUID 추출 ───────────────────────────────────────────────
String? _extractUuidFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return json['sub'] as String?;
  } catch (_) {
    return null;
  }
}

// ════════════════════════════════════════════════════════════════
class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  String? _uuid;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (!mounted) return;
    setState(() {
      _uuid = token != null ? _extractUuidFromToken(token) : null;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('로그아웃',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
        content: const Text('로그아웃 하시겠어요?',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('로그아웃',
                style: TextStyle(color: AppColors.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final tokenStorage = ref.read(tokenStorageProvider);
    final refreshToken = await tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      try {
        await AuthRepository(ref.read(dioProvider))
            .logout(refreshToken: refreshToken);
      } catch (_) {}
    }
    await tokenStorage.clearTokens();
    ref.read(authStateNotifierProvider).logout();
  }

  void _push(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('설정'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ── 내 ID ──────────────────────────────────────────────
          const _SectionHeader(label: '내 ID'),
          _MyIdTile(uuid: _uuid),

          const SizedBox(height: 28),

          // ── 설정 ───────────────────────────────────────────────
          const _SectionHeader(label: '설정'),
          _NavTile(
            label: '프로필',
            onTap: () => _push(const ProfilePage()),
          ),
          _NavTile(
            label: '알림',
            onTap: () => _push(const NotificationsPage()),
          ),

          const SizedBox(height: 28),

          // ── 정보 ───────────────────────────────────────────────
          const _SectionHeader(label: '정보'),
          _NavTile(
            label: '정보',
            onTap: () => _push(const InfoPage()),
          ),

          const SizedBox(height: 28),

          // ── 계정 ───────────────────────────────────────────────
          const _SectionHeader(label: '계정'),
          _ActionTile(
            label: '로그아웃',
            color: AppColors.destructiveRed,
            onTap: _logout,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Tiles
// ════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MyIdTile extends StatelessWidget {
  const _MyIdTile({required this.uuid});
  final String? uuid;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '친구에게 이 ID를 알려주세요',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      letterSpacing: 0.2),
                ),
                const SizedBox(height: 4),
                Text(
                  uuid ?? '불러오는 중...',
                  style: TextStyle(
                    color: uuid != null
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          if (uuid != null)
            IconButton(
              icon: const Icon(Icons.copy_rounded,
                  size: 18, color: AppColors.textMuted),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: uuid!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ID가 클립보드에 복사됐습니다.')),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textDisabled, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.label,
    required this.onTap,
    this.color,
  });
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Text(label,
                style: TextStyle(
                    color: color ?? AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400)),
          ),
        ),
      ),
    );
  }
}
