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
  VoidCallback? onLedgerCategoryTap,
}) {
  showGeneralDialog(
    context: pageContext,
    barrierDismissible: false,
    barrierLabel: '',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, __) {
      final curved = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final scaleCurve = Tween<double>(begin: 0.96, end: 1.0).animate(curved);

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 배경: 바깥 탭 → 닫기
            // Builder로 위젯 트리 내부 context를 확보해야 go_router와 충돌 없이 pop 가능
            Builder(
              builder: (bCtx) => GestureDetector(
                onTap: () => Navigator.of(bCtx).pop(),
                behavior: HitTestBehavior.opaque,
                child: FadeTransition(
                  opacity: curved,
                  child: Container(
                    color: Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
            ),

            // 카드: 상단 배치 + 미세 스케일 + 페이드
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  // 카드 탭이 배경 dismiss로 전파되지 않도록 흡수
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: ScaleTransition(
                    scale: scaleCurve,
                    alignment: Alignment.topCenter,
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
                        onLedgerTap: () {
                          Navigator.of(ctx).pop();
                          pageContext.go('/ledger');
                        },
                        onPreferencesTap: () {
                          Navigator.of(ctx).pop();
                          pageContext.push('/preferences');
                        },
                        onCategoryTap: onCategoryTap != null
                            ? () {
                                Navigator.of(ctx).pop();
                                onCategoryTap();
                              }
                            : null,
                        onLedgerCategoryTap: onLedgerCategoryTap != null
                            ? () {
                                Navigator.of(ctx).pop();
                                onLedgerCategoryTap();
                              }
                            : null,
                      ),
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
    required this.onLedgerTap,
    required this.onPreferencesTap,
    this.onCategoryTap,
    this.onLedgerCategoryTap,
  });

  final VoidCallback onTodoTap;
  final VoidCallback onMemoTap;
  final VoidCallback onSocialTap;
  final VoidCallback onLedgerTap;
  final VoidCallback onPreferencesTap;
  final VoidCallback? onCategoryTap;
  final VoidCallback? onLedgerCategoryTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
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
                _NavRow(label: 'Ledger', onTap: onLedgerTap),
                _NavRow(label: 'Social', onTap: onSocialTap),
                _NavRow(label: 'Memo', onTap: onMemoTap),

                Divider(height: 0.5, color: Colors.white.withOpacity(0.10)),

                if (onCategoryTap != null)
                  _NavRow(
                    label: 'Category',
                    onTap: onCategoryTap!,
                    secondary: true,
                  ),
                if (onLedgerCategoryTap != null)
                  _NavRow(
                    label: 'Ledger Category',
                    onTap: onLedgerCategoryTap!,
                    secondary: true,
                  ),
                _NavRow(
                  label: 'Preferences',
                  onTap: onPreferencesTap,
                  secondary: true,
                ),

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
