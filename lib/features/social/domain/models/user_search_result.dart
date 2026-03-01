class UserSearchResult {
  const UserSearchResult({
    required this.userCode,
    required this.displayName,
    this.profileImageUrl,
  });

  final String userCode;
  final String displayName;
  final String? profileImageUrl;
}
