import 'package:flutter/material.dart';
import 'package:minglechat/components/dm_skeleton.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashRadius: 20,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: const Column(children: [DirectMessagesSkeleton()]),
    );
  }
}
