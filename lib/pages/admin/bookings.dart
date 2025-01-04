import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingsPage extends StatefulWidget {
  @override
  _AdminBookingsPageState createState() => _AdminBookingsPageState();
}

class _AdminBookingsPageState extends State<AdminBookingsPage> {
  Future<List<Map<String, dynamic>>> fetchBookings() async {
    QuerySnapshot bookingsSnapshot =
    await FirebaseFirestore.instance.collection('booking').get();
    return bookingsSnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> removeBooking(String bookingId) async {
    try {
      await FirebaseFirestore.instance.collection('booking').doc(bookingId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking removed successfully.')),
      );
      setState(() {}); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing booking: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Bookings'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching bookings: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No bookings found.'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return ListTile(
                title: Text('Stock ID: ${booking['stockID']}'),
                subtitle: Text('User ID: \n${booking['user']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Date: ${booking['date']}'),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Remove Booking'),
                            content: const Text('Are you sure you want to remove this booking?'),
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
                          await removeBooking(booking['id']);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}