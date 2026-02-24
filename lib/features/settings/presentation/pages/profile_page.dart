import 'package:flutter/material.dart';
import '../../../../shared/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          const SizedBox(height: 32),

          // ── 프로필 이미지 ───────────────────────────────────────
          Center(
            child: Stack(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 44,
                    color: AppColors.textDisabled,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => _showComingSoon(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── 프로필 설정 항목 ────────────────────────────────────
          const _SectionHeader(label: '프로필 정보'),
          _NavTile(
            label: '이름 변경',
            detail: '준비 중',
            onTap: () => _showComingSoon(context),
          ),
          _NavTile(
            label: '프로필 사진 변경',
            detail: '준비 중',
            onTap: () => _showComingSoon(context),
          ),

          const SizedBox(height: 28),

          // ── 개인정보 보호 ───────────────────────────────────────
          const _SectionHeader(label: '개인정보 보호'),
          _NavTile(
            label: '비공개 계정',
            detail: '준비 중',
            onTap: () => _showComingSoon(context),
          ),
          _NavTile(
            label: '차단 목록',
            detail: '준비 중',
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
  const _NavTile({
    required this.label,
    required this.onTap,
    this.detail,
  });
  final String label;
  final VoidCallback onTap;
  final String? detail;

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
                if (detail != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(detail!,
                        style: const TextStyle(
                            color: AppColors.textDisabled, fontSize: 13)),
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
