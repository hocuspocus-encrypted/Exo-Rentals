import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupPageState createState() => SignupPageState();
}

class SignupPageState extends State<SignupPage> {
  File? _imagePP; // Profile Picture
  File? _imageDL; // Driver's License
  String? _base64PP;
  String? _base64DL;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true; // Toggle password visibility

  bool isLoading = false; // Loading state

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'signup_channel',
      'Signup Notifications',
      channelDescription: 'Notification for successful signup',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Signup Successful',
      'Your account has been created!',
      platformDetails,
    );
  }

  Future<void> _pickImage(bool isProfilePicture) async {
    final ImagePicker _picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.amber),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.amber),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          if (isProfilePicture) {
            _imagePP = File(image.path);
            _base64PP = base64Encode(_imagePP!.readAsBytesSync());
          } else {
            _imageDL = File(image.path);
            _base64DL = base64Encode(_imageDL!.readAsBytesSync());
          }
        });
      }
    }
  }

  Future<void> _submitData() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim().toLowerCase();
    final String password = _passwordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _imagePP == null ||
        _imageDL == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields and images are required.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if a user with the same email already exists
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userDoc.exists) {
        // Email is already in use
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('An account with this email already exists.')),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Proceed to create new user
      await FirebaseFirestore.instance.collection('users').doc(email).set({
        'name': name,
        'email': email,
        'password': password,
        'profileImage': _base64PP ?? '',
        'driversLicenseImage': _base64DL ?? '',
      });

      await _showNotification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up successful!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.amber),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: GoogleFonts.lato(
                  textStyle: const TextStyle(color: Colors.grey),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.amber, width: 2.0),
                ),
              ),
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            TextField(
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
                  borderSide:
                  BorderSide(color: Colors.amber, width: 2.0),
                ),
              ),
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.lato(
                  textStyle: const TextStyle(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                  BorderSide(color: Colors.amber, width: 2.0),
                ),
              ),
              style: GoogleFonts.lato(
                  textStyle: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Sections in a Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Profile Picture Section
                    Column(
                      children: [
                        Text(
                          'Upload Profile Picture',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _imagePP == null
                                ? const Center(
                                child: Icon(Icons.person,
                                    size: 50, color: Colors.grey))
                                : ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8),
                              child: Image.file(_imagePP!,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Driver's License Section
                    Column(
                      children: [
                        Text(
                          'Upload Driver\'s License',
                          style: GoogleFonts.lato(
                            textStyle: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _pickImage(false),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _imageDL == null
                                ? const Center(
                              child: Icon(Icons.document_scanner,
                                  size: 50, color: Colors.grey),
                            )
                                : ClipRRect(
                              borderRadius:
                              BorderRadius.circular(8),
                              child: Image.file(_imageDL!,
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _submitData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(
                    horizontal: 100, vertical: 15),
              ),
              icon: const Icon(Icons.check, color: Colors.black),
              label: Text(
                'Submit',
                style: GoogleFonts.lato(
                  textStyle:
                  const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
