import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mindfuck/screens/email_login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MindfuckApp());
}

class MindfuckApp extends StatelessWidget {
  const MindfuckApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mindfuck',
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: EmailLoginPage(),
    );
  }
}
