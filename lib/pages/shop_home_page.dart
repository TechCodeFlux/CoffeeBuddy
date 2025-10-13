import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopHomePage extends StatefulWidget {
  const ShopHomePage({super.key});

  @override
  State<ShopHomePage> createState() => _ShopHomePageState();
}

class _ShopHomePageState extends State<ShopHomePage> {
  String email = "";
  String shopName = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('loggedInEmail') ?? "";
    setState(() {
      email = savedEmail;
    });

    // Optionally, fetch additional shop owner data from Firestore
    if (FirebaseAuth.instance.currentUser != null) {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        setState(() {
          shopName = doc.data()?['shopName'] ?? "";
        });
      }
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInEmail');
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'View Orders',
        'icon': Icons.calendar_today,
        'color': Colors.brown.shade500,
        'route': '/ownerviewbook',
      },
      {
        'title': 'View Payments',
        'icon': Icons.payment,
        'color': Colors.brown.shade600,
        'route': '/ownerviewpayment',
      },
      {
        'title': 'Add New Coffee',
        'icon': Icons.add_circle,
        'color': Colors.brown.shade300,
        'route': '/addcoffee',
      },
      {
        'title': 'View Coffee Flavours',
        'icon': Icons.person,
        'color': Colors.brown.shade400,
        'route': '/viewcoffeeflavourowner',
      },
      {
        'title': 'History of Orders',
        'icon': Icons.calendar_today,
        'color': Colors.brown.shade500,
        'route': '/ownerviewbook',
      },
      {
        'title': 'View Feedback',
        'icon': Icons.feedback,
        'color': Colors.brown.shade700,
        'route': '/ownerviewfeedback',
      },
      {
        'title': 'View Profile',
        'icon': Icons.person,
        'color': Colors.brown.shade400,
        'route': '/ownerprofile',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.store, color: Colors.white),
            SizedBox(width: 8),
            Text("Shop Owner"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display shop name and email
            if (shopName.isNotEmpty)
              Text(
                "Welcome, $shopName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 5),
            // if (email.isNotEmpty)
            //   Text("Email: $email", style: const TextStyle(fontSize: 16)),
            // const SizedBox(height: 16),

            // Grid menu
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, item['route'] as String);
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.shade200,
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 50,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
