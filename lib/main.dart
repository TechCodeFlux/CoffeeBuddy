import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Pages
//user pages
import 'pages/login_page.dart';
import 'pages/signup_user_page.dart';
import 'pages/user_home_page.dart';
import 'pages/user_profile.dart';
import 'pages/view_book_user.dart';
import 'pages/add_feedback_user.dart';
import 'pages/view_feedback_user.dart';
import 'pages/view_payment_user.dart';
// shop owner pages
import 'pages/signup_shop_page.dart';
import 'pages/shop_home_page.dart';
import 'pages/add_coffee.dart';
import 'pages/view_book_owner.dart';
import 'pages/view_payment_owner.dart';
import 'pages/view_coffee_flavour_owner.dart';
import 'pages/view_feedback_owner.dart';
import 'pages/owner_profile.dart';
// admin pages
import 'pages/admin_home_page.dart';
import 'pages/verify_coffee_shop.dart';
import 'pages/view_coffee_shop.dart';
import 'pages/view_payment_admin.dart';
import 'pages/view_book_admin.dart';
import 'pages/view_feedback_admin.dart';
//
import 'pages/view_coffee_flavour.dart';
import 'pages/ShopDetailsPage.dart';

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
        '/': (context) => const LoadingScreen(), // Start with loader
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginPage(),
        //user pages
        '/signup-user': (context) => const CustomerSignUpPage(),
        '/userhome': (context) => const UserHomePage(),
        '/userprofile': (context) => const UserProfilePage(),
        '/userviewbook': (context) => const UserViewBookPage(),
        '/userviewfeedback': (context) => const UserViewFeedbackPage(),
        '/addfeedbackuser': (context) => const AddFeedbackUserPage(),
        '/userviewpayment': (context) => const UserViewPaymentPage(),
        //shop owner pages
        '/signup-shop': (context) => const ShopOwnerSignupPage(),
        '/shophome': (context) => const ShopHomePage(),
        '/ownerviewbook': (context) => const OwnerViewBookPage(),
        '/ownerviewpayment': (context) => const OwnerViewPaymentPage(),
        '/addcoffee': (context) => const AddCoffeePage(),
        '/viewcoffeeflavourowner': (context) =>
            const ViewCoffeeFlavourOwnerPage(),
        // add owner view history
        '/ownerviewfeedback': (context) => const OwnerViewFeedbackPage(),
        '/ownerprofile': (context) => const ShopOwnerProfilePage(),
        //admin pages
        '/adminhome': (context) => const AdminHomePage(),
        '/verifycoffeeshop': (context) => const VerifyCoffeeShopPage(),
        '/viewcoffeeshop': (context) => const ViewCoffeeShopPage(),
        '/adminviewpayment': (context) => const AdminViewPaymentPage(),
        '/adminviewbook': (context) => const AdminViewBookPage(),
        '/adminviewfeedback': (context) => const AdminViewFeedbackPage(),
        //
        '/viewcoffeeflavour': (context) => const ViewCoffeeFlavourPage(),
        '/shop-details': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as QueryDocumentSnapshot?;
          return ShopDetailsPage(shopData: args!);
        },
      },
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Wait a brief moment to let Firebase restore the session
    await Future.delayed(const Duration(milliseconds: 500));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user logged in → go to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // User logged in → fetch their role (user/shop/admin)
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final role = doc.data()?['role'] ?? 'user';

    if (role == 'shop') {
      Navigator.pushReplacementNamed(context, '/shophome');
    } else if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/adminhome');
    } else {
      Navigator.pushReplacementNamed(context, '/userhome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
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
