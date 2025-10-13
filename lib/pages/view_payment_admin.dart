import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminViewPaymentPage extends StatelessWidget {
  const AdminViewPaymentPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.payment, color: Colors.white),
            SizedBox(width: 10),
            Text("Payment Details"),
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
          'All payment details for admin.',
          style: TextStyle(fontSize: 18, color: Colors.brown[800]),
        ),
      ),
    );
  }
}
