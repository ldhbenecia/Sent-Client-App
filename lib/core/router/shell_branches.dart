import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/ledger/domain/models/ledger_category.dart';
import '../../features/ledger/domain/models/ledger_entry.dart';
import '../../features/ledger/presentation/pages/ledger_category_edit_page.dart';
import '../../features/ledger/presentation/pages/ledger_category_page.dart';
import '../../features/ledger/presentation/pages/ledger_entry_edit_page.dart';
import '../../features/ledger/presentation/pages/ledger_page.dart';
import '../../features/memo/domain/models/memo_category.dart';
import '../../features/memo/domain/models/memo_item.dart';
import '../../features/memo/presentation/pages/memo_category_edit_page.dart';
import '../../features/memo/presentation/pages/memo_category_page.dart';
import '../../features/memo/presentation/pages/memo_edit_page.dart';
import '../../features/memo/presentation/pages/memo_page.dart';
import '../../features/social/presentation/pages/chat_page.dart';
import '../../features/social/presentation/pages/chat_list_page.dart';
import '../../features/social/presentation/pages/friend_requests_page.dart';
import '../../features/social/presentation/pages/social_page.dart';
import '../../features/todo/domain/models/todo_category.dart';
import '../../features/todo/domain/models/todo_item.dart';
import '../../features/todo/presentation/pages/category_edit_page.dart';
import '../../features/todo/presentation/pages/category_page.dart';
import '../../features/todo/presentation/pages/todo_edit_page.dart';
import '../../features/todo/presentation/pages/todo_page.dart';
import 'route_transitions.dart';

List<StatefulShellBranch> buildMainShellBranches() {
  return [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/todo',
          name: 'todo',
          builder: (context, state) => const TodoPage(),
          routes: [
            GoRoute(
              path: 'categories',
              name: 'categories',
              builder: (context, state) => const CategoryPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'category-create',
                  builder: (context, state) =>
                      const CategoryEditPage(category: null),
                ),
                GoRoute(
                  path: ':id/edit',
                  name: 'category-edit',
                  builder: (context, state) =>
                      CategoryEditPage(category: state.extra as TodoCategory?),
                ),
              ],
            ),
            GoRoute(
              path: 'new',
              name: 'todo-create',
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return CustomTransitionPage(
                  child: TodoEditPage(
                    initialDate: extra?['date'] as DateTime?,
                    initialCategoryId: extra?['categoryId'] as String?,
                  ),
                  transitionsBuilder: (context, animation, secondary, child) =>
                      slideUpFadeTransition(animation, child),
                );
              },
            ),
            GoRoute(
              path: ':id/edit',
              name: 'todo-edit',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: TodoEditPage(todo: state.extra as TodoItem?),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideUpFadeTransition(animation, child),
              ),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/ledger',
          name: 'ledger',
          builder: (context, state) => const LedgerPage(),
          routes: [
            GoRoute(
              path: 'categories',
              name: 'ledger-categories',
              builder: (context, state) => const LedgerCategoryPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'ledger-category-create',
                  builder: (context, state) =>
                      const LedgerCategoryEditPage(category: null),
                ),
                GoRoute(
                  path: ':id/edit',
                  name: 'ledger-category-edit',
                  builder: (context, state) => LedgerCategoryEditPage(
                    category: state.extra as LedgerCategory?,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'new',
              name: 'ledger-create',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const LedgerEntryEditPage(),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideUpFadeTransition(animation, child),
              ),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'ledger-edit',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: LedgerEntryEditPage(entry: state.extra as LedgerEntry?),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideUpFadeTransition(animation, child),
              ),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/social',
          name: 'social',
          builder: (context, state) => const SocialPage(),
          routes: [
            GoRoute(
              path: 'requests',
              name: 'social-requests',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const FriendRequestsPage(),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideRightFadeTransition(animation, child),
              ),
            ),
            GoRoute(
              path: 'chats',
              name: 'social-chats',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const ChatListPage(),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideRightFadeTransition(animation, child),
              ),
            ),
            GoRoute(
              path: 'chat',
              name: 'social-chat',
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>;
                return CustomTransitionPage(
                  child: ChatPage(
                    opponentId: extra['opponentId'] as String,
                    friendName: extra['friendName'] as String,
                    opponentProfileImageUrl:
                        extra['opponentProfileImageUrl'] as String?,
                  ),
                  transitionsBuilder: (context, animation, secondary, child) =>
                      slideRightFadeTransition(animation, child),
                );
              },
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: '/memo',
          name: 'memo',
          builder: (context, state) => const MemoPage(),
          routes: [
            GoRoute(
              path: 'categories',
              name: 'memo-categories',
              builder: (context, state) => const MemoCategoryPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  name: 'memo-category-create',
                  builder: (context, state) =>
                      const MemoCategoryEditPage(category: null),
                ),
                GoRoute(
                  path: ':id/edit',
                  name: 'memo-category-edit',
                  builder: (context, state) => MemoCategoryEditPage(
                    category: state.extra as MemoCategory?,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: 'new',
              name: 'memo-create',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: const MemoEditPage(),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideUpFadeTransition(animation, child),
              ),
            ),
            GoRoute(
              path: ':id/edit',
              name: 'memo-edit',
              pageBuilder: (context, state) => CustomTransitionPage(
                child: MemoEditPage(memo: state.extra as MemoItem?),
                transitionsBuilder: (context, animation, secondary, child) =>
                    slideUpFadeTransition(animation, child),
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
