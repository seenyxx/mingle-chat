import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:minglechat/components/chat_bubble.dart';
import 'package:minglechat/components/message_text_field.dart';
import 'package:minglechat/services/accounts/profile_service.dart';
import 'package:minglechat/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserID;
  final String receiverUserAvatarUrl;
  final String receiverUserDisplayName;
  final String receiverUsername;

  const ChatPage(
      {super.key,
      required this.receiverUsername,
      required this.receiverUserDisplayName,
      required this.receiverUserID,
      required this.receiverUserAvatarUrl});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();
  final ProfileService _profileService = ProfileService();

  late String senderUserAvatarUrl = '';
  late String senderUserDisplayName;

  void sendMessage() async {
    if (_messageController.text.trim().isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text.trim());

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _profileService.dispose();
    _chatService.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xBB120D1E),
        shape: const Border(bottom: BorderSide(color: Color(0x8821212F), width: 4)),
        flexibleSpace: ClipRect(
            child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
          child: Container(color: Colors.transparent),
        )),
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashRadius: 20,
          onPressed: () => Navigator.pop(
            context,
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Row(children: [
            Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.receiverUserAvatarUrl),
                )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverUserDisplayName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('@${widget.receiverUsername}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey)),
                ),
              ],
            )
          ]),
        ),
      ),
      body: Column(
        children: [
          // Messages
          FutureBuilder(
              future: _profileService.getUserProfile(_firebaseAuth.currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                  // return Container();
                }

                senderUserAvatarUrl =
                    snapshot.data!.data().toString().contains('avatarUrl') == true
                        ? snapshot.data!['avatarUrl']
                        : _profileService.defaultAvatar();
                senderUserDisplayName = snapshot.data!['displayName'];

                return Expanded(
                  child: _buildMessageList(),
                );
              }),

          _buildMessageInput(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var messages = snapshot.data!.docs
              .map((document) => document.data() as Map<String, dynamic>)
              .toList();

          // Insert padding at the start of the reversed list in order to fix the message showing underneath the appbar
          messages.insert(messages.length,
              {'start': true, 'timestamp': Timestamp.fromMillisecondsSinceEpoch(0)});

          // return ListView(
          //   shrinkWrap: true,
          //   reverse: true,
          //   padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
          //   children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
          // );
          return GroupedListView(
            controller: _scrollController,
            shrinkWrap: true,
            reverse: true,
            sort: false,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12.0),
            elements: messages,
            groupBy: (message) {
              return DateTime(
                (message['timestamp'] as Timestamp).toDate().year,
                (message['timestamp'] as Timestamp).toDate().month,
                (message['timestamp'] as Timestamp).toDate().day,
                (message['timestamp'] as Timestamp).toDate().hour,
              );
            },
            groupHeaderBuilder: (Map<String, dynamic> message) {
              return SizedBox(
                  height: 35,
                  child: Center(
                      child: Text(
                    '${DateFormat.yMMMMEEEEd().format((message['timestamp'] as Timestamp).toDate())} ${DateFormat.jm().format((message['timestamp'] as Timestamp).toDate())}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                      fontWeight: FontWeight.normal,
                    ),
                  )));
            },
            itemBuilder: (context, Map<String, dynamic> message) =>
                _buildMessageItem(message),
          );
        });
  }

  // Build message item
  Widget _buildMessageItem(Map<String, dynamic> data) {
    if (data['start'] != null) {
      // Creating the beginning padding at the start
      return const SizedBox(
        height: 120,
      );
    }
    // Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    // Map<String, dynamic> data = document.toMap();

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;
    DateTime timestampDate = (data['timestamp'] as Timestamp).toDate();

    return Row(
      mainAxisAlignment: alignment == Alignment.centerRight
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
            constraints: const BoxConstraints(maxWidth: 250),
            margin: EdgeInsets.symmetric(vertical: isSender == true ? 0 : 10),
            alignment: alignment,
            child: Column(
              crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                isSender
                    ? const SizedBox.shrink()
                    : FittedBox(
                        fit: BoxFit.cover,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: isSender ? 0 : 34, right: isSender ? 34 : 0),
                          child: Align(
                            alignment: alignment,
                            child: Text(
                              isSender
                                  ? senderUserDisplayName
                                  : widget.receiverUserDisplayName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFAAAAAA),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                ChatBubble(
                    avatarUrl:
                        isSender ? senderUserAvatarUrl : widget.receiverUserAvatarUrl,
                    message: data['message'],
                    isSender: isSender,
                    senderId: data['senderId'],
                    receiverId: data['receiverId'],
                    timestampString: DateFormat.jms().format(timestampDate),
                    timestampMillisecondsString: (data['timestamp'] as Timestamp)
                        .millisecondsSinceEpoch
                        .toString()),
                // Container(
                //   padding:
                //       EdgeInsets.only(left: isSender ? 0 : 10, right: isSender ? 10 : 0),
                //   child: Align(
                //     alignment: alignment,
                //     child: Text(
                //       DateFormat.jm().format((data['timestamp'] as Timestamp).toDate()),
                //       style: const TextStyle(
                //         fontSize: 12,
                //         color: Color(0xFFAAAAAA),
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            )),
      ],
    );
  }

  // Build message input
  Widget _buildMessageInput() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Expanded(
                    child: MessageTextField(
                  controller: _messageController,
                  hintText: 'Message',
                  submitAction: sendMessage,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
