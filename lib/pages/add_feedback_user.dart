import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddFeedbackUserPage extends StatefulWidget {
  const AddFeedbackUserPage({super.key});

  @override
  State<AddFeedbackUserPage> createState() => _AddFeedbackUserPageState();
}

class _AddFeedbackUserPageState extends State<AddFeedbackUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('feedbacks').add({
        "shopName": _shopController.text.trim(),
        "feedbackText": _feedbackController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback submitted successfully!")),
      );

      _shopController.clear();
      _feedbackController.clear();

      // ✅ Redirect to userviewfeedback page
      Navigator.pushReplacementNamed(context, "/userviewfeedback");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Feedback"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _shopController,
                decoration: const InputDecoration(
                  labelText: "Shop Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter shop name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: "Your Feedback",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter feedback" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submitFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
