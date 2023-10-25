class FriendsList {
  // List of friended user uids
  final List<String> friends;
  // List of friend requests
  final List<String> friendRequests;
  // List of active chat rooms
  final List<String> activeChatrooms;

  FriendsList({
    required this.activeChatrooms,
    required this.friends,
    required this.friendRequests,
  });

  Map<String, dynamic> toMap() {
    return {
      'friends': friends,
      'friendRequests': friendRequests,
      'activeChatrooms': activeChatrooms,
    };
  }
}
