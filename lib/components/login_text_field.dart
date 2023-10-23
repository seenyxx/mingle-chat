import 'package:flutter/material.dart'; 

class LoginTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.white,
      enableSuggestions: false,
      autocorrect: false,

      style: const TextStyle(
        color: Colors.white
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF21212F),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF6C6C6C)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        )
      ),
    );
  }
}