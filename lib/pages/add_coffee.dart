import 'dart:io'; // For File (mobile only)
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCoffeePage extends StatefulWidget {
  const AddCoffeePage({super.key});

  @override
  State<AddCoffeePage> createState() => _AddCoffeePageState();
}

class _AddCoffeePageState extends State<AddCoffeePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

Future<String> _saveImageToFirebase(File image) async {
  // Create a reference to Firebase Storage root
  final storageRef = FirebaseStorage.instance.ref();

  // Create a timestamp-based filename
  final timestamp = DateTime.now().toIso8601String().replaceAll(':', '');
  final fileExtension = path.extension(image.path);

  // Create a folder 'coffee_images' and unique filename
  final imageRef = storageRef.child('coffee_images/coffee_$timestamp$fileExtension');

  // Upload the image file
  final uploadTask = await imageRef.putFile(image);

  // Get the download URL after successful upload
  final downloadUrl = await imageRef.getDownloadURL();

  return downloadUrl;
}


 Future<void> _saveCoffee() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedImage == null) {
    _showAlert(
      title: "Missing Image",
      message: "Please select an image for the coffee.",
      isError: true,
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final description = _descriptionController.text.trim();

    // ✅ Upload image to Firebase Storage (works for web & mobile)
    String imageUrl = '';
    if (kIsWeb) {
      // On web, convert XFile to Uint8List before uploading
      final bytes = await _selectedImage!.readAsBytes();
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '');
      final imageRef = storageRef.child('coffee_images/coffee_$timestamp.jpg');

      await imageRef.putData(bytes); // Uploads bytes to Firebase
      imageUrl = await imageRef.getDownloadURL(); // ✅ Get Firebase URL
    } else {
      // On mobile (Android/iOS)
      final localImage = File(_selectedImage!.path);
      imageUrl = await _saveImageToFirebase(localImage);
    }

    // ✅ Save metadata to Firestore
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance.collection('coffee').doc();

    await docRef.set({
      'coffeeId': docRef.id,
      'shopOwnerId': userId,
      'name': name,
      'price': price,
      'description': description,
      'imagePath': imageUrl, // ✅ Now stores Firebase Storage URL
      'createdAt': FieldValue.serverTimestamp(),
    });

    _showAlert(
      title: "Success",
      message: "Coffee '$name' added successfully!",
      isError: false,
      onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AddCoffeePage()),
        );
      },
    );
  } catch (e) {
    _showAlert(
      title: "Error",
      message: "Failed to save coffee: $e",
      isError: true,
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  // Alert dialog for success/error messages
  void _showAlert({
    required String title,
    required String message,
    required bool isError,
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildImagePreview() {
      if (_selectedImage == null) {
        return const Center(
          child: Text(
            "Tap to add coffee image",
            style: TextStyle(color: Colors.brown),
          ),
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: kIsWeb
            ? Image.network(
                _selectedImage!.path,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Image.file(
                File(_selectedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Coffee"),
        backgroundColor: Colors.brown,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.brown.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.brown.shade50,
                      ),
                      child: buildImagePreview(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Coffee Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? "Enter coffee name"
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: "Price",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Enter price";
                      if (double.tryParse(value) == null) {
                        return "Enter valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _saveCoffee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text(
                      "Save Coffee",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              ),
            ),
        ],
      ),
    );
  }
}
