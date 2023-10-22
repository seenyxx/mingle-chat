import 'package:flutter/material.dart';



class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String uid;

  static LinearGradient senderGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [
      0,
      1,
    ],
    colors: [
      Color(0xFFFFA7B1),
      Color(0xFFCC79FF),
    ]
  );

  static LinearGradient receiverGradient = const LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    stops: [
      0,
      1,
    ],
    colors: [
      Color(0xFFC2D2EA),
      Color(0xFFE2C2EA),
    ]
  );

  const ChatBubble({super.key, required this.message, required this.isSender, required this.uid});


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: isSender ? senderGradient : receiverGradient
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.normal
              ),
            )
          ), 
          Positioned(
            top: -28,
            right: isSender ? -18 : null,
            left: isSender ? null : -18,
            child: const CircleAvatar(radius: 20, backgroundColor: Colors.red,)
          ),
        ]
      ),
    );
  }
}