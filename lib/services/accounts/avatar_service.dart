import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AvatarService extends ChangeNotifier {
  final storageRef = FirebaseStorage.instance.ref();

  Future<String> uploadImageToStorage(String uid, Uint8List fileData) async {
    // Uploads Uint8 image array and returns download URL
    UploadTask uploadTask = storageRef.child('avatars/$uid').putData(fileData);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImageFromStorage(String uid) async {
    await storageRef.child('avatars/$uid').delete();
  }
}
