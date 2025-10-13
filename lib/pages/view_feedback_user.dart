import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewFeedbackPage extends StatelessWidget {
  const UserViewFeedbackPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.feedback, color: Colors.white),
            SizedBox(width: 10),
            Text("Feedback - User"),
          ],
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Text(
          'List of all Feedbacks.',
          style: TextStyle(fontSize: 18, color: Colors.brown[800]),
        ),
      ),
    );
  }
}
