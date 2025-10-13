import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> adminItems = [
      {
        'title': 'Verify Shops',
        'icon': Icons.verified,
        'color': Colors.brown.shade300,
        'route': '/verifycoffeeshop',
      },
      {
        'title': 'View Shops',
        'icon': Icons.store_mall_directory,
        'color': Colors.brown.shade400,
        'route': '/viewcoffeeshop',
      },
      {
        'title': 'Payment Details',
        'icon': Icons.payment,
        'color': Colors.brown.shade500,
        'route': '/adminviewpayment',
      },
      {
        'title': 'Coffee Orders History',
        'icon': Icons.book_online,
        'color': Colors.brown.shade500,
        'route': '/adminviewbook',
      },
      {
        'title': 'View Feedbacks',
        'icon': Icons.feedback,
        'color': Colors.brown.shade600,
        'route': '/adminviewfeedback',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.admin_panel_settings, color: Colors.white),
            SizedBox(width: 10),
            Text("Admin Dashboard"),
          ],
        ),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: adminItems.length,
          itemBuilder: (context, index) {
            final item = adminItems[index];
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
    );
  }
}
