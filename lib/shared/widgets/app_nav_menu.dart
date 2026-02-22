import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════
// showAppNavMenu — 전역 내비게이션 메뉴 다이얼로그
// ══════════════════════════════════════════════════════════════════
void showAppNavMenu(
  BuildContext pageContext, {
  VoidCallback? onCategoryTap,
  VoidCallback? onDevLogout,
}) {
  showGeneralDialog(
    context: pageContext,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 배경: 카드 밖은 살짝만 어둡게 — 뒤 콘텐츠 최대한 살리기
            FadeTransition(
              opacity: anim,
              child: Container(
                color: Colors.black.withOpacity(0.05),
              ),
            ),

            // 카드: 상단 배치
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.05),
                    end: Offset.zero,
                  ).animate(curved),
                  child: FadeTransition(
                    opacity: curved,
                    child: _AppNavMenuCard(
                      onTodoTap: () {
                        Navigator.of(ctx).pop();
                        pageContext.go('/todo');
                      },
                      onMemoTap: () {
                        Navigator.of(ctx).pop();
                        pageContext.go('/memo');
                      },
                      onSocialTap: () {
                        Navigator.of(ctx).pop();
                        pageContext.go('/social');
                      },
                      onCategoryTap: onCategoryTap != null
                          ? () {
                              Navigator.of(ctx).pop();
                              onCategoryTap();
                            }
                          : null,
                      onDevLogout: onDevLogout != null
                          ? () {
                              Navigator.of(ctx).pop();
                              onDevLogout();
                            }
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ══════════════════════════════════════════════════════════════════
// 내비게이션 메뉴 카드 (리퀴드 글래스)
// ══════════════════════════════════════════════════════════════════
class _AppNavMenuCard extends StatelessWidget {
  const _AppNavMenuCard({
    required this.onTodoTap,
    required this.onMemoTap,
    required this.onSocialTap,
    this.onCategoryTap,
    this.onDevLogout,
  });

  final VoidCallback onTodoTap;
  final VoidCallback onMemoTap;
  final VoidCallback onSocialTap;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onDevLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          // 적당한 blur — 뒤 콘텐츠 형태가 보이면서 frosted glass 느낌
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              // 탑→바텀 그라디언트: 상단 빛 반사 (specular) + 하단 더 투명
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.07),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 14, 14),
                  child: Row(
                    children: [
                      Text(
                        'SENT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.40),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.20),
                              width: 0.5,
                            ),
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 13,
                              color: Colors.white.withOpacity(0.55)),
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 0.5, color: Colors.white.withOpacity(0.10)),

                // 섹션 이동
                _NavRow(label: 'Todo', onTap: onTodoTap),
                _NavRow(label: 'Memo', onTap: onMemoTap),
                _NavRow(label: 'Social', onTap: onSocialTap),

                Divider(height: 0.5, color: Colors.white.withOpacity(0.10)),

                if (onCategoryTap != null)
                  _NavRow(
                    label: 'Category',
                    onTap: onCategoryTap!,
                    secondary: true,
                  ),
                _NavRow(
                  label: 'Preferences',
                  onTap: () => Navigator.of(context).pop(),
                  secondary: true,
                ),

                if (onDevLogout != null) ...[
                  Divider(height: 0.5, color: Colors.white.withOpacity(0.10)),
                  _NavRow(
                    label: 'DEV Logout',
                    onTap: onDevLogout!,
                    color: AppColors.destructiveRed.withOpacity(0.80),
                    secondary: true,
                  ),
                ],

                const SizedBox(height: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.onTap,
    this.color,
    this.secondary = false,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool secondary;

  @override
  Widget build(BuildContext context) {
    final textColor = color ??
        (secondary
            ? Colors.white.withOpacity(0.50)
            : Colors.white.withOpacity(0.92));
    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withOpacity(0.06),
      highlightColor: Colors.white.withOpacity(0.04),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 22,
          vertical: secondary ? 11.0 : 15.0,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: secondary ? 19.0 : 30.0,
            fontWeight: FontWeight.w300,
            letterSpacing: -0.3,
          ),
        ),
      ),
    );
  }
}
