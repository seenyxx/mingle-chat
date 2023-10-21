import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:minglechat/components/chat_bubble.dart';
import 'package:minglechat/components/login_text_field.dart';
import 'package:minglechat/services/chat/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;

  const ChatPage({
    super.key,
    required this.receiverUserEmail,
    required this.receiverUserID,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();


  void sendMessage() async {
    if(_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.receiverUserID, _messageController.text);
      _messageController.clear();
    }

    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverUserEmail,
          style: const TextStyle(fontSize: 18),
        )
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _buildMessageList(),
          ),

          _buildMessageInput(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // Build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverUserID, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }
        var messages = snapshot.data!.docs.map((document) => document.data() as Map<String, dynamic>).toList();
        
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
          groupBy: (message) => DateTime(
            (message['timestamp'] as Timestamp).toDate().year,
            (message['timestamp'] as Timestamp).toDate().month,
            (message['timestamp'] as Timestamp).toDate().day,
            (message['timestamp'] as Timestamp).toDate().hour,
          ), 
          groupHeaderBuilder: (Map<String, dynamic> message) => SizedBox(
            height: 35,
            child: Center(
              child: Text(
                '${DateFormat.yMMMMEEEEd().format((message['timestamp'] as Timestamp).toDate())} ${DateFormat.jm().format((message['timestamp'] as Timestamp).toDate())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.normal,
                ),
              )
            )
          ),
          itemBuilder: (context, Map<String, dynamic> message) => _buildMessageItem(message),
        );
      }
    );
  }

  // Build message item
  Widget _buildMessageItem(Map<String, dynamic> data) {
    // Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    // Map<String, dynamic> data = document.toMap();

    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
      ? Alignment.centerRight
      : Alignment.centerLeft;

    // DateTime timestampDate = (data['timestamp'] as Timestamp).toDate();

    return Row(
      mainAxisAlignment: alignment == Alignment.centerRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 250),
          margin: const EdgeInsets.symmetric(vertical: 10),
          alignment: alignment,
          child: Column(
            crossAxisAlignment: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                data['senderEmail'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              ChatBubble(message: data['message'], isSender: data['senderId'] == _firebaseAuth.currentUser!.uid),
              const SizedBox(height: 5),
              Text(
                DateFormat.jm().format((data['timestamp'] as Timestamp).toDate()),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ),
      ],
    );
  }

  // Build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: LoginTextField(
              controller: _messageController,
              hintText: 'Message',
              obscureText: false,
            )
          ),
    
          IconButton(
            onPressed: sendMessage,
            color: Colors.white,
            icon: const Icon(Icons.send, size: 40)
          )
        ],
      ),
    );
  }
}