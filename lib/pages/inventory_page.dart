import 'dart:convert'; // For Base64 encoding/decoding
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'book_page.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  late Future<List<Car>> futureCars;

  @override
  void initState() {
    super.initState();
    futureCars = fetchCarsFromFirestore(); // Fetch cars on initialization
  }

  // Fetch car data from Firestore
  Future<List<Car>> fetchCarsFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('cars').get();
      return snapshot.docs.map((doc) {
        return Car(
          stockID: doc.id, // Fetch stockID from document ID
          name: doc['name'] ?? 'Unnamed Car',
          imageUrl: doc['image'] ?? '',
          manuf: doc['manufacturer'] ?? '',
          model: doc['model'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '/////',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 21, // Smaller size for slashes
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20), // Adds some spacing between the slashes and text
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ' Explore Cars ',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 30, // Larger size for the main text
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20), // Adds some spacing between the text and slashes
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '/////',
                  style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 21, // Smaller size for slashes
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 12, right: 12, bottom: 8),
            child: FutureBuilder<List<Car>>(
              future: futureCars,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading cars: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No cars available',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                } else {
                  final cars = snapshot.data!;
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return CarCard(car: cars[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decodedBytes = base64Decode(car.imageUrl);

    return Card(
      color: Colors.white10,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingPage(stockID: car.stockID),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.memory(
                decodedBytes,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                car.manuf.isNotEmpty
                    ? "${car.manuf} ${car.name} ${car.model}"
                    : car.name,
                style: GoogleFonts.lato(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Car model class to hold Firestore data
class Car {
  final String stockID; // Unique identifier for the car document
  final String name;
  final String imageUrl;
  final String manuf;
  final String model;

  Car({
    required this.stockID,
    required this.name,
    required this.imageUrl,
    required this.manuf,
    required this.model,
  });
}
