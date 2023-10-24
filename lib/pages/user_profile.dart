import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/components/user_profile_text_field.dart';
import 'package:minglechat/services/chat/profile_service.dart';
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
                  const CircleAvatar(
                    radius: 60,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  FutureBuilder(
                      future: _profileService.getUserProfile(_firebaseAuth.currentUser!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return Text('Error = ${snapshot.error}');
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // if (true) {
                          return Column(children: [
                            const SizedBox(height: 22),
                            _buildInputSkeleton(),
                            const SizedBox(height: 22),
                            _buildInputSkeleton(),
                          ]);
                        }

                        Map<String, dynamic> data = snapshot.data!.data()!;

                        return Column(
                          children: [
                            _buildSubtitles('Username'),
                            const SizedBox(
                              height: 5,
                            ),
                            UserProfileTextField(
                                hintText: 'Username',
                                initialValue: data['username'],
                                controller: usernameController),
                            const SizedBox(
                              height: 30,
                            ),
                            _buildSubtitles('Display Name'),
                            const SizedBox(
                              height: 5,
                            ),
                            UserProfileTextField(
                                hintText: 'Display Name',
                                initialValue: data['displayName'],
                                controller: displayNameController),
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
}
