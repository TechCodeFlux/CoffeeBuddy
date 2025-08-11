import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
import 'pages/login_page.dart';
import 'pages/signup_user_page.dart';
import 'pages/signup_shop_page.dart';
import 'pages/user_home_page.dart';
import 'pages/shop_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coffee Buddy',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.brown[50],
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
        '/signup-user': (context) => const CustomerSignUpPage(),
        '/signup-shop': (context) => const ShopOwnerSignupPage(),
        '/userhome': (context) => const UserHomePage(),
        '/shophome': (context) => const ShopHomePage(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color.fromARGB(255, 93, 45, 29),
                  child: Icon(Icons.coffee, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Coffee Buddy",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Brew connections over coffee ☕",
                  style: TextStyle(fontSize: 16, color: Colors.brown[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Login button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text("Log In", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 15),

                // Sign Up button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.brown),
                    foregroundColor: Colors.brown,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _showSignupOptions(context);
                  },
                  child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignupOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Account Type",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.brown),
                title: const Text("Customer"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/signup-user');
                },
              ),
              ListTile(
                leading: const Icon(Icons.store, color: Colors.brown),
                title: const Text("Shop Owner"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/signup-shop');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
