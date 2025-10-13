import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ShopOwnerProfilePage extends StatefulWidget {
  const ShopOwnerProfilePage({super.key});

  @override
  State<ShopOwnerProfilePage> createState() => _ShopOwnerProfilePageState();
}

class _ShopOwnerProfilePageState extends State<ShopOwnerProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _shopImageFile;

  Future<Map<String, dynamic>?> _getShopOwnerData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection("users").doc(user.uid).get();
    return snapshot.data();
  }

  Future<void> _pickShopImage(String userId) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _shopImageFile = File(pickedImage.path);
      });

      final ref = FirebaseStorage.instance.ref().child(
        "shop_images/$userId.jpg",
      );
      await ref.putFile(_shopImageFile!);
      final imageUrl = await ref.getDownloadURL();

      await _firestore.collection("users").doc(userId).update({
        "shopImage": imageUrl,
      });
    }
  }

  Future<void> _editProfile(Map<String, dynamic> data, String userId) async {
    final nameController = TextEditingController(text: data["name"]);
    final phoneController = TextEditingController(text: data["phone"]);
    final shopNameController = TextEditingController(text: data["shopName"]);
    final shopAddressController = TextEditingController(
      text: data["shopAddress"],
    );
    final ownerNameController = TextEditingController(text: data["ownerName"]);
    final licenseController = TextEditingController(
      text: data["licenseNumber"],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Edit Profile",
            style: TextStyle(color: Colors.brown),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(ownerNameController, "Owner Name"),
                _buildTextField(nameController, "Email Name / User Name"),
                _buildTextField(phoneController, "Phone"),
                _buildTextField(shopNameController, "Shop Name"),
                _buildTextField(shopAddressController, "Shop Address"),
                _buildTextField(licenseController, "License Number"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _firestore.collection("users").doc(userId).update({
                  "ownerName": ownerNameController.text,
                  "name": nameController.text,
                  "phone": phoneController.text,
                  "shopName": shopNameController.text,
                  "shopAddress": shopAddressController.text,
                  "licenseNumber": licenseController.text,
                });
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Save", style: TextStyle(color: Colors.brown)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
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

  Future<void> _deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection("users").doc(user.uid).delete();
        await user.delete();
        Navigator.pushReplacementNamed(context, "/login");
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
      appBar: AppBar(
        title: const Text("Shop Profile"),
        backgroundColor: Colors.brown,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getShopOwnerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("No profile data found"));
          }

          final data = snapshot.data!;
          final userId = _auth.currentUser!.uid;

          final ownerName = data["ownerName"] ?? "Not available";
          final name = data["name"] ?? "Unknown";
          final email = data["email"] ?? "Not available";
          final phone = data["phone"] ?? "Not available";
          final shopName = data["shopName"] ?? "Not available";
          final shopAddress = data["shopAddress"] ?? "Not available";
          final licenseNumber = data["licenseNumber"] ?? "Not available";
          final shopImage = data["shopImage"];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _pickShopImage(userId),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.brown.shade200,
                    backgroundImage: shopImage != null
                        ? NetworkImage(shopImage)
                        : null,
                    child: shopImage == null
                        ? const Icon(Icons.store, size: 60, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  shopName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Owned by $ownerName",
                  style: const TextStyle(fontSize: 16, color: Colors.brown),
                ),
                const SizedBox(height: 20),
                _buildInfoTile(Icons.email, "Email", email),
                _buildInfoTile(Icons.phone, "Phone", phone),
                _buildInfoTile(Icons.location_on, "Shop Address", shopAddress),
                _buildInfoTile(Icons.badge, "License Number", licenseNumber),
                const SizedBox(height: 24),

                // Professional buttons
                _buildButton(
                  "Edit Profile",
                  Icons.edit,
                  Colors.brown.shade700,
                  () => _editProfile(data, userId),
                ),
                const SizedBox(height: 12),
                _buildOutlinedButton(
                  "Change Password",
                  Icons.lock_reset,
                  Colors.brown.shade700,
                  _changePassword,
                ),
                const SizedBox(height: 12),
                _buildButton(
                  "Delete Account",
                  Icons.delete_forever,
                  Colors.red.shade700,
                  _deleteAccount,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    String label,
    IconData icon,
    Color borderColor,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: borderColor),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: borderColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: borderColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
