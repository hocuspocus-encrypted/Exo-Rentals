import 'dart:convert'; // For Base64 decoding and encoding
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For picking images

class AdminUsersPage extends StatefulWidget {
  @override
  _AdminUsersPageState createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  Future<List<Map<String, dynamic>>> fetchUsers() async {
    QuerySnapshot usersSnapshot =
    await FirebaseFirestore.instance.collection('users').get();
    return usersSnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> removeUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User removed successfully.')),
      );
      setState(() {}); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing user: $e')),
      );
    }
  }

  void showAddUserDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    XFile? profileImage;
    XFile? driversLicenseImage;

    void submitAdd() async {
      if (profileImage == null || driversLicenseImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload both images.')),
        );
        return;
      }

      try {
        // Convert images to Base64
        final profileImageBytes = await profileImage!.readAsBytes();
        final driversLicenseBytes = await driversLicenseImage!.readAsBytes();
        final profileImageBase64 = base64Encode(profileImageBytes);
        final driversLicenseBase64 = base64Encode(driversLicenseBytes);

        // Add new user to Firestore
        await FirebaseFirestore.instance.collection('users').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'profileImage': profileImageBase64,
          'driversLicenseImage': driversLicenseBase64,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully.')),
        );
        setState(() {}); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding user: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    profileImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Image selected.')),
                    );
                  }
                },
                child: const Text('Upload Profile Image'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    driversLicenseImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Driver\'s License Image selected.')),
                    );
                  }
                },
                child: const Text('Upload Driver\'s License Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: submitAdd,
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void showEditUserDialog(Map<String, dynamic> user) {
    final _nameController = TextEditingController(text: user['name']);
    final _emailController = TextEditingController(text: user['email']);
    final _passwordController = TextEditingController(text: user['password']);
    XFile? selectedProfileImage;
    XFile? selectedDriversLicenseImage;

    void submitEdit() async {
      try {
        String? profileImage = user['profileImage']; // Use existing image if not updated
        String? driversLicenseImage = user['driversLicenseImage'];

        if (selectedProfileImage != null) {
          // Convert updated profile image to Base64
          final profileImageBytes = await selectedProfileImage!.readAsBytes();
          profileImage = base64Encode(profileImageBytes);
        }

        if (selectedDriversLicenseImage != null) {
          // Convert updated driver's license image to Base64
          final licenseImageBytes = await selectedDriversLicenseImage!.readAsBytes();
          driversLicenseImage = base64Encode(licenseImageBytes);
        }

        // Delete the old user document
        await FirebaseFirestore.instance.collection('users').doc(user['id']).delete();

        // Add a new user document with the updated info and new email as the document ID
        await FirebaseFirestore.instance.collection('users').doc(_emailController.text).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'profileImage': profileImage,
          'driversLicenseImage': driversLicenseImage,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully.')),
        );
        setState(() {}); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    selectedProfileImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile Image selected.')),
                    );
                  }
                },
                child: const Text('Upload New Profile Image'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final pickedImage =
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    selectedDriversLicenseImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Driver\'s License Image selected.')),
                    );
                  }
                },
                child: const Text('Upload New Driver\'s License Image'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: submitEdit,
            child: const Text('Update User'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Users'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddUserDialog, // Open Add User form
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching users: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['profileImage'] != null
                          ? MemoryImage(base64Decode(user['profileImage']))
                          : null,
                      child: user['profileImage'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(user['name'] ?? 'Unknown'),
                    subtitle: Text('Email: ${user['email'] ?? 'N/A'}'),
                    onTap: () {
                      showEditUserDialog(user);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove User'),
                            content: const Text(
                                'Are you sure you want to remove this user?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Remove'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await removeUser(user['id']);
                        }
                      },
                    ),
                  ),
                  if (user['driversLicenseImage'] != null)
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                            children: [
                              Text('${user['name'] ?? 'Unknown'}\'s Driver License'),
                              Image.memory(
                                base64Decode(user['driversLicenseImage']),
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ]
                        )
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}