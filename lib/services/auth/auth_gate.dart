import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minglechat/pages/home_page.dart';
import 'package:minglechat/services/auth/login_or_register.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Display home page if user is logged in
            return const HomePage();
          } else {
            // Otherwise if the user is not logged in then display login or register page
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
