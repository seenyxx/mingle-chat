import 'package:flutter/material.dart';
import 'package:minglechat/components/login_button.dart';
import 'package:minglechat/components/login_text_field.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  final displayNameController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        leading: IconButton(
          highlightColor: Colors.transparent,
          splashRadius: 20,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
              child: Column(
                children: [
                  const CircleAvatar(radius: 60,),
                  const SizedBox(height: 30.0),
                  LoginTextField(
                    controller: displayNameController,
                    hintText: 'Display Name',
                    obscureText: false
                  ),
                  const SizedBox(height: 30),
                  LoginTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false
                  ),
                  const SizedBox(height: 30),
                  LoginButton(onTap: (){}, text: 'Save')
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}