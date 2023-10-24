import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:minglechat/components/login_button.dart';
import 'package:minglechat/components/login_text_field.dart';
import 'package:minglechat/components/user_profile_text_field.dart';
import 'package:minglechat/services/accounts/profile_service.dart';
import 'package:minglechat/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();

  final scrollController = ScrollController();
  late StreamSubscription<bool> keyboardSubscription;
  final ProfileService _profileService = ProfileService();

  // Sign up
  void signUp() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        displayNameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Not all fields are filled")));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signUpWithEmailandPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    _profileService.updateUserProfile(
        usernameController.text.trim(), usernameController.text.trim());
  }

  @override
  void initState() {
    super.initState();

    var kbVisibilityController = KeyboardVisibilityController();
    keyboardSubscription = kbVisibilityController.onChange.listen((bool visible) {
      if (visible && scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      controller: scrollController,
      child: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              // const Image(
              //   image: AssetImage("assets/icon.png"),
              //   width: 192,
              //   height: 192,
              // ),
              const Text("Create Account",
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )),
              const SizedBox(height: 20.0),

              // Email Input
              LoginTextField(
                  scrollController: scrollController,
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false),

              const SizedBox(height: 10.0),

              // Password Input
              LoginTextField(
                  scrollController: scrollController,
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true),

              const SizedBox(height: 10.0),

              // Confirm Password Input
              LoginTextField(
                  scrollController: scrollController,
                  controller: confirmPasswordController,
                  hintText: 'Confirm password',
                  obscureText: true),

              const SizedBox(height: 30.0),

              UserProfileTextField(
                hintText: 'Username',
                controller: usernameController,
                initialValue: 'a',
                onStart: () {},
              ),

              const SizedBox(height: 10),

              UserProfileTextField(
                  hintText: 'Display Name',
                  initialValue: '',
                  controller: displayNameController,
                  onStart: () {}),

              const SizedBox(height: 20),

              // Sign up button
              LoginButton(onTap: signUp, text: "Sign Up"),

              const SizedBox(height: 20.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a member?",
                      style: TextStyle(
                        fontSize: 16,
                      )),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      )),
    ));
  }
}
