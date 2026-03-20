import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/theme/app_color_theme.dart';
import '../../../../shared/utils/haptics.dart';
import '../../../../shared/utils/layout.dart';
import '../../../../shared/widgets/app_nav_menu.dart';
import '../providers/memo_provider.dart';
import '../widgets/memo_tile.dart';

class MemoPage extends ConsumerWidget {
  const MemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final memosAsync = ref.watch(memoItemsProvider);
    final navBarHeight = navBarReservedHeight(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/home'),
          child: const Text('SENT'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: colors.textMuted, size: 22),
            onPressed: () {
              Haptics.medium();
              context.push('/memo/new');
            },
          ),
          IconButton(
            icon: Icon(Icons.folder_outlined, color: colors.textMuted, size: 22),
            onPressed: () => context.push('/memo/categories'),
          ),
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
        onRefresh: () => ref.refresh(memoItemsProvider.future),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ...memosAsync.when(
              loading: () => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: navBarHeight),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: navBarHeight),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: colors.textDisabled, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            e.toString().replaceAll('Exception: ', ''),
                            style: TextStyle(
                                color: colors.textMuted, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => ref.invalidate(memoItemsProvider),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              data: (memos) {
                if (memos.isEmpty) {
                  return [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      // nav bar 높이만큼 bottom padding → Center가 시각적으로 정중앙에 위치
                      child: Padding(
                        padding: EdgeInsets.only(bottom: navBarHeight),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_note_rounded,
                                  size: 52, color: colors.textDisabled),
                              const SizedBox(height: 16),
                              Text(
                                l10n.memoEmptyTitle,
                                style: TextStyle(
                                  color: colors.textMuted,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.memoEmptySubtitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colors.textDisabled,
                                  fontSize: 13,
                                  letterSpacing: -0.1,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                }
                return [
                  SliverList.separated(
                    itemCount: memos.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 0.5, color: colors.border, indent: 16),
                    itemBuilder: (context, index) {
                      final memo = memos[index];
                      return MemoTile(
                        item: memo,
                        onTap: () => context.push(
                          '/memo/${memo.id}/edit',
                          extra: memo,
                        ),
                      );
                    },
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(bottom: navBarHeight + 24),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
