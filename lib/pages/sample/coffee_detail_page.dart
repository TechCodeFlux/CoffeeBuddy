import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CoffeeDetailPage extends StatelessWidget {
  final String coffeeId;
  final Map<String, dynamic> coffeeData;

  const CoffeeDetailPage({
    super.key,
    required this.coffeeId,
    required this.coffeeData,
  });

  Future<void> _deleteCoffee(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Coffee"),
        content: const Text("Are you sure you want to delete this coffee?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('coffee')
          .doc(coffeeId)
          .delete();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Coffee deleted successfully"),
          backgroundColor: Colors.brown,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = coffeeData['name'] ?? 'Unnamed';
    final price = coffeeData['price']?.toString() ?? 'N/A';
    final description = coffeeData['description'] ?? '';
    final imagePath = coffeeData['imagePath'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coffee Details"),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteCoffee(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (imagePath.isNotEmpty)
              Image.network(imagePath, height: 200, fit: BoxFit.cover)
            else
              const Icon(Icons.local_cafe, size: 200, color: Colors.brown),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Price: ₹$price", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              "Description:\n$description",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
