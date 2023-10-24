class UserProfile {
  final String uid;
  final String displayName;
  final String username;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'username': username,
    };
  }
}
