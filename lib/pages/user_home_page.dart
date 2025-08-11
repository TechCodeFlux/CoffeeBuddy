import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Coffee Buddy"),
        backgroundColor: Colors.brown,
      ),
      body: const Center(
        child: Text(
          "You are user now logged in!",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
