import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/models/user_profile.dart';

class ProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> updateUserProfile(String username, String displayName) async {
    UserProfile userProfile = UserProfile(
      uid: _firebaseAuth.currentUser!.uid,
      username: username,
      displayName: displayName,
    );

    await _firestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .set(userProfile.toMap(), SetOptions(merge: true));
  }

  // TODO: Implement avatar url upload into database and retrieval from database

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String userId) {
    return _firestore.collection('profiles').doc(userId).get();
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('profiles')
        .where('username', isEqualTo: username)
        .get();

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
