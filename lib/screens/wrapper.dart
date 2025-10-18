import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/main_screen.dart';
import 'package:myapp/screens/login_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // return either the Home or Authenticate widget
    if (user == null) {
      return const LoginScreen();
    } else {
      return const MainScreen();
    }
  }
}
