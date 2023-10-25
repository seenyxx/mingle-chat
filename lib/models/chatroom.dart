import 'package:cloud_firestore/cloud_firestore.dart';

class Chatroom {
  final Timestamp lastMessageTimestamp;
  final int unreadMessages;

  Chatroom({
    required this.lastMessageTimestamp,
    required this.unreadMessages,
  });

  Map<String, dynamic> toMap() {
    return {
      'unreadMessages': unreadMessages,
      'lastMessageTimestamp': lastMessageTimestamp,
    };
  }
}
