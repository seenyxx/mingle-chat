import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minglechat/firebase_options.dart';
import 'package:minglechat/services/auth/auth_gate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:minglechat/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: ThemeData(
        progressIndicatorTheme: const ProgressIndicatorThemeData(
            circularTrackColor: Color(0xFF21212F), color: Color(0xFF343449)),
        scaffoldBackgroundColor: const Color(0xFF120D1E),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white),
        appBarTheme: AppBarTheme(
            toolbarHeight: 80,
            titleTextStyle: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0),
            backgroundColor: const Color(0xFF120D1E),
            foregroundColor: Colors.white,
            shape: const Border(bottom: BorderSide(color: Color(0xFF21212F), width: 4))),
      ),
    );
  }
}
