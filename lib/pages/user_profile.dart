import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minglechat/components/green_button.dart';
import 'package:minglechat/components/user_profile_text_field.dart';
import 'package:minglechat/services/accounts/profile_service.dart';
import 'package:shimmer/shimmer.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final displayNameController = TextEditingController();
  final usernameController = TextEditingController();
  final scrollController = ScrollController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  static const Color _skeletonColor = Color(0xFF21212F);
  static const Color _shimmerColor = Color(0xFF343449);

  late String initialUsername;
  late String initialDisplayName;

  Uint8List? avatarImage;

  Future<Uint8List?> pickAvatarImageFile() async {
    // TODO: IOS functionality has not been implemented yet because I have not added the stuff required for image picker to work into the plist file
    // TODO: Implement image picker and firebase cloud storage
    final ImagePicker imagePicker = ImagePicker();
    final XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return await image.readAsBytes();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Profile'),
          leading: IconButton(
            highlightColor: Colors.transparent,
            splashRadius: 20,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: SafeArea(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 64,
                        backgroundImage: avatarImage != null
                            ? MemoryImage(avatarImage!)
                            : _defaultAvatar(),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: const Color(0xAA21212F),
                            child: IconButton(
                              onPressed: () async {
                                // Pick image when button is clicked and then state is updated to rebuild the avatar
                                Uint8List? img = await pickAvatarImageFile();
                                setState(() {
                                  avatarImage = img;
                                });
                              },
                              icon: const Icon(Icons.edit),
                              splashRadius: 18,
                              color: Colors.white,
                            ),
                          ))
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FutureBuilder(
                      future:
                          _profileService.getUserProfile(_firebaseAuth.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error = ${snapshot.error}');
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // if (true) {
                          return Column(children: [
                            const SizedBox(height: 22),
                            _buildInputSkeleton(),
                            const SizedBox(height: 53),
                            _buildInputSkeleton(),
                            const SizedBox(height: 30),
                            _buildInputSkeleton(),
                          ]);
                        }

                        Map<String, dynamic> data = snapshot.data!.data()!;

                        return Column(
                          children: [
                            _buildSubtitles('Username'),
                            const SizedBox(height: 5),
                            UserProfileTextField(
                                onStart: () {
                                  initialUsername = usernameController.text;
                                },
                                prefixText: '@',
                                hintText: 'Username',
                                initialValue: data['username'],
                                controller: usernameController),
                            const SizedBox(height: 30),
                            _buildSubtitles('Display Name'),
                            const SizedBox(height: 5),
                            UserProfileTextField(
                                onStart: () {
                                  initialDisplayName = displayNameController.text;
                                },
                                hintText: 'Display Name',
                                initialValue: data['displayName'],
                                controller: displayNameController),
                            const SizedBox(height: 30),
                            GreenButton(
                                onTap: () async {
                                  if (await _profileService
                                          .isUsernameTaken(usernameController.text) &&
                                      context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Username is already taken')));
                                    return;
                                  }

                                  if (initialUsername == usernameController.text &&
                                      initialDisplayName == displayNameController.text) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('No changes detected')));
                                    return;
                                  }

                                  initialDisplayName = displayNameController.text;
                                  initialUsername = usernameController.text;

                                  _profileService.updateUserProfile(
                                      usernameController.text,
                                      displayNameController.text);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Profile updated!')));
                                  }
                                },
                                text: 'Save Changes')
                          ],
                        );
                      })
                ],
              ),
            ),
          )),
        ));
  }

  Widget _buildSubtitles(String text) {
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF6C6C6C),
                fontSize: 12,
              ),
            )));
  }

  Widget _buildInputSkeleton() {
    return Shimmer.fromColors(
      baseColor: _skeletonColor,
      highlightColor: _shimmerColor,
      period: const Duration(milliseconds: 800),
      child: const SizedBox(
        height: 60,
        width: 400,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _skeletonColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _defaultAvatar() {
    return const NetworkImage(
        'https://static.vecteezy.com/system/resources/thumbnails/009/292/244/small/default-avatar-icon-of-social-media-user-vector.jpg');
  }
}
