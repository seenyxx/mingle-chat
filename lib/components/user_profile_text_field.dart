import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserProfileTextField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final TextEditingController controller;
  final Function()? onStart;

  const UserProfileTextField({
    super.key,
    required this.hintText,
    required this.initialValue,
    required this.controller,
    required this.onStart,
  });

  @override
  State<UserProfileTextField> createState() => _UserProfileTextFieldState();
}

class _UserProfileTextFieldState extends State<UserProfileTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = widget.initialValue;
    widget.onStart!();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autocorrect: false,
      autofocus: false,
      enableSuggestions: false,
      controller: widget.controller,
      inputFormatters: [LengthLimitingTextInputFormatter(32)],
      decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF21212F),
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFF6C6C6C)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          )),
    );
  }
}
