import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserViewPaymentPage extends StatelessWidget {
  const UserViewPaymentPage({super.key});

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
            Icon(Icons.local_cafe, color: Colors.white),
            SizedBox(width: 10),
            Text("Payment User View"),
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
          'List of Payments for user.',
          style: TextStyle(fontSize: 18, color: Colors.brown[800]),
        ),
      ),
    );
  }
}
