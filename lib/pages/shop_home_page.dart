import 'package:flutter/material.dart';

class ShopHomePage extends StatelessWidget {
  const ShopHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Add New Coffee',
        'icon': Icons.add_circle,
        'color': Colors.brown.shade300 as Color,
        'route': '/add-coffee',
      },
      {
        'title': 'View Profile',
        'icon': Icons.person,
        'color': Colors.brown.shade400 as Color,
        'route': '/shop-profile',
      },
      {
        'title': 'View Bookings',
        'icon': Icons.calendar_today,
        'color': Colors.brown.shade500 as Color,
        'route': '/shop-bookings',
      },
      {
        'title': 'View Payments',
        'icon': Icons.payment,
        'color': Colors.brown.shade600 as Color,
        'route': '/shop-payments',
      },
      {
        'title': 'View Feedback',
        'icon': Icons.feedback,
        'color': Colors.brown.shade700 as Color,
        'route': '/shop-feedback',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop Owner Dashboard"),
        backgroundColor: Colors.brown,
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
    );
  }
}
