import 'package:final_project/pages/signin_page.dart';
import 'package:final_project/pages/signup_page.dart';
import 'package:flutter/material.dart';

class GreetingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: Colors.amber, // Change the color to whatever you prefer
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'lib/Images/Exo_Rental-Noir.png', // Replace with your image asset path
              fit: BoxFit.cover,
            ),
          ),
          // Buttons at the Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // First Button
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black, // Text color
                      side: const BorderSide(color: Colors.transparent), // Grey border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Height of the button
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SigninPage()),
                      );
                    },
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                // Second Button
                Container(
                  width: double.infinity, // Full width of the screen
                  margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white, // Text color
                      side: const BorderSide(color: Colors.transparent), // Grey border
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0), // Height of the button
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
