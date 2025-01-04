import 'dart:convert'; // For Base64 encoding
import 'dart:io'; // For File handling
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For picking an image from the device

class AdminCarsPage extends StatefulWidget {
  @override
  _AdminCarsPageState createState() => _AdminCarsPageState();
}

class _AdminCarsPageState extends State<AdminCarsPage> {
  final ImagePicker _picker = ImagePicker();

  Future<List<Map<String, dynamic>>> fetchCars() async {
    QuerySnapshot carsSnapshot =
    await FirebaseFirestore.instance.collection('cars').get();
    return carsSnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<void> removeCar(String carId) async {
    try {
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Car removed successfully.')),
      );
      setState(() {}); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing car: $e')),
      );
    }
  }

  Future<int> getNextStockID() async {
    QuerySnapshot carsSnapshot = await FirebaseFirestore.instance.collection('cars').get();
    return carsSnapshot.docs.length + 1; // Next stock ID is the number of cars + 1
  }

  void showAddCarDialog() async {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();
    final _colorController = TextEditingController();
    final _manufacturerController = TextEditingController();
    final _modelController = TextEditingController();
    final _yearController = TextEditingController();
    XFile? selectedImage;

    final int nextStockID = await getNextStockID(); // Auto-generate stock ID

    void submitCar() async {
      if (selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image.')),
        );
        return;
      }

      try {
        // Read the image file and convert it to Base64
        final imageBytes = await selectedImage!.readAsBytes();
        final base64Image = base64Encode(imageBytes);

        final double pricePerDay = double.tryParse(_priceController.text) ?? 0.0;

        await FirebaseFirestore.instance
            .collection('cars')
            .doc(nextStockID.toString()) // Use the next stock ID as the document ID
            .set({
          'stockid': nextStockID,
          'name': _nameController.text,
          'priceperday': pricePerDay,
          'dealprice': pricePerDay, // Default to pricePerDay
          'color': _colorController.text,
          'manufacturer': _manufacturerController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text) ?? 0,
          'ondeal': false, // Default to false
          'image': base64Image,
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car added successfully.')),
        );
        setState(() {}); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding car: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Car'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price Per Day'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
              ),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Pick image from device
                  final pickedImage =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    selectedImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image selected.')),
                    );
                  }
                },
                child: const Text('Upload Image'),
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
            onPressed: submitCar,
            child: const Text('Add Car'),
          ),
        ],
      ),
    );
  }

  void showEditCarDialog(Map<String, dynamic> car) {
    final _nameController = TextEditingController(text: car['name']);
    final _priceController =
    TextEditingController(text: car['priceperday'].toString());
    final _dealPriceController =
    TextEditingController(text: car['dealprice'].toString());
    final _colorController = TextEditingController(text: car['color']);
    final _manufacturerController =
    TextEditingController(text: car['manufacturer']);
    final _modelController = TextEditingController(text: car['model']);
    final _yearController = TextEditingController(text: car['year'].toString());
    bool onDeal = car['ondeal'] ?? false;
    XFile? selectedImage;

    void submitEdit() async {
      try {
        String? base64Image = car['image']; // Use existing image if not updated
        if (selectedImage != null) {
          // Read the updated image and convert to Base64
          final imageBytes = await selectedImage!.readAsBytes();
          base64Image = base64Encode(imageBytes);
        }

        await FirebaseFirestore.instance
            .collection('cars')
            .doc(car['id']) // Use the existing car ID
            .update({
          'name': _nameController.text,
          'priceperday': double.tryParse(_priceController.text) ?? 0.0,
          'dealprice': double.tryParse(_dealPriceController.text) ?? 0.0,
          'color': _colorController.text,
          'manufacturer': _manufacturerController.text,
          'model': _modelController.text,
          'year': int.tryParse(_yearController.text) ?? 0,
          'ondeal': onDeal,
          'image': base64Image, // Update image if a new one is provided
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Car updated successfully.')),
        );
        setState(() {}); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating car: $e')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Car'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price Per Day'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dealPriceController,
                decoration: const InputDecoration(labelText: 'Deal Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: 'Manufacturer'),
              ),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
              ),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('On Deal'),
                value: onDeal,
                onChanged: (value) {
                  setState(() {
                    onDeal = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  // Pick image from device
                  final pickedImage =
                  await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedImage != null) {
                    selectedImage = pickedImage;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('New image selected.')),
                    );
                  }
                },
                child: const Text('Upload New Image'),
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
            child: const Text('Update Car'),
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
        title: const Text('Cars'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddCarDialog, // Open the add car form
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching cars: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cars found.'));
          }

          final cars = snapshot.data!;
          return ListView.builder(
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return ListTile(
                title: Text(car['name'] + ' | StockID - ${car['stockid']}' ?? 'Unknown'),
                subtitle: Text('Price: \$${car['priceperday'] ?? 'N/A'}'),
                onTap: () {
                  // Open edit dialog when car is tapped
                  showEditCarDialog(car);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remove Car'),
                        content: const Text(
                            'Are you sure you want to remove this car?'),
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
                      await removeCar(car['id']);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
