import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../auth/data/repositories/auth_repository.dart';

/// JWT payload 디코딩 → sub 클레임(UUID) 추출
String? _extractUuidFromToken(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    // base64url → base64 패딩 보정
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

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '로그아웃',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        content: const Text(
          '로그아웃 하시겠어요?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('취소', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('로그아웃',
                style: TextStyle(color: AppColors.destructiveRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

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
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<String?>(
        future: ref.read(tokenStorageProvider).getAccessToken(),
        builder: (context, snapshot) {
          final uuid = snapshot.hasData && snapshot.data != null
              ? _extractUuidFromToken(snapshot.data!)
              : null;

          return ListView(
            children: [
              const SizedBox(height: 16),

              // 내 ID 섹션
              _SectionHeader(label: '내 ID'),
              _MyIdTile(uuid: uuid),

              const SizedBox(height: 32),

              // 계정 섹션
              _SectionHeader(label: '계정'),
              _SettingsTile(
                label: '로그아웃',
                color: AppColors.destructiveRed,
                onTap: () => _logout(context, ref),
              ),

              const SizedBox(height: 32),

              // 앱 정보
              _SectionHeader(label: '앱 정보'),
              const _SettingsInfoTile(label: '버전', value: '1.0.0'),
            ],
          );
        },
      ),
    );
  }
}

// ── 내 ID 타일 (복사 버튼 포함) ────────────────────────────────────
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
                        ? AppColors.textPrimary
                        : AppColors.textDisabled,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
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
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsInfoTile extends StatelessWidget {
  const _SettingsInfoTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 16)),
          Text(value,
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}
