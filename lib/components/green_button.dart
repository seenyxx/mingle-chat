import 'package:flutter/material.dart';

class GreenButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const GreenButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                side: BorderSide.none, borderRadius: BorderRadius.circular(12.0)),
            fixedSize: const Size(400, 60),
            backgroundColor: Colors.green,
            elevation: 0,
            textStyle: const TextStyle(fontSize: 18)),
        child: Text(text));
  }
}
