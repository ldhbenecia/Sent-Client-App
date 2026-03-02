import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../social/presentation/providers/friend_provider.dart';

// ════════════════════════════════════════════════════════════════
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(myProfileProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(l10n.profile),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            color: colors.textMuted,
            strokeWidth: 2,
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (profileOrNull) {
          if (profileOrNull == null) return const SizedBox.shrink();
          final profile = profileOrNull;
          return ListView(
          children: [
            const SizedBox(height: 36),

            // ── 프로필 이미지 ─────────────────────────────────────
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border, width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: profile.profileImageUrl != null
                    ? Image.network(
                        profile.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, e) => Icon(
                          Icons.person_rounded,
                          size: 44,
                          color: colors.textDisabled,
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 44,
                        color: colors.textDisabled,
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 이름 ──────────────────────────────────────────────
            Center(
              child: Text(
                profile.displayName,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),

            // ── 이메일 ────────────────────────────────────────────
            const SizedBox(height: 5),
            Center(
              child: Text(
                profile.email,
                style: TextStyle(color: colors.textMuted, fontSize: 13),
              ),
            ),

            // ── 유저코드 ──────────────────────────────────────────
            ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _UserCodeTile(userCode: profile.userCode),
              ),
            ],

            const SizedBox(height: 36),

            // ── 개인정보 보호 ─────────────────────────────────────
            _SectionHeader(label: l10n.privacy),
            _NavTile(
              label: l10n.privateAccount,
              onTap: () => _showComingSoon(context, l10n),
            ),
            _NavTile(
              label: l10n.blockedUsers,
              onTap: () => _showComingSoon(context, l10n),
            ),

            const SizedBox(height: 40),
          ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.comingSoon)),
    );
  }
}

// ── 유저코드 타일 (복사 아이콘 토글) ────────────────────────────────
class _UserCodeTile extends StatefulWidget {
  const _UserCodeTile({required this.userCode});
  final String userCode;

  @override
  State<_UserCodeTile> createState() => _UserCodeTileState();
}

class _UserCodeTileState extends State<_UserCodeTile> {
  bool _copied = false;

  Future<void> _onCopy() async {
    if (_copied) return;
    await Clipboard.setData(ClipboardData(text: widget.userCode));
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.codeCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _onCopy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myCode,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.userCode,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(_copied),
                size: 16,
                color: _copied ? colors.textPrimary : colors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tiles ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
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
    final colors = context.colors;
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
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w400)),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: colors.textDisabled, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
