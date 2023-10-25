import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:minglechat/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String avatarUrl;
  final String timestampString;
  final String senderId;
  final String receiverId;
  final String timestampMillisecondsString;

  static LinearGradient senderGradient =
      const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, stops: [
    0,
    1,
  ], colors: [
    Color(0xFFFFA7B1),
    Color(0xFFCC79FF),
  ]);

  static LinearGradient receiverGradient =
      const LinearGradient(begin: Alignment.bottomLeft, end: Alignment.topRight, stops: [
    0,
    1,
  ], colors: [
    Color(0xFFC2D2EA),
    Color(0xFFE2C2EA),
  ]);

  const ChatBubble(
      {super.key,
      required this.timestampString,
      required this.message,
      required this.isSender,
      required this.avatarUrl,
      required this.senderId,
      required this.receiverId,
      required this.timestampMillisecondsString});

  @override
  Widget build(BuildContext context) {
    return FocusedMenuHolder(
      menuWidth: MediaQuery.of(context).size.width * 0.5,
      blurSize: 60.0,
      menuItemExtent: 45,
      onPressed: () {},
      animateMenuItems: false,
      blurBackgroundColor: const Color(0xFF100B1C),
      // openWithTap: true,
      menuBoxDecoration: const BoxDecoration(
          color: Color(0xFF120D1E),
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      menuItems: isSender
          ? [
              _buildTimestampMenu(),
              _buildCopyMessageMenu(context),
              FocusedMenuItem(
                  backgroundColor: const Color(0xFF21212F),
                  title: const Text(
                    'Delete Message',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    ChatService chatService = ChatService();

                    await chatService.deleteMessage(
                        senderId, receiverId, timestampMillisecondsString);

                    chatService.dispose();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Message deleted'),
                        backgroundColor: Colors.green,
                        duration: Duration(milliseconds: 500),
                      ));
                    }
                  },
                  trailingIcon: const Icon(Icons.delete, color: Colors.red))
            ]
          : [_buildTimestampMenu(), _buildCopyMessageMenu(context)],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(clipBehavior: Clip.none, children: [
          Container(
              // constraints: const BoxConstraints(minWidth: 90, minHeight: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: isSender ? senderGradient : receiverGradient),
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
              )),
          Positioned(
              top: -28,
              right: isSender ? -18 : null,
              left: isSender ? null : -18,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.red,
                backgroundImage: NetworkImage(avatarUrl),
              )),
          // Positioned(
          //   bottom: 5,
          //   right: 10,
          //   child: Text(
          //     timestampString,
          //     textAlign: TextAlign.end,
          //     style: TextStyle(
          //         color: Colors.grey[700], fontSize: 11.5, fontWeight: FontWeight.bold),
          //   ),
          // )
        ]),
      ),
    );
  }

  FocusedMenuItem _buildTimestampMenu() {
    return FocusedMenuItem(
        backgroundColor: const Color(0xFF21212F),
        title: Text(
          'Sent at $timestampString',
          style: const TextStyle(color: Colors.white),
        ),
        onPressed: () {},
        trailingIcon: const Icon(Icons.schedule_rounded, color: Colors.white));
  }

  FocusedMenuItem _buildCopyMessageMenu(context) {
    return FocusedMenuItem(
        backgroundColor: const Color(0xFF21212F),
        title: const Text(
          'Copy Message',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Message copied'),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 500),
          ));
          Clipboard.setData(ClipboardData(text: message));
        },
        trailingIcon: const Icon(Icons.copy_rounded, color: Colors.white));
  }
}
