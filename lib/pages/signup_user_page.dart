import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerSignUpPage extends StatefulWidget {
  const CustomerSignUpPage({super.key});

  @override
  State<CustomerSignUpPage> createState() => _CustomerSignUpPageState();
}

class _CustomerSignUpPageState extends State<CustomerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'role': 'customer',
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'phone': _phoneController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign Up failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.brown),
        labelText: label,
        filled: true,
        fillColor: Colors.brown[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) => value!.isEmpty ? '$label is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_add_alt_1,
                      size: 80,
                      color: Colors.brown,
                    ),
                    const SizedBox(height: 25),
                    _buildField(
                      _nameController,
                      'Full Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _emailController,
                      'Email',
                      type: TextInputType.emailAddress,
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _phoneController,
                      'Phone Number',
                      type: TextInputType.phone,
                      icon: Icons.phone,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _passwordController,
                      'Password',
                      obscure: true,
                      icon: Icons.lock,
                    ),
                    const SizedBox(height: 15),
                    _buildField(
                      _confirmPasswordController,
                      'Confirm Password',
                      obscure: true,
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 25),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.brown)
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _signUp,
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Already have an account? Log in",
                        style: TextStyle(color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
