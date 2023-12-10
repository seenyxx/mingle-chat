import 'package:flutter/material.dart';
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
            child: _buildFriendReqList(),
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

          if (snapshot.data!.isEmpty) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied, size: 30.0, color: Colors.white),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'No friends to show',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ));
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
            trailing: IconButton(
              color: Colors.white,
              splashRadius: 15,
              icon: const Icon(Icons.delete_forever_rounded),
              onPressed: () async {
                await _friendsService.removeFriend(uid);
                setState(() {});

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Removed friend'),
                    backgroundColor: Colors.green,
                  ));
                }
              },
            ),
          );
        });
  }

  Widget _buildFriendReqList() {
    return FutureBuilder<List<String>>(
        future: _friendsService.getFriendRequests(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.isEmpty) {
            return const Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.emoji_people_rounded, size: 30.0, color: Colors.white),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'No friend requests to show',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _buildFriendReqListItem(snapshot.data![index]),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
          );
        });
  }

  Widget _buildFriendReqListItem(String uid) {
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                      onPressed: () async {
                        await _friendsService.addFriend(uid);
                        setState(() {});

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Friend request approved'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      splashRadius: 15,
                      splashColor: Colors.lightGreen.withOpacity(0.5),
                      icon: const Icon(Icons.done),
                      color: Colors.green),
                  IconButton(
                      onPressed: () async {
                        await _friendsService.removeFriendRequest(uid);
                        setState(() {});

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Friend request denied'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      splashRadius: 15,
                      splashColor: Colors.redAccent.withOpacity(0.5),
                      icon: const Icon(Icons.close),
                      color: Colors.red)
                ],
              ));
        });
  }
}
