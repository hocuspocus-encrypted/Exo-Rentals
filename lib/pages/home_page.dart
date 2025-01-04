import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/pages/book_page.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

// Add a button beside 'RENT YOUR DREAMS'
class _HomePageState extends State<HomePage> {
  late Future<List<Car>> futureCars;
  List<Car> allCars = []; // To hold the full list of cars
  List<Car> filteredCars = []; // This will hold the filtered cars based on search
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    futureCars = fetchCarsFromFirestore(); // Fetch cars on initialization
  }

  // Fetch car data from Firestore
  Future<List<Car>> fetchCarsFromFirestore() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('cars').get();
      List<Car> cars = snapshot.docs.map((doc) {
        return Car(
          name: doc['name'] ?? 'Unnamed Car',
          imageUrl: doc['image'] ?? '',
          hasDeal: doc['ondeal'] ?? false,
          price: (doc['priceperday'] ?? 0).toDouble(),
          stockID: doc.id,
          manufacturer: doc['manufacturer'] ?? 'Unknown Manufacturer',
          model: doc['model'] ?? 'Unknown Model',
          dealPrice: (doc['dealprice'] ?? 0).toDouble(),
        );
      }).toList();

      // Store the full list of cars for searching
      setState(() {
        allCars = cars;
        filteredCars = cars.where((car) => car.hasDeal).toList(); // Initially show only cars on deal
      });

      return cars;
    } catch (e) {
      throw Exception('Failed to fetch cars: $e');
    }
  }

  // Apply search filter immediately when the text changes
  void _filterCars(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, show only the cars on deal
        filteredCars = allCars.where((car) => car.hasDeal).toList();
      } else {
        // If the search query is not empty, show all cars that match the query, regardless of deal status
        filteredCars = allCars
            .where((car) =>
        car.name.toLowerCase().contains(query.toLowerCase()) ||
            car.manufacturer.toLowerCase().contains(query.toLowerCase()) ||
            car.model.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          FutureBuilder<List<Car>>(
            future: futureCars,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading cars: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No cars available'));
              } else {
                final cars = filteredCars;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterCars, // Trigger the filter on text change
                            decoration: InputDecoration(
                              hintText: 'Car, Manufacturer, or Model',
                              hintStyle: GoogleFonts.lato (textStyle: const TextStyle(color: Colors.grey),), // Light blue text placeholder
                              prefixIcon: const Icon(Icons.search, color: Colors.amber), // light blue search icon
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.amber),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.amber), // Light blue border when not focused
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: const BorderSide(color: Colors.amber, width: 2), // Thicker amber
                              ),
                            ),
                            style: const TextStyle(color: Colors.amber), // light blue text inside search
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Exotic Deals'
                                : 'Search Results',
                            style: GoogleFonts.lato (textStyle: const TextStyle(fontSize: 33, fontWeight: FontWeight.bold, color: Colors.amber)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            height: 500.0, // Adjust the height as per your content
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: cars.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BookingPage(stockID: cars[index].stockID), // Pass stockID dynamically
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16.0),
                                    child: CarCard(car: cars[index]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            ' ////////// ',
                            style: GoogleFonts.lato(
              textStyle:const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber),
                          ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}


class Car {
  final String name;
  final String imageUrl;
  final String stockID;
  final double price;
  final bool hasDeal;
  final double dealPrice;
  final String manufacturer;  // Added manufacturer field
  final String model;  // Added model field

  Car({
    required this.name,
    required this.imageUrl,
    required this.stockID,
    required this.price,
    required this.hasDeal,
    required this.dealPrice,
    required this.manufacturer,
    required this.model,
  });
}

class CarCard extends StatelessWidget {
  final Car car;

  const CarCard({Key? key, required this.car}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decodedBytes = base64Decode(car.imageUrl);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white10, // Card background color
        border: Border.all(color: Colors.transparent, width: 1.25), // Border with grey color
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flexible Image Section
          Flexible(
            flex: 5, // Image section takes 3 parts of the space
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 19, // Maintain aspect ratio for images
                child: Image.memory(
                  decodedBytes,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Flexible Text Section
          Flexible(
            flex: 1, // Text section takes 1 part of the space
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Ensures the text content doesn't take excessive space
                children: [
                  Text(
                    '  ${car.name}',
                style: GoogleFonts.lato (textStyle: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber, // Text color for car name
                    ),),
                    maxLines: 1, // Ensures text doesn't overflow
                    overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
                  ),
                  const SizedBox(height: 4.0), // Add spacing between name and price
                  Text(
                    car.hasDeal
                        ? '  [ Deal Price ] : \$${car.dealPrice.toStringAsFixed(2)}'
                        : '  Price : \$${car.price.toStringAsFixed(2)}',
                    style: GoogleFonts.lato (textStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey, // Text color for price
                    ),
                    ),
                    maxLines: 1, // Ensures text doesn't overflow
                    overflow: TextOverflow.ellipsis, // Adds "..." if text overflows
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
