class UserProfile {
  final String uid;
  final String displayName;
  final String username;
  String? avatarUrl;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    if (avatarUrl != null) {
      return {
        'uid': uid,
        'displayName': displayName,
        'username': username,
        'avatarUrl': avatarUrl
      };
    } else {
      return {
        'uid': uid,
        'displayName': displayName,
        'username': username,
      };
    }
  }
}
