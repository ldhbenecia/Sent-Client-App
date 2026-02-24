import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/theme/app_colors.dart';

// ── JWT 페이로드에서 사용자 정보 추출 ────────────────────────────────
class _UserInfo {
  final String? displayName;
  final String? email;
  final String? profileImageUrl;
  const _UserInfo({this.displayName, this.email, this.profileImageUrl});
}

_UserInfo _parseToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return const _UserInfo();
    var payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
    while (payload.length % 4 != 0) {
      payload += '=';
    }
    final decoded = utf8.decode(base64.decode(payload));
    final json = jsonDecode(decoded) as Map<String, dynamic>;
    return _UserInfo(
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  } catch (_) {
    return const _UserInfo();
  }
}

// ════════════════════════════════════════════════════════════════
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  _UserInfo _info = const _UserInfo();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await ref.read(tokenStorageProvider).getAccessToken();
    if (!mounted || token == null) return;
    setState(() => _info = _parseToken(token));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('프로필'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 36),

          // ── 프로필 이미지 ───────────────────────────────────────
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: _info.profileImageUrl != null
                  ? Image.network(
                      _info.profileImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: AppColors.textDisabled,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 44,
                      color: AppColors.textDisabled,
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // ── 이름 ────────────────────────────────────────────────
          if (_info.displayName != null)
            Center(
              child: Text(
                _info.displayName!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),

          // ── 이메일 ──────────────────────────────────────────────
          if (_info.email != null) ...[
            const SizedBox(height: 5),
            Center(
              child: Text(
                _info.email!,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          ],

          const SizedBox(height: 36),

          // ── 개인정보 보호 ───────────────────────────────────────
          const _SectionHeader(label: '개인정보 보호'),
          _NavTile(
            label: '비공개 계정',
            onTap: () => _showComingSoon(context),
          ),
          _NavTile(
            label: '차단 목록',
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('준비 중인 기능이에요.')),
    );
  }
}

// ── Tiles ─────────────────────────────────────────────────────────

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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
