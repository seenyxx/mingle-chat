import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/components/avatar_skeleton.dart';
import 'package:minglechat/components/dm_skeleton.dart';
import 'package:minglechat/pages/chat_page.dart';
import 'package:minglechat/pages/friends_page.dart';
import 'package:minglechat/pages/user_profile.dart';
import 'package:minglechat/services/accounts/friends_serivce.dart';
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
  final FriendsService _friendsService = FriendsService();
  static const Color _skeletonColor = Color(0xFF21212F);

  // Sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _profileService.dispose();
    super.dispose();
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
                      return const AvatarSkeleton(radius: 20);
                    }

                    return CircleAvatar(
                      radius: 20,
                      backgroundColor: _skeletonColor,
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
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FriendsPage(),
                          maintainState: false))
                  .then((_) => setState(() {}));
              ;
            },
            icon: const Icon(Icons.people_alt_rounded),
            splashRadius: 18,
          ),
          // User settings
          IconButton(
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const UserProfilePage()))
                  .then((_) => setState(() {}));
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
    return FutureBuilder<List<String>>(
      future: _friendsService.getFriendsList(),
      builder: (context, friends) {
        if (friends.hasError) {
          return const Text('Error');
        }

        if (friends.connectionState == ConnectionState.waiting) {
          // Skeleton loader
          return _buildSkeletonLoader();
        }

        if (friends.data!.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.speaker_notes_off_rounded,
                  size: 30.0, color: Colors.white),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'No chatrooms',
                style: TextStyle(fontSize: 22),
              ),
              Text('Add some friends to get started',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16))
            ],
          ));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: friends.data!.length,
          itemBuilder: (context, index) => _buildUserListItem(friends.data![index]),
          separatorBuilder: (context, index) => const SizedBox(height: 30),
        );
      },
    );
  }

  Widget _buildUserListItem(String uid) {
    return FutureBuilder(
        future: _profileService.getUserProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DirectMessagesSkeleton();
          }

          Map<String, dynamic> profile = snapshot.data!.data() as Map<String, dynamic>;

          return ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: FutureBuilder(
                future: _profileService.getProfileAvatarUrl(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AvatarSkeleton(radius: 25);
                  }

                  if (snapshot.data == null) {
                    return const AvatarSkeleton(radius: 25);
                  }

                  return CircleAvatar(
                    radius: 25,
                    backgroundColor: _skeletonColor,
                    backgroundImage: NetworkImage(snapshot.data!),
                  );
                }),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile['displayName']),
                Text(
                  '@${profile['username']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                )
              ],
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChatPage(
                            receiverUsername: profile['username'],
                            receiverUserAvatarUrl:
                                profile.toString().contains('avatarUrl') == true
                                    ? profile['avatarUrl']
                                    : _profileService.defaultAvatar(),
                            receiverUserDisplayName: profile['displayName'],
                            receiverUserID: uid,
                          ))).then((_) => setState(() {}));
              ;
            },
          );
        });
  }
}
