class UserSearchResult {
  const UserSearchResult({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  final int id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
}
