import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _commentController = TextEditingController();
  final ValueNotifier<double> _ratingNotifier = ValueNotifier<double>(0);

  bool _isSubmitting = false;
  String? _selectedCarStockID; // For storing the selected car's stock ID
  String? _selectedCarDisplayName; // For storing the selected car's display name
  String? _userID;

  @override
  void initState() {
    super.initState();
    _userID = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<List<Map<String, dynamic>>> fetchCars() async {
    try {
      QuerySnapshot carSnapshot =
      await FirebaseFirestore.instance.collection('cars').get();
      return carSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'stockID': doc.id,
          'displayName': data['model'] != null
              ? '${data['manufacturer']} ${data['name']} ${data['model']}'
              : '${data['manufacturer']} ${data['name']}',
        };
      }).toList();
    } catch (error) {
      print('Error fetching cars: $error');
      return [];
    }
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      FirebaseFirestore firestore = FirebaseFirestore.instance;

      try {
        await firestore.collection('reviews').add({
          'stockID': _selectedCarStockID, // Store the stockID for reference
          'car': _selectedCarDisplayName, // Car display name
          'user': id, // Current user's ID
          'rating': _ratingNotifier.value,
          'comment': _commentController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          _isSubmitting = false;
          _commentController.clear();
          _selectedCarStockID = null;
          _selectedCarDisplayName = null;
          _ratingNotifier.value = 0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } catch (error) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting review: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Reviews',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('reviews')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.amber,
                        color: Colors.amber,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No reviews yet.',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  var reviews = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review = reviews[index];
                      return Card(
                        color: Colors.grey[900],
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['comment'],
                                style: GoogleFonts.lato(
                                  textStyle: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Car: ${review['car']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Text(
                                'User: ${review['user']}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  const Text(
                                    'Rating: ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating: review['rating'].toDouble(),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    unratedColor: Colors.grey[700],
                                    itemBuilder: (context, index) =>
                                    const Icon(Icons.star, color: Colors.amber),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const Padding(padding: EdgeInsets.only(top: 15),
            child: SizedBox(
              width: double.infinity, // Full width of the parent
              child: Divider(
                color: Colors.grey,
                thickness: 1.0,
              ),
            ),
    ),

            Padding(

              padding: const EdgeInsets.only(top: 15),

              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchCars(),
                      builder: (context, carSnapshot) {
                        if (carSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (carSnapshot.hasError) {
                          return const Text(
                            'Error loading cars.',
                            style: TextStyle(color: Colors.white),
                          );
                        }

                        final cars = carSnapshot.data ?? [];
                        return DropdownButtonFormField<String>(
                          dropdownColor: Colors.grey[900],
                          value: _selectedCarStockID,
                          items: cars.map((car) {
                            return DropdownMenuItem<String>(
                              value: car['stockID'],
                              child: Text(
                                car['displayName'],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCarStockID = value;
                              _selectedCarDisplayName = cars
                                  .firstWhere(
                                      (car) => car['stockID'] == value)['displayName'];
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Select Vehicle',
                            labelStyle: const TextStyle(color: Colors.amber),
                            filled: true,
                            fillColor: Colors.grey[850],
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a car';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        labelText: 'Your Comment',
                        labelStyle: const TextStyle(color: Colors.amber),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: const OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.grey),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<double>(
                      valueListenable: _ratingNotifier,
                      builder: (context, rating, child) {
                        return RatingBar.builder(
                          initialRating: rating,
                          unratedColor: Colors.grey[700],
                          glowColor: Colors.amber[300],
                          minRating: 1,
                          itemSize: 40.0,
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemPadding:
                          const EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (newRating) {
                            _ratingNotifier.value = newRating;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: _isSubmitting
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                          'Submit Review',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
