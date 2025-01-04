import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'signin_page.dart';

class BookingPage extends StatefulWidget {
  final String stockID;

  const BookingPage({Key? key, required this.stockID}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  bool? isAvailable;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String carImage = '';
  String carName = '';
  String carColor = '';
  String carManuf = '';
  String carModel = '';
  bool carOnDeal = false;
  double carPrice = 0.0;
  double dealPrice = 0.0;
  int carYear = 0;

  @override
  void initState() {
    super.initState();
    _fetchCarDetails(widget.stockID);
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _fetchCarDetails(String stockID) async {
    try {
      var carDoc = await FirebaseFirestore.instance.collection('cars').doc(stockID).get();

      if (carDoc.exists) {
        setState(() {
          carImage = carDoc['image'] ?? '';
          carName = carDoc['name'] ?? 'Name not available';
          carColor = carDoc['color'] ?? 'Color info not available';
          carManuf = carDoc['manufacturer'] ?? 'Manufacturer info not available';
          carModel = carDoc['model'] ?? 'Generic';
          carOnDeal = carDoc['ondeal'] ?? false;
          carPrice = carDoc['priceperday']?.toDouble() ?? 0.0;
          dealPrice = carDoc['dealprice']?.toDouble() ?? carPrice;
          carYear = carDoc['year'] ?? 0;
        });
      } else {
        setState(() {
          carName = 'Car not found';
          carPrice = 0.0;
        });
      }
    } catch (e) {
      setState(() {
        carName = 'Error loading car details';
        carPrice = 0.0;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    try {
      QuerySnapshot reviewDocs = await FirebaseFirestore.instance
          .collection('reviews')
          .where('stockID', isEqualTo: widget.stockID)
          .get();

      return reviewDocs.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!loggedin) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SigninPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to proceed')),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 1),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.white10,
                onPrimary: Colors.amber,
                onSurface: Colors.amber,
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amber,
                ),
              ),
            ),
            child: child!,
          );
        });

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        isAvailable = null;
      });

      try {
        var bookingQuery = await FirebaseFirestore.instance
            .collection('booking')
            .where('stockID', isEqualTo: widget.stockID)
            .where('date', isEqualTo: picked.toIso8601String())
            .get();

        if (bookingQuery.docs.isNotEmpty) {
          setState(() {
            isAvailable = false;
          });
        } else {
          await FirebaseFirestore.instance.collection('booking').add({
            'user': id,
            'stockID': widget.stockID,
            'date': picked.toIso8601String(),
          });

          _showNotification();
          setState(() {
            isAvailable = true;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking or adding booking: $e')),
        );
      }
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'booking_channel',
      'Booking Notifications',
      channelDescription: 'Notifications for booking updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Booking Completed',
      'Your booking for $carName on ${selectedDate!.toLocal()} is confirmed.',
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(carImage);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: carName.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: SizedBox(
                child: carImage.isNotEmpty
                    ? Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover, width: double.infinity, height: 400)
                    : const Icon(Icons.car_repair, size: 100),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              carModel != 'Generic' ? "$carManuf $carName $carModel" : "$carManuf $carName",
              style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
            const SizedBox(height: 10),
            Text('Color: $carColor', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            Text('Manufacturer: $carManuf', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            Text('Model: $carModel', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            Text('Year: $carYear', style: const TextStyle(fontSize: 16, color: Colors.white70)),
            const SizedBox(height: 30),
            if (selectedDate != null)
              Column(
                children: [
                  Text(
                    isAvailable == null
                        ? "Checking availability..."
                        : isAvailable!
                        ? "Booked for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                        : "Not available for ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isAvailable == null
                          ? Colors.black
                          : isAvailable!
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            Center(
              child: Text(
                'Reviews',
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text("Error loading reviews");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text("No reviews available");
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var review = snapshot.data![index];
                      return ListTile(
                        title: Text(review['username']),
                        subtitle: Text(review['review']),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
