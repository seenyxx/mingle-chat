import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/components/dm_skeleton.dart';
import 'package:minglechat/pages/chat_page.dart';
import 'package:minglechat/pages/friends_page.dart';
import 'package:minglechat/pages/user_profile.dart';
import 'package:minglechat/services/accounts/profile_service.dart';
import 'package:minglechat/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfileService _profileService = ProfileService();

  // Sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FutureBuilder(
                  future: _profileService.getProfileAvatarUrl(_auth.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey,
                      );
                    }

                    if (snapshot.data == null) {
                      return const Text('No Image found');
                    }

                    return CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(snapshot.data!),
                    );
                  })),
          const Text(
            'Messages',
            style: TextStyle(fontSize: 24),
          ),
        ]),
        actions: [
          // Friends list
          IconButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const FriendsPage()));
            },
            icon: const Icon(Icons.people_alt_rounded),
            splashRadius: 18,
          ),
          // User settings
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()));
            },
            icon: const Icon(Icons.account_circle_rounded),
            splashRadius: 18,
          ),
          // Sign out
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout_rounded),
            splashRadius: 18,
          )
        ],
      ),
      body: _buildUserList(),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        separatorBuilder: (context, index) => const SizedBox(
              height: 30,
            ),
        itemCount: 5,
        itemBuilder: (context, index) => const DirectMessagesSkeleton());
  }

  // Build list of users
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Skeleton loader
          return _buildSkeletonLoader();
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) => _buildUserListItem(snapshot.data!.docs[index]),
          separatorBuilder: (context, index) => const SizedBox(height: 30),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    if (_auth.currentUser!.email != data['email']) {
      return ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: const CircleAvatar(radius: 25, backgroundColor: Colors.grey),
        title: Text(data['email']),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                        receiverUserEmail: data['email'],
                        receiverUserID: data['uid'],
                      )));
        },
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
