import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/utils/haptics.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../../../ledger/domain/models/ledger_summary.dart';
import '../../domain/models/todo_statistics.dart';
import '../providers/home_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final month = ref.watch(homeMonthProvider);
    final todoAsync = ref.watch(homeTodoStatisticsProvider);
    final ledgerAsync = ref.watch(homeLedgerSummaryProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('SENT'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: colors.textMuted, size: 22),
            onPressed: () => showAppNavMenu(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: colors.textPrimary,
        backgroundColor: colors.card,
        onRefresh: () async {
          ref.invalidate(homeTodoStatisticsProvider);
          ref.invalidate(homeLedgerSummaryProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── 월 네비게이션 ──────────────────────────────────────
            SliverToBoxAdapter(
              child: _MonthNavigator(
                month: month,
                onPrev: () {
                  Haptics.light();
                  final prev = DateTime(month.year, month.month - 1);
                  ref.read(homeMonthProvider.notifier).state =
                      (year: prev.year, month: prev.month);
                },
                onNext: () {
                  Haptics.light();
                  final next = DateTime(month.year, month.month + 1);
                  ref.read(homeMonthProvider.notifier).state =
                      (year: next.year, month: next.month);
                },
              ),
            ),

            // ── Todo 통계 카드 ─────────────────────────────────────
            SliverToBoxAdapter(
              child: todoAsync.when(
                data: (stats) => _TodoStatsCard(stats: stats),
                loading: () => _TodoStatsCard(
                    stats: TodoStatistics.empty(month.year, month.month)),
                error: (e, _) => _TodoStatsCard(
                    stats: TodoStatistics.empty(month.year, month.month)),
              ),
            ),

            // ── 가계부 요약 카드 ───────────────────────────────────
            SliverToBoxAdapter(
              child: ledgerAsync.when(
                data: (summary) => _LedgerCard(summary: summary),
                loading: () => _LedgerCard(summary: LedgerSummary.empty()),
                error: (e, _) =>
                    _LedgerCard(summary: LedgerSummary.empty()),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }
}

// ── 월 네비게이션 ─────────────────────────────────────────────────
class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  final ({int year, int month}) month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: Icon(Icons.chevron_left_rounded, color: colors.textMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '${month.year}.${month.month.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: Icon(Icons.chevron_right_rounded, color: colors.textMuted),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ── 글래스 카드 래퍼 (누름 시 스케일 + 밝기만 변화) ─────────────────
class _GlassCard extends StatefulWidget {
  const _GlassCard({
    required this.child,
    this.onTap,
  });

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _tAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnim = Tween(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _tAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _down(_) => _ctrl.forward();
  void _cancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTapDown: _down,
      onTap: () {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: _cancel,
      onLongPressStart: _down,
      onLongPressEnd: (_) => _ctrl.reverse(),
      onLongPressCancel: _cancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _tAnim.value;
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      const Color(0xFF1C1C1E),
                      const Color(0xFF242426),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF0F0F0F),
                      const Color(0xFF181818),
                      t,
                    )!,
                  ],
                ),
                border: Border.all(color: colors.border, width: 0.5),
              ),
              child: Stack(
                children: [
                  // 상단 얇은 하이라이트 (빛 반사)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.06),
                            Colors.white.withValues(alpha: 0.01),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: child,
                  ),
                ],
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

// ── Todo 통계 카드 ────────────────────────────────────────────────
class _TodoStatsCard extends ConsumerStatefulWidget {
  const _TodoStatsCard({required this.stats});

  final TodoStatistics stats;

  @override
  ConsumerState<_TodoStatsCard> createState() => _TodoStatsCardState();
}

class _TodoStatsCardState extends ConsumerState<_TodoStatsCard>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rateAnim;
  late Animation<double> _countAnim;

  double? _pendingFromRate;
  double? _pendingFromCount;

  double get _targetRate =>
      widget.stats.totalCount > 0 ? widget.stats.completionRate / 100.0 : 0.0;
  double get _targetCount => widget.stats.completedCount.toDouble();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _rateAnim = Tween(begin: 0.0, end: _targetRate)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _countAnim = Tween(begin: 0.0, end: _targetCount)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_TodoStatsCard old) {
    super.didUpdateWidget(old);
    if (old.stats.completionRate != widget.stats.completionRate ||
        old.stats.completedCount != widget.stats.completedCount) {
      // 홈 탭(0)이 활성이면 즉시 애니메이션, 아니면 복귀 시까지 대기
      if (ref.read(currentBranchIndexProvider) == 0) {
        _startAnimation(
            fromRate: _rateAnim.value, fromCount: _countAnim.value);
      } else {
        _pendingFromRate = _rateAnim.value;
        _pendingFromCount = _countAnim.value;
      }
    }
  }

  void _startAnimation({required double fromRate, required double fromCount}) {
    setState(() {
      _rateAnim = Tween(begin: fromRate, end: _targetRate)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _countAnim = Tween(begin: fromCount, end: _targetCount)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    });
    _ctrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // 홈 탭으로 복귀할 때 대기 중인 애니메이션 실행
    ref.listen(currentBranchIndexProvider, (_, next) {
      if (next == 0 && _pendingFromRate != null) {
        final fromRate = _pendingFromRate!;
        final fromCount = _pendingFromCount!;
        _pendingFromRate = null;
        _pendingFromCount = null;
        _startAnimation(fromRate: fromRate, fromCount: fromCount);
      }
    });

    return _GlassCard(
      onTap: () => context.go('/todo'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          AnimatedBuilder(
            animation: _countAnim,
            builder: (context, _) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.homeTodo,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${_countAnim.value.round()} / ${widget.stats.totalCount}',
                      style:
                          TextStyle(color: colors.textDisabled, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded,
                        color: colors.textDisabled, size: 14),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Arc 게이지 (양방향 애니메이션)
          AnimatedBuilder(
            animation: _rateAnim,
            builder: (context, _) => Center(
              child: SizedBox(
                width: 160,
                height: 90,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _ArcGaugePainter(
                        rate: _rateAnim.value,
                        baseColor: colors.secondary,
                        fillColor: const Color(0xFF32D74B),
                      ),
                      size: const Size(160, 90),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 0,
                      right: 0,
                      child: Text(
                        '${(_rateAnim.value * 100).toStringAsFixed(0)}%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 카테고리 분류
          if (widget.stats.categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: 20),
            ...widget.stats.categoryBreakdown
                .take(4)
                .map((cat) => _CategoryBar(cat: cat)),
          ] else if (widget.stats.totalCount == 0) ...[
            const SizedBox(height: 12),
            Center(
              child: Text(
                l10n.homeNoTasks,
                style: TextStyle(color: colors.textDisabled, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Arc 게이지 CustomPainter ──────────────────────────────────────
class _ArcGaugePainter extends CustomPainter {
  const _ArcGaugePainter({
    required this.rate,
    required this.baseColor,
    required this.fillColor,
  });

  final double rate;
  final Color baseColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = pi;
    const sweepAngle = pi;

    final bgPaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    if (rate > 0) {
      final fgPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * rate.clamp(0.0, 1.0),
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter old) =>
      old.rate != rate || old.fillColor != fillColor;
}

// ── 카테고리 진행 막대 ─────────────────────────────────────────────
class _CategoryBar extends ConsumerStatefulWidget {
  const _CategoryBar({required this.cat});

  final CategoryStatistic cat;

  @override
  ConsumerState<_CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends ConsumerState<_CategoryBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rateAnim;

  double? _pendingFromRate;

  double get _targetRate => widget.cat.totalCount > 0
      ? widget.cat.completedCount / widget.cat.totalCount
      : 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _rateAnim = Tween(begin: 0.0, end: _targetRate)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_CategoryBar old) {
    super.didUpdateWidget(old);
    if (old.cat.completedCount != widget.cat.completedCount ||
        old.cat.totalCount != widget.cat.totalCount) {
      if (ref.read(currentBranchIndexProvider) == 0) {
        _startAnimation(fromRate: _rateAnim.value);
      } else {
        _pendingFromRate = _rateAnim.value;
      }
    }
  }

  void _startAnimation({required double fromRate}) {
    setState(() {
      _rateAnim = Tween(begin: fromRate, end: _targetRate)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    });
    _ctrl.forward(from: 0.0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = widget.cat.categoryName ?? '기타';

    ref.listen(currentBranchIndexProvider, (_, next) {
      if (next == 0 && _pendingFromRate != null) {
        final fromRate = _pendingFromRate!;
        _pendingFromRate = null;
        _startAnimation(fromRate: fromRate);
      }
    });

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              Text(
                '${widget.cat.completedCount}/${widget.cat.totalCount}',
                style: TextStyle(color: colors.textDisabled, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 5),
          AnimatedBuilder(
            animation: _rateAnim,
            builder: (context, _) => ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _rateAnim.value,
                backgroundColor: colors.secondary,
                valueColor:
                    const AlwaysStoppedAnimation(Color(0xFF32D74B)),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 가계부 요약 카드 ──────────────────────────────────────────────
class _LedgerCard extends StatelessWidget {
  const _LedgerCard({required this.summary});

  final LedgerSummary summary;

  static String _fmt(int n, String sym) {
    final abs = n.abs();
    final s = abs
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '${n < 0 ? '-' : ''}$s$sym';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final sym = l10n.currencySymbol;
    final total = summary.totalIncome + summary.totalExpense;

    return _GlassCard(
      onTap: () => context.go('/ledger'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.homeLedger,
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${summary.netAmount >= 0 ? '+' : ''}${_fmt(summary.netAmount, sym)}',
                    style: TextStyle(
                      color: summary.netAmount >= 0
                          ? const Color(0xFF32D74B)
                          : const Color(0xFFFF6467),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textDisabled, size: 14),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _LedgerRow(
            label: l10n.income,
            amount: summary.totalIncome,
            total: total,
            color: const Color(0xFF32D74B),
            symbol: sym,
          ),
          const SizedBox(height: 10),
          _LedgerRow(
            label: l10n.expense,
            amount: summary.totalExpense,
            total: total,
            color: const Color(0xFFFF6467),
            symbol: sym,
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
    required this.symbol,
  });

  final String label;
  final int amount;
  final int total;
  final Color color;
  final String symbol;

  static String _fmt(int n, String sym) {
    final s = n
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
    return '$s$sym';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rate = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
            Text(
              _fmt(amount, symbol),
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: colors.secondary,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
