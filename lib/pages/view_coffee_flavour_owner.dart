import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ViewCoffeeFlavourOwnerPage extends StatelessWidget {
  const ViewCoffeeFlavourOwnerPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Coffee Flavours"),
          backgroundColor: Colors.brown,
        ),
        body: const Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Coffee Flavours"),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('coffee')
            .where('shopOwnerId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No coffee flavours added yet!",
                style: TextStyle(fontSize: 18, color: Colors.brown),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final coffee = doc.data() as Map<String, dynamic>;
              final id = doc.id;

              final name = coffee['name'] ?? '';
              final description = coffee['description'] ?? '';
              final price = coffee['price']?.toString() ?? '';
              final imagePath = coffee['imagePath'] ?? '';

              Widget buildImage() {
                if (kIsWeb || imagePath.isEmpty) {
                  return const Icon(
                    Icons.local_cafe,
                    color: Colors.brown,
                    size: 60,
                  );
                } else {
                  return Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                }
              }

              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => EditCoffeeDialog(
                      docId: id,
                      currentName: name,
                      currentDescription: description,
                      currentPrice: price,
                      currentImagePath: imagePath,
                    ),
                  );
                },
                child: CoffeeCubeCard(
                  name: name,
                  description: description,
                  price: price,
                  imageWidget: buildImage(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------- Cube Card (3D effect) --------------------
class CoffeeCubeCard extends StatefulWidget {
  final String name;
  final String description;
  final String price;
  final Widget imageWidget;

  const CoffeeCubeCard({
    super.key,
    required this.name,
    required this.description,
    required this.price,
    required this.imageWidget,
  });

  @override
  State<CoffeeCubeCard> createState() => _CoffeeCubeCardState();
}

class _CoffeeCubeCardState extends State<CoffeeCubeCard> {
  double _rotateX = 0;
  double _rotateY = 0;

  void _resetRotation() {
    setState(() {
      _rotateX = 0;
      _rotateY = 0;
    });
  }

  void _onHover(PointerEvent details, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    final dx = details.localPosition.dx - centerX;
    final dy = details.localPosition.dy - centerY;

    setState(() {
      _rotateY = dx / centerX * 0.2;
      _rotateX = -dy / centerY * 0.2;
    });
  }

  void _onHoverMobile(Offset localPosition, BoxConstraints constraints) {
    final centerX = constraints.maxWidth / 2;
    final centerY = constraints.maxHeight / 2;
    final dx = localPosition.dx - centerX;
    final dy = localPosition.dy - centerY;

    setState(() {
      _rotateY = dx / centerX * 0.2;
      _rotateX = -dy / centerY * 0.2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card = Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotateX)
            ..rotateY(_rotateY),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: widget.imageWidget,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Text(
                          "₹${widget.price}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        if (kIsWeb) {
          return MouseRegion(
            onHover: (details) => _onHover(details, constraints),
            onExit: (_) => _resetRotation(),
            child: card,
          );
        } else {
          return GestureDetector(
            onTapDown: (details) =>
                _onHoverMobile(details.localPosition, constraints),
            onTapUp: (_) => _resetRotation(),
            onTapCancel: _resetRotation,
            child: card,
          );
        }
      },
    );
  }
}

// -------------------- Edit Coffee Dialog --------------------
class EditCoffeeDialog extends StatefulWidget {
  final String docId;
  final String currentName;
  final String currentDescription;
  final String currentPrice;
  final String currentImagePath;

  const EditCoffeeDialog({
    super.key,
    required this.docId,
    required this.currentName,
    required this.currentDescription,
    required this.currentPrice,
    required this.currentImagePath,
  });

  @override
  State<EditCoffeeDialog> createState() => _EditCoffeeDialogState();
}

class _EditCoffeeDialogState extends State<EditCoffeeDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _newImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _descriptionController = TextEditingController(
      text: widget.currentDescription,
    );
    _priceController = TextEditingController(text: widget.currentPrice);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _newImagePath = pickedFile.path;
      });
    }
  }

  Future<void> _updateCoffee() async {
    final docRef = FirebaseFirestore.instance
        .collection('coffee')
        .doc(widget.docId);

    final updatedData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'price': double.tryParse(_priceController.text) ?? 0,
    };

    // Optional: update image path if a new image was picked
    if (_newImagePath != null) {
      updatedData['imagePath'] = _newImagePath!;
    }

    await docRef.update(updatedData);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Coffee"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: _newImagePath != null
                  ? Image.file(
                      File(_newImagePath!),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : widget.currentImagePath.isNotEmpty && !kIsWeb
                  ? Image.file(
                      File(widget.currentImagePath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.local_cafe, size: 80),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _updateCoffee, child: const Text("Update")),
      ],
    );
  }
}
