class UserProfile {
  final String uid;
  final String displayName;
  final String username;
  final List<String> friends;
  final List<String> friendRequests;
  final List<String> chatRooms;

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.friends,
    required this.friendRequests,
    required this.chatRooms,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'username': username,
      'friends': friends,
      'friendRequests': friendRequests,
      'chatRooms': chatRooms,
    };
  }
}