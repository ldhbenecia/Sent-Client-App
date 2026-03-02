import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../shared/theme/app_color_theme.dart';
import '../../domain/models/user_search_result.dart';
import '../providers/friend_provider.dart';
import 'social_tiles.dart';

enum _SearchState { idle, loading, found, notFound, error }

// ════════════════════════════════════════════════════════════════
// 친구 추가 바텀시트 — 유저코드 검색 플로우
// ════════════════════════════════════════════════════════════════
class AddFriendSheet extends StatefulWidget {
  const AddFriendSheet({super.key, required this.ref});
  final WidgetRef ref;

  @override
  State<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<AddFriendSheet> {
  final _codeController = TextEditingController();
  _SearchState _searchState = _SearchState.idle;
  UserSearchResult? _found;
  String? _errorMessage;
  bool _sending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _searchState = _SearchState.loading;
      _found = null;
      _errorMessage = null;
    });

    try {
      final result =
          await widget.ref.read(userRepositoryProvider).searchByCode(code);
      if (!mounted) return;
      setState(() {
        if (result != null) {
          _searchState = _SearchState.found;
          _found = result;
        } else {
          _searchState = _SearchState.notFound;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchState = _SearchState.error;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_found == null || _sending) return;
    setState(() => _sending = true);

    try {
      await widget.ref
          .read(friendRepositoryProvider)
          .addFriend(_found!.userCode);
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final displayName = _found!.displayName;
      // 보낸 요청 목록 갱신
      widget.ref.read(sentRequestsProvider.notifier).refresh();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.friendRequestSent(displayName))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: colors.border, width: 0.5),
          left: BorderSide(color: colors.border, width: 0.5),
          right: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 핸들 ───────────────────────────────────────────────
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── 제목 ───────────────────────────────────────────────
          Text(
            l10n.addFriend,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.addFriendSubtitle,
            style: TextStyle(color: colors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── 유저코드 입력 + 검색 ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  style: TextStyle(
                      color: colors.textPrimary, fontSize: 15),
                  keyboardType: TextInputType.visiblePassword,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: l10n.codeHint,
                    hintStyle: TextStyle(
                        color: colors.textDisabled, fontSize: 14),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: colors.textMuted.withValues(alpha: 0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _search(),
                  maxLength: 8,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed:
                      _searchState == _SearchState.loading ? null : _search,
                  style: TextButton.styleFrom(
                    backgroundColor: colors.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _searchState == _SearchState.loading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: colors.textMuted,
                          ),
                        )
                      : Text(l10n.search,
                          style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),

          // ── 결과 영역 ───────────────────────────────────────────
          if (_searchState == _SearchState.notFound) ...[
            const SizedBox(height: 14),
            Text(
              l10n.userNotFound,
              style:
                  TextStyle(color: colors.textDisabled, fontSize: 13),
            ),
          ],
          if (_searchState == _SearchState.error &&
              _errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: TextStyle(
                  color: colors.destructiveRed, fontSize: 13),
            ),
          ],
          if (_searchState == _SearchState.found && _found != null) ...[
            const SizedBox(height: 14),
            _UserCard(
              user: _found!,
              sending: _sending,
              onAdd: _sendRequest,
            ),
          ],
        ],
      ),
    );
  }
}

// ── 검색된 유저 카드 ──────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.sending,
    required this.onAdd,
  });
  final UserSearchResult user;
  final bool sending;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          SocialAvatar(imageUrl: user.profileImageUrl, name: user.displayName),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.userCode,
                  style: TextStyle(
                      color: colors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 34,
            child: TextButton(
              onPressed: sending ? null : onAdd,
              style: TextButton.styleFrom(
                backgroundColor: colors.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: sending
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: colors.textMuted),
                    )
                  : Text(l10n.request,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
