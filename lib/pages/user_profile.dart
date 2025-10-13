import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection("users").doc(user.uid).get();
    return snapshot.data();
  }

  Future<void> _editProfile(Map<String, dynamic> data, String userId) async {
    final nameController = TextEditingController(text: data["name"]);
    final phoneController = TextEditingController(text: data["phone"]);
    final addressController = TextEditingController(text: data["address"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone"),
                ),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _firestore.collection("users").doc(userId).update({
                  "name": nameController.text,
                  "phone": phoneController.text,
                  "address": addressController.text,
                });
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _auth.sendPasswordResetEmail(email: user.email!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
  title: const Text("My Profile"),
  backgroundColor: Colors.brown[700],
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      color: Colors.white,
      tooltip: "Logout",
      onPressed: () async {
        await _auth.signOut();
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    ),
  ],
),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile data found"));
          }

          final data = snapshot.data!;
          final userId = _auth.currentUser!.uid;
          final name = data["name"] ?? "Unknown";
          final email = data["email"] ?? "Not available";
          final phone = data["phone"] ?? "Not available";
          final address = data["address"] ?? "Not available";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.brown[300],
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Email
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.grey)),

                const SizedBox(height: 24),

                // Info Cards
                _buildInfoCard(Icons.phone, "Phone", phone),
                _buildInfoCard(Icons.location_on, "Address", address),

                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _editProfile(data, userId),
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock),
                        label: const Text("Reset Password"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: Icon(icon, color: Colors.brown[600], size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
