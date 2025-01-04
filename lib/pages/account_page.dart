import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'editprofile_page.dart';
import 'review_page.dart';

class AccountInfoPage extends StatefulWidget {
  final String userID;

  const AccountInfoPage({super.key, required this.userID});

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  // Fetch user data from Firestore
  Future<Map<String, dynamic>> fetchUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userID).get();
    return userDoc.data() as Map<String, dynamic>;
  }

  // Fetch the list of bookings for the current user from Firestore
  Future<List<Map<String, dynamic>>> fetchUserBookings() async {
    QuerySnapshot bookingDocs = await FirebaseFirestore.instance
        .collection('booking')
        .where('user', isEqualTo: widget.userID)
        .get();
    return bookingDocs.docs
        .map((doc) => {
      'id': doc.id,
      'stockID': doc['stockID'] ?? 'N/A',
      'date': doc['date'] ?? 'N/A',
    })
        .toList();
  }

  // Fetch car details based on the stockID from Firestore
  Future<Map<String, dynamic>> fetchCarDetails(String stockID) async {
    try {
      DocumentSnapshot carDoc = await FirebaseFirestore.instance.collection('cars').doc(stockID).get();
      return carDoc.exists ? carDoc.data() as Map<String, dynamic> : {};
    } catch (e) {
      throw Exception('Error fetching car details: $e');
    }
  }

  // Remove a booking from Firestore
  Future<void> removeBooking(String bookingID) async {
    try {
      await FirebaseFirestore.instance.collection('booking').doc(bookingID).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking removed successfully.')));
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error removing booking: $e')));
    }
  }

  // Sign out the user and navigate to the home page
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(initialIndex: 0,)),
      );
      loggedin = false;
      id = '';
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed Out')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(), // Fetch user data asynchronously
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.amber)));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching user data.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found.'));
          }

          final userData = snapshot.data!;
          final String name = userData['name'] ?? 'N/A';
          final String email = userData['email'] ?? 'N/A';
          final String profileImageBase64 = userData['profileImage'] ?? '';
          final String dlImageBase64 = userData['driversLicenseImage'] ?? '';
          final profileImage = const Base64Decoder().convert(profileImageBase64);
          final dlImage = const Base64Decoder().convert(dlImageBase64);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            child: Column(
              children: [
                Row(
                  children: [
                    // Display user's profile picture if available
                    profileImage.isNotEmpty
                        ? CircleAvatar(radius: 40, backgroundImage: MemoryImage(profileImage))
                        : const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50, color: Colors.grey)),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 8.0),
                          Text(email, style: const TextStyle(fontSize: 16.0, color: Colors.white70)),
                        ],
                      ),
                    ),
                    // Button to navigate to the profile editing page
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentEmail: id,)));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25.0),
                // Display driver's license image if available
                Text(
                  'Driver\'s License',
                  style: GoogleFonts.lato(textStyle: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                dlImage.isNotEmpty
                    ? Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Image.memory(dlImage, fit: BoxFit.cover),
                )
                    : Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey)),
                  child: const Center(child: Icon(Icons.document_scanner, size: 40, color: Colors.grey)),
                ),
                const SizedBox(height: 35.0),
                // Buttons to write a review or sign out
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewPage()));
                        },
                        icon: const Icon(Icons.rate_review, color: Colors.black),
                        label: Text('Write a Review', style: GoogleFonts.lato(textStyle: const TextStyle(color: Colors.black, fontSize: 16))),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => signOut(context), // Sign out the user
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: Text('Sign Out', style: GoogleFonts.lato(textStyle: const TextStyle(color: Colors.black, fontSize: 16))),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 10)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35.0),
                const SizedBox(width: double.infinity, child: Divider(color: Colors.grey, thickness: 1.0)),
                const Text('Your Bookings', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.amber)),
                const SizedBox(height: 8.0),
                // Fetch and display user bookings
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchUserBookings(),
                  builder: (context, bookingSnapshot) {
                    if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (bookingSnapshot.hasError) {
                      return const Text('Error fetching bookings.');
                    } else if (!bookingSnapshot.hasData || bookingSnapshot.data!.isEmpty) {
                      return const Text('No bookings found.');
                    }

                    final bookings = bookingSnapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        final String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['date']));

                        return FutureBuilder<Map<String, dynamic>>(
                          future: fetchCarDetails(booking['stockID']), // Fetch car details for each booking
                          builder: (context, carSnapshot) {
                            if (carSnapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (carSnapshot.hasError || !carSnapshot.hasData || carSnapshot.data!.isEmpty) {
                              return ListTile(
                                title: const Text('Car details unavailable'),
                                subtitle: Text('Booking Date: $formattedDate'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await removeBooking(booking['id']); // Remove booking if needed
                                  },
                                ),
                              );
                            }

                            final car = carSnapshot.data!;
                            return ListTile(
                              leading: const Icon(Icons.car_rental),
                              title: Text('${car['manufacturer']} ${car['name']}${(car['model'] != null && car['model'].isNotEmpty) ? ' ${car['model']}' : ''}', style: const TextStyle(color: Colors.white)),
                              subtitle: Text('Date: $formattedDate', style: const TextStyle(color: Colors.grey)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await removeBooking(booking['id']); // Remove booking if needed
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
