import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:minglechat/components/avatar_skeleton.dart';
import 'package:minglechat/components/dm_skeleton.dart';
import 'package:minglechat/services/accounts/friends_serivce.dart';
import 'package:minglechat/services/accounts/profile_service.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final FriendsService _friendsService = FriendsService();
  final ProfileService _profileService = ProfileService();
  static const Color _skeletonColor = Color(0xFF21212F);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Friends'),
          leading: IconButton(
            highlightColor: Colors.transparent,
            splashRadius: 20,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              icon: Icon(Icons.people_alt_outlined),
              text: 'Friends',
            ),
            Tab(
              icon: Icon(Icons.group_add),
              text: 'Friend Requests',
            )
          ]),
        ),
        body: TabBarView(children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: _buildFriendList(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(),
          ),
        ]),
      ),
    );
  }

  Widget _buildFriendList() {
    return FutureBuilder<List<String>>(
        future: _friendsService.getFriendsList(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildFriendListItem(snapshot.data![index]),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          );
        });
  }

  Widget _buildFriendListItem(String uid) {
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
                future: _profileService.getProfileAvatarUrl(profile['uid']),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const AvatarSkeleton(radius: 20);
                  }

                  if (snapshot.data == null) {
                    return const AvatarSkeleton(radius: 20);
                  }

                  return CircleAvatar(
                    radius: 20,
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
            trailing: MenuAnchor(
              builder: (context, controller, child) {
                return IconButton(
                  color: Colors.white,
                  splashRadius: 15,
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                );
              },
              menuChildren: [const MenuItemButton(child: Text('a'))],
            ),
          );
        });
  }
}
