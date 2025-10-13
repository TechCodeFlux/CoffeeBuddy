import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pages
import 'user_home_page.dart';
import 'shop_home_page.dart';
import 'admin_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _isPasswordVisible = false; // 👁️ Added toggle variable

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedInEmail', email);
  }

  Future<void> _redirectBasedOnRole(User user) async {
    try {
      setState(() => _isLoading = true);

      await _saveEmail(user.email ?? "");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final role = data?['role'];
        final status = data?['status'];

        if (role == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const UserHomePage()),
          );
        } else if (role == 'shop_owner') {
          if (status == 'verified') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ShopHomePage()),
            );
          } else {
            await _auth.signOut();
            _showMessage("Wait for the admin's approval before logging in.");
          }
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminHomePage()),
          );
        } else {
          _showMessage("Unknown role. Contact support.");
        }
      } else {
        _showMessage("User profile not found.");
      }
    } catch (e) {
      _showMessage("Error reading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password");
      return;
    }

    // Default admin login
    if (email == "admin" && password == "admin") {
      await _saveEmail(email);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminHomePage()),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _redirectBasedOnRole(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "Incorrect password. Please try again.";
      } else if (e.code == 'user-not-found') {
        message = "No account found for that email.";
      } else {
        message = "Login failed. Please try again.";
      }
      _showMessage(message);
    } catch (e) {
      _showMessage("Something went wrong: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _redirectBasedOnRole(userCredential.user!);
      }
    } catch (e) {
      _showMessage("Google Sign-In failed. Please try again.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showMessage("Please enter your email to reset password");
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showMessage("Password reset email sent");
    } catch (e) {
      _showMessage("Failed to send reset email: $e");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            "Message",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK", style: TextStyle(color: Colors.brown)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Icon(Icons.coffee, size: 80, color: Colors.brown),
                  const SizedBox(height: 10),
                  const Text(
                    "Coffee Buddy",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Welcome back! Please log in.",
                    style: TextStyle(color: Colors.brown[600]),
                  ),
                  const SizedBox(height: 30),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.brown,
                              ),
                              labelText: "Email / Username",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _passwordController,
                            obscureText:
                                !_isPasswordVisible, // 👁️ toggled here
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.brown,
                              ),
                              labelText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.brown,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.brown),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _signInWithEmail,
                            child: const Text("Log In"),
                          ),
                          const SizedBox(height: 15),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              side: const BorderSide(color: Colors.brown),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _signInWithGoogle,
                            icon: Image.asset(
                              'assets/google_logo.png',
                              height: 24,
                            ),
                            label: const Text(
                              "Sign in with Google",
                              style: TextStyle(color: Colors.brown),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading Spinner
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.brown),
              ),
            ),
        ],
      ),
    );
  }
}
