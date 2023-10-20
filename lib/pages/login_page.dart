import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minglechat/components/login_button.dart';
import 'package:minglechat/components/login_text_field.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF120D1E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70.0),
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                const Image(
                  image: AssetImage('../assets/icon.png'),
                  width: 300,
                  height: 300,
                ),
                const Text("Welcome", style:TextStyle(fontSize: 64, color: Colors.white)),
                const SizedBox(height: 30.0),

                // Email Input
                LoginTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false
                ),

                const SizedBox(height: 30.0),

                // Password Input
                LoginTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true
                ),

                const SizedBox(height: 30.0),
                // Sign in button
                LoginButton(onTap: (){}, text: "Sign In"),

                const SizedBox(height: 20.0),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Not a member?"),
                    SizedBox(width: 4),
                    Text(
                      'Register now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
      )
      ) 
    );
  }
}