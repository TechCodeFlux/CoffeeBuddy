import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ShopDetailsPage.dart';

class ShopsPage extends StatelessWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text("Coffee Shops"),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Fetch only verified shop owners
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'shop_owner')
            .where('status', isEqualTo: 'verified')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.brown),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No verified shops available.",
                style: TextStyle(color: Colors.brown, fontSize: 18),
              ),
            );
          }

          final shops = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final data = shops[index].data() as Map<String, dynamic>? ?? {};

              // ✅ Safely access shop fields
              final shopName = data['shopName'] ?? 'Unnamed Shop';
              // final ownerName = data['ownerName'] ?? 'Unknown Owner';
              final shopAddress = data['shopAddress'] ?? 'No address provided';
              final licenseNumber = data['licenseNumber'] ?? 'N/A';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ShopDetailsPage(shopData: shops[index]),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shadowColor: Colors.brown.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.brown[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_cafe,
                            color: Colors.brown,
                            size: 35,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Text(
                              //   "Owner: $ownerName",
                              //   style: TextStyle(
                              //     color: Colors.brown[600],
                              //     fontSize: 14,
                              //   ),
                              // ),
                              const SizedBox(height: 4),
                              Text(
                                shopAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.brown[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.brown,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
