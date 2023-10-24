import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/model/user_profile.dart';

class ProfileService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> setUserProfile(String username, String displayName) async {
    UserProfile userProfile = UserProfile(
      uid: _firebaseAuth.currentUser!.uid,
      username: username,
      displayName: displayName,
    );

    await _firestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .set(userProfile.toMap());
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String userId) {
    return _firestore.collection('profiles').doc(userId).get();
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot<Map<String, dynamic>> result =
        await _firestore.collection('profiles').where('username', isEqualTo: username).get();

    return result.docs.isNotEmpty;
  }
}
