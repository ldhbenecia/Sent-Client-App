class UserProfile {
  const UserProfile({
    required this.id,
    required this.provider,
    required this.email,
    required this.displayName,
    required this.userCode,
    this.profileImageUrl,
  });

  final String id;
  final String provider;
  final String email;
  final String displayName;
  final String userCode;
  final String? profileImageUrl;
}
