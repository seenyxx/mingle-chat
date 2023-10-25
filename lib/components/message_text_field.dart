import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageTextField extends StatefulWidget {
  final TextEditingController controller;
  final void Function()? submitAction;
  final String hintText;

  const MessageTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.submitAction,
  });

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: false,
      cursorColor: Colors.white,
      onChanged: (value) {
        setState(() {});
      },
      keyboardType: TextInputType.multiline,
      maxLines: null,
      inputFormatters: [
        LengthLimitingTextInputFormatter(1000),
      ],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF21212F),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFF6C6C6C)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CircleAvatar(
              radius: 5,
              backgroundColor: widget.controller.text.trim().isEmpty
                  ? Colors.transparent
                  : Colors.blue,
              child: IconButton(
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onPressed: () {
                  widget.submitAction!();
                  widget.controller.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.send_rounded),
                color: Colors.white,
              ),
            ),
          )),
    );
  }
}
