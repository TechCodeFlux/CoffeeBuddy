import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_feedback_user.dart';
import 'view_feedback_user.dart';
import 'user_profile.dart';
import 'shops_page.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late List<Widget> _pages;
  String? _userId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
    }

    _pages = [
      const ShopsPage(),
      const HistoryPage(),
      const PaymentsPage(),
      const FeedbackPage(),
      // Pass userId safely; show a fallback if null
      _userId != null
          ? ProfilePage(userId: _userId!)
          : const Center(child: Text("User not logged in")),
    ];
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.brown[300],
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Shops"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: "Feedback",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// ------------------- Shops Page -------------------
class ShopsTab extends StatelessWidget {
  const ShopsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly return the new ShopsPage widget
    return const ShopsPage();
  }
}

// ------------------- History Page -------------------
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Text(
          "User's Order History",
          style: TextStyle(color: Colors.brown[700], fontSize: 20),
        ),
      ),
    );
  }
}

// ------------------- Payments Page -------------------
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.brown,
      ),
      body: Center(
        child: Text(
          "User's Payment History",
          style: TextStyle(color: Colors.brown[700], fontSize: 20),
        ),
      ),
    );
  }
}

// ------------------- Feedback Page -------------------
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3F0),
      appBar: AppBar(
        title: const Text("Feedback"),
        backgroundColor: Colors.brown[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "We value your feedback ☕",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Help us improve your coffee experience.",
              style: TextStyle(color: Colors.brown, fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Add Feedback Card
            _buildFeedbackCard(
              context,
              icon: Icons.rate_review,
              title: "Add Feedback",
              subtitle: "Share your thoughts about a shop",
              color: Colors.brown[400]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddFeedbackUserPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // View Feedback Card
            _buildFeedbackCard(
              context,
              icon: Icons.feedback_outlined,
              title: "View My Feedback",
              subtitle: "Check what you’ve shared previously",
              color: Colors.brown[300]!,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserViewFeedbackPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Info / Tip Card
            Container(
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.lightbulb, color: Colors.brown, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Your feedback helps us serve you better and improve shop quality.",
                      style: TextStyle(
                        color: Colors.brown,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 28,
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// ------------------- Profile Page -------------------
class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return UserProfilePage(); // Redirects to user_profile.dart
  }
}
