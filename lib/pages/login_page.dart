import 'package:flutter/material.dart';
import 'package:minglechat/components/login_button.dart';
import 'package:minglechat/components/login_text_field.dart';
import 'package:minglechat/services/auth/auth_service.dart';
import 'package:provider/provider.dart'; 

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Sign in
  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signInWithEmailandPassword(emailController.text, passwordController.text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Column(
                children: [
                  const SizedBox(height: 50.0),
                  const Image(
                    image: AssetImage("assets/icon.png"),
                    width: 192,
                    height: 192,
                  ),
                  const Text("Welcome", style:
                    TextStyle(
                      fontSize: 42,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const SizedBox(height: 20.0),
      
                  // Email Input
                  LoginTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false
                  ),
      
                  const SizedBox(height: 20.0),
      
                  // Password Input
                  LoginTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true
                  ),
      
                  const SizedBox(height: 20.0),
                  // Sign in button
                  LoginButton(onTap: signIn, text: "Sign In"),
      
                  const SizedBox(height: 20.0),
      
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Not a member?",
                        style: TextStyle(
                          fontSize: 16,
                        )
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          'Register now',
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
        )
        ),
      ) 
    );
  }
}