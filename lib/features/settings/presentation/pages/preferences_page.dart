import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';

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

// ── SharedPreferences 키 ─────────────────────────────────────────
const _kNotifFriendRequest = 'notif_friend_request';
const _kNotifTodo = 'notif_todo';

// ════════════════════════════════════════════════════════════════
class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  String? _uuid;
  bool _notifFriendRequest = true;
  bool _notifTodo = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token =
        await ref.read(tokenStorageProvider).getAccessToken();
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _uuid = token != null ? _extractUuidFromToken(token) : null;
      _notifFriendRequest = prefs.getBool(_kNotifFriendRequest) ?? true;
      _notifTodo = prefs.getBool(_kNotifTodo) ?? true;
    });
  }

  Future<void> _setToggle(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preferences'),
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

          // ── 프로필 ─────────────────────────────────────────────
          const _SectionHeader(label: '프로필'),
          _NavTile(
            label: '이름 변경',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),
          _NavTile(
            label: '프로필 사진',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),

          const SizedBox(height: 28),

          // ── 개인정보 보호 ─────────────────────────────────────
          const _SectionHeader(label: '개인정보 보호'),
          _NavTile(
            label: '비공개 계정',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),
          _NavTile(
            label: '차단 목록',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),

          const SizedBox(height: 28),

          // ── 알림 ───────────────────────────────────────────────
          const _SectionHeader(label: '알림'),
          _ToggleTile(
            label: '친구 요청 알림',
            value: _notifFriendRequest,
            onChanged: (v) {
              setState(() => _notifFriendRequest = v);
              _setToggle(_kNotifFriendRequest, v);
            },
          ),
          _ToggleTile(
            label: '할 일 알림',
            value: _notifTodo,
            onChanged: (v) {
              setState(() => _notifTodo = v);
              _setToggle(_kNotifTodo, v);
            },
          ),

          const SizedBox(height: 28),

          // ── 앱 권한 ────────────────────────────────────────────
          const _SectionHeader(label: '앱 권한'),
          _InfoRow(
            label: '앱 권한 관리',
            detail: 'iOS 설정 > SENT',
          ),

          const SizedBox(height: 28),

          // ── 공지 / 약관 ────────────────────────────────────────
          const _SectionHeader(label: '공지'),
          _NavTile(
            label: '공지사항',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),
          _NavTile(
            label: '서비스 이용약관',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),
          _NavTile(
            label: '개인정보 처리방침',
            badge: '준비 중',
            onTap: () => _showComingSoon(),
          ),

          const SizedBox(height: 28),

          // ── 계정 ───────────────────────────────────────────────
          const _SectionHeader(label: '계정'),
          _ActionTile(
            label: '로그아웃',
            color: AppColors.destructiveRed,
            onTap: _logout,
          ),

          const SizedBox(height: 28),

          // ── 앱 정보 ────────────────────────────────────────────
          const _SectionHeader(label: '앱 정보'),
          const _InfoRow(label: '버전', detail: '1.0.0'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('준비 중인 기능이에요.')),
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

// 내 ID 타일
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

// 이동 타일 (ChevronRight + 선택적 뱃지)
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.onTap,
    this.badge,
  });
  final String label;
  final VoidCallback onTap;
  final String? badge;

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
                if (badge != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
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

// 토글 타일
class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.fromLTRB(18, 4, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w400)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

// 액션 타일 (로그아웃 등 — 컬러 강조)
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

// 정보 표시 타일 (탭 없음)
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.detail});
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400)),
          Text(detail,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 14)),
        ],
      ),
    );
  }
}
