class UserSearchResult {
  const UserSearchResult({
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  final String email;
  final String displayName;
  final String? profileImageUrl;
}
