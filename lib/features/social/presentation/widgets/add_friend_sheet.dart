import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../domain/models/user_search_result.dart';
import '../providers/friend_provider.dart';
import 'social_tiles.dart';

enum _SearchState { idle, loading, found, notFound, error }

// ════════════════════════════════════════════════════════════════
// 친구 추가 바텀시트 — 이메일 검색 플로우
// ════════════════════════════════════════════════════════════════
class AddFriendSheet extends StatefulWidget {
  const AddFriendSheet({super.key, required this.ref});
  final WidgetRef ref;

  @override
  State<AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<AddFriendSheet> {
  final _emailController = TextEditingController();
  _SearchState _searchState = _SearchState.idle;
  UserSearchResult? _found;
  String? _errorMessage;
  bool _sending = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _searchState = _SearchState.loading;
      _found = null;
      _errorMessage = null;
    });

    try {
      final result =
          await widget.ref.read(userRepositoryProvider).searchByEmail(email);
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
          .addFriend(_found!.email);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_found!.displayName}님께 친구 요청을 보냈습니다.')),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
          left: BorderSide(color: AppColors.border, width: 0.5),
          right: BorderSide(color: AppColors.border, width: 0.5),
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
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── 제목 ───────────────────────────────────────────────
          const Text(
            '친구 추가',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '친구의 이메일을 입력해 검색하세요.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // ── 이메일 입력 + 검색 ──────────────────────────────────
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(
                      color: AppColors.textPrimary, fontSize: 15),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: '이메일 주소',
                    hintStyle: const TextStyle(
                        color: AppColors.textDisabled, fontSize: 14),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: AppColors.textMuted.withOpacity(0.5)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed:
                      _searchState == _SearchState.loading ? null : _search,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _searchState == _SearchState.loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.textMuted,
                          ),
                        )
                      : const Text('검색',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),

          // ── 결과 영역 ───────────────────────────────────────────
          if (_searchState == _SearchState.notFound) ...[
            const SizedBox(height: 14),
            const Text(
              '일치하는 사용자를 찾을 수 없습니다.',
              style:
                  TextStyle(color: AppColors.textDisabled, fontSize: 13),
            ),
          ],
          if (_searchState == _SearchState.error &&
              _errorMessage != null) ...[
            const SizedBox(height: 14),
            Text(
              _errorMessage!,
              style: const TextStyle(
                  color: AppColors.destructiveRed, fontSize: 13),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  user.email,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
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
                backgroundColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: sending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: AppColors.textMuted),
                    )
                  : const Text('요청',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
