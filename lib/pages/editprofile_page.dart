import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class EditProfilePage extends StatefulWidget {
  final String currentEmail;

  EditProfilePage({required this.currentEmail});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? email;
  String? password;
  String? profileImageBase64;
  String? driversLicenseImageBase64;

  File? _profileImageFile;
  File? _driversLicenseImageFile;

  final picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the page is initialized
  }

  // Load user data from Firestore
  void _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentEmail)
        .get();

    if (userDoc.exists) {
      setState(() {
        name = userDoc['name'] ?? '';
        email = userDoc['email'] ?? '';
        password = userDoc['password'] ?? '';
        profileImageBase64 = userDoc['profileImage'] ?? '';
        driversLicenseImageBase64 = userDoc['driversLicenseImage'] ?? '';
      });
    }
  }

  // Pick an image for the profile or driver's license
  Future<void> _pickImage(bool isProfileImage) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isProfileImage) {
          _profileImageFile = File(pickedFile.path);
          profileImageBase64 =
              base64Encode(_profileImageFile!.readAsBytesSync()); // Convert to base64
        } else {
          _driversLicenseImageFile = File(pickedFile.path);
          driversLicenseImageBase64 =
              base64Encode(_driversLicenseImageFile!.readAsBytesSync()); // Convert to base64
        }
      });
    }
  }

  // Save the updated data to Firestore
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true; // Set loading state to true
    });

    _formKey.currentState!.save(); // Save the form data

    try {
      var data = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentEmail)
          .get();

      Map<String, dynamic> updatedData = {
        'name': name ?? data['name'],
        'password': password ?? data['password'],
        'profileImage': profileImageBase64 ?? data['profileImage'],
        'driversLicenseImage': driversLicenseImageBase64 ?? data['driversLicenseImage'],
      };

      // Check if the email has been changed
      if (email != null && email!.isNotEmpty && email != widget.currentEmail) {
        DocumentSnapshot newEmailDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();

        if (newEmailDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('The email address is already in use by another account.')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Delete old email record and update with new email
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentEmail)
            .delete();

        updatedData['email'] = email;

        // Save the updated data with new email
        await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .set(updatedData);
      } else {
        // Just update the existing document if the email is not changed
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentEmail)
            .update(updatedData);
      }

      // Show success message after updating
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(initialIndex: 2,)),
      );
    } catch (e) {
      // Handle error if updating the profile fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading state back to false
      });
    }
  }

  Widget _buildProfileImage() {
    // Display profile image if available, otherwise show a default placeholder
    if (_profileImageFile != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(_profileImageFile!),
      );
    } else if (profileImageBase64 != null &&
        profileImageBase64!.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: MemoryImage(base64Decode(profileImageBase64!)),
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[700],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      );
    }
  }

  Widget _buildDriversLicenseImage() {
    // Display driver's license image if available, otherwise show a placeholder
    if (_driversLicenseImageFile != null) {
      return Image.file(
        _driversLicenseImageFile!,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else if (driversLicenseImageBase64 != null &&
        driversLicenseImageBase64!.isNotEmpty) {
      return Image.memory(
        base64Decode(driversLicenseImageBase64!),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[900],
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.amber,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _pickImage(true), // Trigger picking a profile image
                child: _buildProfileImage(),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[850],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.amber, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  name = value; // Save the name value
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[850],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.amber, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  email = value; // Save the email value
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.amber),
                  filled: true,
                  fillColor: Colors.grey[850],
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                    BorderSide(color: Colors.amber, width: 2.0),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                obscureText: true, // Hide password text
                onSaved: (value) {
                  password = value; // Save the password value
                },
              ),
              const SizedBox(height: 16.0),
              GestureDetector(
                onTap: () => _pickImage(false), // Trigger picking a driver's license image
                child: _buildDriversLicenseImage(),
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _saveChanges, // Save changes to Firestore
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
