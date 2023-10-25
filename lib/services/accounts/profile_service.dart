import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/models/user_profile.dart';

String _defaultAvatarUrl =
    'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg';

class ProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserProfile(
    String username,
    String displayName, [
    String? uid,
  ]) async {
    UserProfile userProfile = UserProfile(
      uid: uid ?? _firebaseAuth.currentUser!.uid,
      username: username,
      displayName: displayName,
    );

    await _firestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .set(userProfile.toMap(), SetOptions(merge: true));
  }

  // TODO: Implement avatar url upload into database and retrieval from database

  Future<void> updateProfileAvatarUrL(String avatarUrl) async {
    await _firestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .set({'avatarUrl': avatarUrl}, SetOptions(merge: true));
  }

  Future<String> getProfileAvatarUrl(String uid) async {
    Map<String, dynamic>? userProfile = (await getUserProfile(uid)).data();

    if (userProfile == null) {
      return _defaultAvatarUrl;
    }

    return userProfile['avatarUrl'] ?? _defaultAvatarUrl;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String userId) {
    return _firestore.collection('profiles').doc(userId).get();
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('profiles')
        .where('username', isEqualTo: username)
        .get();

    if (_firebaseAuth.currentUser == null) {
      return result.docs.isNotEmpty;
    }

    // The following conditional statements below skip the need for the use of another firestore query (optimisation)

    // Return false is there is no profile with the username
    if (result.docs.isEmpty) {
      return false;
    }

    // Return false if the profile with the username is the current user's profile
    if (result.docs.first.id == _firebaseAuth.currentUser!.uid) {
      return false;
    }
    // Otherwise return true
    return true;
  }
}
