import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send message

  Future<void> sendMessage(String receiverId, String message) async {
    // Get user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    final String msgUid = [timestamp.millisecondsSinceEpoch.toString(), receiverId, currentUserId].join('_');

    Message newMessage = Message(
      uid: msgUid,
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      timestamp: timestamp,
      message: message,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Add message to firestore
    await _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .doc(newMessage.uid)
      .set(newMessage.toMap());
  }

  // Retrieve messages
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }
}