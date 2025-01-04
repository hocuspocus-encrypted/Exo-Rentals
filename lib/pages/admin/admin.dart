import 'package:flutter/material.dart';
import 'cars.dart';
import 'users.dart';
import 'bookings.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200, // Set a fixed width for all buttons
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminCarsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Set the background color to grey
                  foregroundColor: Colors.amber, // Set the text color to amber
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Cars'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Ensure the same width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminUsersPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Set the background color to grey
                  foregroundColor: Colors.amber, // Set the text color to amber
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Users'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 200, // Same width for consistency
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminBookingsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Set the background color to grey
                  foregroundColor: Colors.amber, // Set the text color to amber
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Bookings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}