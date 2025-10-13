import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot shopData;
  const ShopDetailsPage({required this.shopData, super.key});

  @override
  Widget build(BuildContext context) {
    final shopOwnerId = shopData.id;
    final shopName = shopData['shopName'] ?? 'Unnamed Shop';
    final owner = shopData['ownerName'] ?? 'Unknown Owner';
    final license = shopData['licenseNumber'] ?? 'N/A';
    final address = shopData['shopAddress'] ?? 'No address provided';

    // Safely get shop image
    final shopImage =
        (shopData.data() as Map<String, dynamic>?)?.containsKey('imagePath') ==
            true
        ? shopData['imagePath'] ?? ''
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: Text(shopName),
        backgroundColor: Colors.brown[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------- Shop Image -----------
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: shopImage.isNotEmpty
                  ? Image.network(
                      shopImage,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.brown[100],
                          child: const Icon(
                            Icons.store,
                            size: 50,
                            color: Colors.brown,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.brown[100],
                      child: const Icon(
                        Icons.store,
                        size: 50,
                        color: Colors.brown,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // ----------- Shop Info -----------
            Text(
              shopName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.store, "Owner", owner),
                  const SizedBox(height: 10),
                  _infoRow(Icons.badge, "License No.", license),
                  const SizedBox(height: 10),
                  _infoRow(Icons.location_on, "Address", address),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ----------- Coffee List Title -----------
            const Text(
              "Coffees Available",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 12),

            // ----------- Coffee List from Firestore -----------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('coffee')
                  .where('shopOwnerId', isEqualTo: shopOwnerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.brown),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "No coffees listed yet.",
                      style: TextStyle(color: Colors.brown, fontSize: 16),
                    ),
                  );
                }

                final coffees = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: coffees.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final coffee =
                        coffees[index].data() as Map<String, dynamic>;
                    final coffeeName = coffee['name'] ?? 'Unnamed Coffee';
                    final price = coffee['price'] != null
                        ? double.parse(
                            coffee['price'].toString(),
                          ).toStringAsFixed(2)
                        : 'N/A';
                    final desc =
                        coffee['description'] ?? 'No description available';
                    final coffeeImageUrl = coffee.containsKey('imagePath')
                        ? coffee['imagePath'] ?? ''
                        : '';

                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: coffeeImageUrl.isNotEmpty
                                ? Image.network(
                                    coffeeImageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.brown[100],
                                        child: const Icon(
                                          Icons.local_cafe,
                                          color: Colors.brown,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.brown[100],
                                    child: const Icon(
                                      Icons.local_cafe,
                                      color: Colors.brown,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          coffeeName,
                          style: const TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.brown),
                        ),
                        trailing: Text(
                          "₹$price",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.brown),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            "$label: $value",
            style: const TextStyle(color: Colors.brown, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
