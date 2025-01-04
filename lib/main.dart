import 'package:final_project/pages/account_page.dart';
import 'package:final_project/pages/greeting_page.dart';
import 'package:final_project/pages/inventory_page.dart';
import 'package:final_project/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

var loggedin = false;
var id;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(initialIndex: 0,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int initialIndex;

  const MyHomePage({Key? key, required this.initialIndex}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Getter for pages
  List<Widget> get _pages {
    return [
      HomePage(),
      InventoryPage(),
      loggedin
          ? AccountInfoPage(userID: id)
          : const SizedBox
          .shrink(), // Render empty widget if the user is not logged in
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Function to handle navigation
  void _onItemTapped(int index) {
    if (index == 2 && !loggedin) {
      // Push SigninPage if not logged in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GreetingPage()),
      );
    } else {
      // Update selected index for Home and Inventory
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(57),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          title: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset(
                  'lib/Images/7.png',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex], // Show the page based on the selected index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Current selected index
        onTap: _onItemTapped, // Update index on tap
        backgroundColor: Colors.black, // Set the background color to black
        selectedItemColor: Colors.amber, // Set the selected icon and text color to amber
        unselectedItemColor: Colors.white60, // Set unselected icon and text color to a lighter white
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}