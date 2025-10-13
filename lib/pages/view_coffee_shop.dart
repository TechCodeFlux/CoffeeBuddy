import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewCoffeeShopPage extends StatefulWidget {
  const ViewCoffeeShopPage({super.key});

  @override
  State<ViewCoffeeShopPage> createState() => _ViewCoffeeShopPageState();
}

class _ViewCoffeeShopPageState extends State<ViewCoffeeShopPage> {
  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _deleteShopOwner(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shop owner deleted successfully."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error deleting shop owner: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDelete(String docId, String shopName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Confirm Deletion",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete the shop '$shopName'?",
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteShopOwner(docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text(
          "Verified Coffee Shops",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown.shade700,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'shop_owner')
            .where('status', isEqualTo: 'verified')
            .snapshots(),
        builder: (context, snapshot) {
          // 🔄 Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }

          // ❌ Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading coffee shops.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final shops = snapshot.data?.docs ?? [];

          // 📴 No Data
          if (shops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_mall_directory,
                    color: Colors.brown[300],
                    size: 70,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "No verified coffee shops yet.",
                    style: TextStyle(
                      color: Colors.brown[700],
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // 🧾 Responsive Table
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double columnWidth = constraints.maxWidth < 600 ? 150 : 200;

                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadowColor: Colors.brown.withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                            Colors.brown[100],
                          ),
                          columnSpacing: 24,
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.brown.shade200),
                            outside: BorderSide(color: Colors.brown.shade300),
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: const Text(
                                  'Shop Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: const Text(
                                  'Owner Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: const Text(
                                  'Email',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: columnWidth * 0.8,
                                child: const Text(
                                  'License Number',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: columnWidth * 0.6,
                                child: const Text(
                                  'Action',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows: shops.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            return DataRow(
                              cells: [
                                DataCell(Text(data['shopName'] ?? 'N/A')),
                                DataCell(Text(data['ownerName'] ?? 'N/A')),
                                DataCell(Text(data['email'] ?? 'N/A')),
                                DataCell(Text(data['licenseNumber'] ?? 'N/A')),
                                DataCell(
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade600,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _confirmDelete(
                                      doc.id,
                                      data['shopName'] ?? 'this shop',
                                    ),
                                    icon: const Icon(Icons.delete, size: 18),
                                    label: const Text("Delete"),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
