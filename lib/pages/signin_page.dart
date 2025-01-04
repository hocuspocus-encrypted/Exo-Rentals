import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/account_page.dart';
import 'package:final_project/pages/admin/admin.dart';
import 'package:final_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'signup_page.dart'; // Import the SignupPage
import 'package:final_project/main.dart';

class SigninPage extends StatelessWidget {
  SigninPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Function to verify email and password from Firestore
  Future<void> _signInUser(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // Query Firestore for the user document using the email as the document ID
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(email).get();

      // Check if user exists and password matches
      if (userDoc.exists) {
        var userData = userDoc.data();
        String storedPassword = userData?['password'] ?? '';

        if (password == storedPassword) {
          loggedin = true;
          id = email;
          // Password matched, proceed with the login
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage(initialIndex: 0,)),
          );
        } else {
          // Password does not match
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        }
      } else {
        // User does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.black,
        titleTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.amber,
              child: Icon(Icons.person, size: 70, color: Colors.black),
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.grey),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2.0),
                        ),
                      ),
                      style: GoogleFonts.lato(textStyle: const TextStyle(color: Colors.white)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.grey),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2.0),
                        ),
                      ),
                      style: GoogleFonts.lato(textStyle: const TextStyle(color: Colors.white)),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    // Sign in button
                    ElevatedButton(
                      onPressed: () {
                        // Call sign-in function if the form is valid
                        if (_formKey.currentState!.validate()) {
                          _signInUser(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                      ),
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign-up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.lato(
                              textStyle: const TextStyle(color: Colors.amber, fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Floating action button for admin login
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 35.0, bottom: 10.0),
          child: ElevatedButton.icon(
            onPressed: () {
              if (_emailController.text == 'admin' && _passwordController.text == 'admin') {
                // Action for admin login
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Use correct admin credentials')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            icon: const Icon(Icons.admin_panel_settings, color: Colors.black),
            label: Text(
              'Admin Login',
              style: GoogleFonts.lato(
                textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
