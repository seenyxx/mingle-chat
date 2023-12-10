import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendsService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getFriendData(String uid) {
    return _firestore.collection('friends').doc(uid).get();
  }

  Future<List<String>> getFriendsList([String? uid]) async {
    var friendData = (await getFriendData(uid ?? _firebaseAuth.currentUser!.uid)).data();

    if (friendData == null) {
      return [];
    }

    return friendData.toString().contains('friends')
        ? List<String>.from(friendData['friends'])
        : [];
    // return friendData;
  }

  Future<void> addFriend(String otherUserUid) async {
    String currentUserUid = _firebaseAuth.currentUser!.uid;
    List<String> currentFriendsList = await getFriendsList();
    List<String> currentFriendRequests = await getFriendRequests();
    List<String> otherUserFriendsList = await getFriendsList(otherUserUid);

    if (!currentFriendsList.contains(otherUserUid)) {
      currentFriendsList.add(otherUserUid);
    }

    if (!otherUserFriendsList.contains(currentUserUid)) {
      otherUserFriendsList.add(currentUserUid);
    }

    if (currentFriendRequests.contains(otherUserUid)) {
      currentFriendRequests.remove(otherUserUid);
    }

    // Update current user's friend requests list
    await _firestore
        .collection('friends')
        .doc(currentUserUid)
        .set({'friendRequests': currentFriendRequests}, SetOptions(merge: true));

    // Update current user friends list
    await _firestore
        .collection('friends')
        .doc(currentUserUid)
        .set({'friends': currentFriendsList}, SetOptions(merge: true));

    // Update other user's friends list
    await _firestore
        .collection('friends')
        .doc(otherUserUid)
        .set({'friends': otherUserFriendsList}, SetOptions(merge: true));
  }

  Future<void> removeFriend(String otherUserUid) async {
    String currentUserUid = _firebaseAuth.currentUser!.uid;
    List<String> otherUserFriendsList = await getFriendsList(otherUserUid);
    List<String> currentFriendsList = await getFriendsList();

    if (otherUserFriendsList.contains(currentUserUid)) {
      otherUserFriendsList.remove(currentUserUid);
    }

    if (currentFriendsList.contains(otherUserUid)) {
      currentFriendsList.remove(otherUserUid);
    }

    // Update current user friends list
    await _firestore
        .collection('friends')
        .doc(currentUserUid)
        .set({'friends': currentFriendsList}, SetOptions(merge: true));

    // Update other user's friends list
    await _firestore
        .collection('friends')
        .doc(otherUserUid)
        .set({'friends': otherUserFriendsList}, SetOptions(merge: true));
  }

  Future<List<String>> getFriendRequests([String? uid]) async {
    Map<String, dynamic>? friendData =
        (await getFriendData(uid ?? _firebaseAuth.currentUser!.uid)).data();

    if (friendData == null) {
      return [];
    }

    return friendData.toString().contains('friendRequests')
        ? List<String>.from(friendData['friendRequests'])
        : [];
  }

  Future<void> removeFriendRequest(String otherUserUid, [String? uid]) async {
    List<String> currentFriendRequests =
        await getFriendRequests(uid ?? _firebaseAuth.currentUser!.uid);
    if (currentFriendRequests.contains(otherUserUid)) {
      currentFriendRequests.remove(otherUserUid);
    }

    await _firestore
        .collection('friends')
        .doc(uid ?? _firebaseAuth.currentUser!.uid)
        .set({'friendRequests': currentFriendRequests}, SetOptions(merge: true));
  }

  Future<void> addFriendRequest(String otherUserUid, [String? uid]) async {
    List<String> currentFriendRequests =
        await getFriendRequests(uid ?? _firebaseAuth.currentUser!.uid);
    if (!currentFriendRequests.contains(otherUserUid)) {
      currentFriendRequests.add(otherUserUid);
    }
  }

  // Future<List<String>> getActiveChatRooms([String? uid]) async {
  //   Map<String, dynamic>? friendData =
  //       (await getFriendData(uid ?? _firebaseAuth.currentUser!.uid)).data();

  //   if (friendData == null) {
  //     return [];
  //   }

  //   return friendData.toString().contains('chatRooms') ? friendData['chatRooms'] : [];
  // }

  // Future<List<String>> addActiveChatRoom(String otherUserUid, [String? uid]) async {
  //   List<String> chatrooms =
  //       await getActiveChatRooms(uid ?? _firebaseAuth.currentUser!.uid);
  //   List<String> otherUserChatrooms = await getActiveChatRooms(otherUserUid);

  // }
}
