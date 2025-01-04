# ExoRental - Exotic Car Rental App

Welcome to **ExoRental**, an exotic car rental mobile application built using Flutter. This app allows users to explore a wide range of luxury cars, book them for rental, and share reviews. It integrates with Firebase for backend services like authentication, Firestore database, and storage.

## Table of Contents
- [Features](#features)
- [Special Features and Innovations](#special-features-and-innovations)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Firebase Setup](#firebase-setup)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Dependencies](#dependencies)
- [Contributing](#contributing)
- [License](#license)

## Features
- **User Authentication**: Sign up and sign in using email and password.
- **Profile Management**: Users can upload profile pictures and driver's license images.
- **Explore Cars**: Browse a catalog of exotic cars with detailed information.
- **Search Functionality**: Search cars by name, manufacturer, or model.
- **Special Deals**: Highlight cars on special deals.
- **Booking System**: Book cars for specific dates, with availability checks.
- **Reviews and Ratings**: Users can write reviews and rate cars they have rented.
- **User Account**: View and manage personal bookings and account information.
- **Admin Panel**: Manage cars, users, and bookings.
- **Notifications**: Local notifications for booking confirmations and sign-up success.
- **Firebase Integration**: Uses Firebase services for backend functionalities.

## Special Features and Innovations

### Storing Images as Base64 Strings in Firestore
- **Efficient Image Handling**: Images are converted to Base64 strings and stored directly in Firestore.
- **Simplified Retrieval**: Improves image loading times by eliminating Firebase Storage calls.
- **Optimized for Small Images**: Ideal for profile pictures, driver's licenses, and car thumbnails.

### Editing User Email and Profile
- **Dynamic Email Update**: Users and admins can edit user emails, updating document IDs in Firestore.
- **Comprehensive Profile Editing**: Users can update personal info, profile pictures, and driver's licenses.

### Comprehensive Admin Panel
- **Admin Authentication**: Special admin login (`admin`/`admin`) provides access to administrative functionalities.
- **Manage Cars**: Add, update, or remove cars, set special deals, and pricing.
- **Manage Users**: View, add, edit, or remove user accounts.
- **Manage Bookings**: View and remove bookings as necessary.

### Out-of-the-Box Problem Solving
- **Custom Booking System**: Real-time availability checks using Firestore queries.
- **Local Notifications**: Immediate feedback on bookings and sign-ups using `flutter_local_notifications`.
- **Direct Firestore Queries**: Efficient search and filter functionalities with indexed queries.
- **Dynamic Admin Features**: Seamlessly integrates admin functionalities for managing data and users.

## Getting Started

### Prerequisites
- **Flutter SDK**: [Install Flutter](https://flutter.dev/docs/get-started/install).
- **Dart SDK**: Included with Flutter.
- **Android Studio or Visual Studio Code**: Recommended IDEs.
- **Firebase Account**: Set up a Firebase project.

### Installation
- **Install Flutter Dependencies**: 
    ```bash
    flutter pub get
    ```
## Firebase Setup

### Create a Firebase Project:
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project and follow the setup instructions.

### Add Firebase to Your App:
- **For Android**:  
  Download `google-services.json` and place it in the `android/app` directory.
  
- **For iOS**:  
  Download `GoogleService-Info.plist` and place it in the `ios/Runner` directory.

### Enable Firebase Services:
1. **Authentication**:  
   Enable **Email/Password Authentication** in the Firebase Console.
2. **Firestore Database**:  
   Create the following Firestore collections:
   - `users`
   - `cars`
   - `bookings`
   - `reviews`

### Initialize Firebase in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```
### Run the project
- 
    ```bash
    flutter pub get
    ```

# Usage

### main.dart
- Contains the bottom navigation for the three main pages: Home, Inventory, and Account.
- Also holds the app bar at the top displaying the Exo Rental logo.

### Home Page
- The home page displaying the special "Exotic" rental deals of the day which the user can scroll sideways to view. 
- Search functionality to search for a specific car by it's name, manufacturer, or model.
- Tapping on a car takes user booking page.

<img src="screenshots/Homepage.png" alt="Home Page" width="150">

### Inventory Page
- Scroll down on the inventory page to explore all available cars.
- Tapping on a car will take you to the car booking page.

<img src="screenshots/Inventory.png" alt="Inventory" width="150">

### Greeting Page
- Tapping on the Account page while there's no user logged in will take you to the greetings page. 
- Displays the Exo Rental logo and gives the user a sense of how it will feel to use and rent from the app.
- Has buttons for Sign Up and Log In which takes user to those respective pages.

<img src="screenshots/Greeting.png" alt="Greeting" width="150">

### Sign Up
- Create a new account by filling in the required fields. 
- Allows the user to upload profile and driver's license photos.
- Gives the user the option to upload from the camera or gallery.


<img src="screenshots/Signup.png" alt="Sign-Up" width="150">
<img src="screenshots/SelectingPicture.png" alt="Selecting Photo" width="150">

### Sign In
- Log in using your email and password.
- Allows navigation to the Sign Up page as well 

<img src="screenshots/Signin.png" alt="Sign-In" width="150">

### Booking Page
- Tapping on the car cards from either the Home or the Inventory page takes user to the Booking Page
- Holds more information on the selected car such as: name, colour, manufacturer, model, and year. 
- Displays reviews section containing reviews for that specific car.
- Bottom section displays the rental cost per day and a button to book the car.
- Tapping the "Select Date to Book" button will display a calendar in which the user can pick the date to book.

<img src="screenshots/Book.png" alt="Booking Page" width="150">
<img src="screenshots/BookingCalendar.png" alt="Booking-Calendar" width="150">

### Account Page
- Access your account page to see your bookings, edit your profile, or write reviews. 
- Sign out button.
- Allows user to cancel their bookings.

<img src="screenshots/Account.png" alt="Account" width="150">

### Edit Profile Page
- Allows user to edit their profile.
- Able to change their name, email, password, profile and driver's license photos, and save them
- The email change is handled cautiously as it is used as the document ID for individual fields in user's table.
    - So when user's make a booking, its their email that is used to id that booking
    - Therefore changing the email also changes their booking ID
    - So when the email is changed, this change occurs everywhere for seamless user email transition.

<img src="screenshots/EditProfile.png" alt="Edit Profile" width="150">

### Reviews
- Reviews page allowing user to select a vehicle from the dropdown bar to write a review on, then write their comment below, give it a rating out of 5 stars, and then submit.

<img src="screenshots/Review.png" alt="Review" width="150">
<img src="screenshots/ReviewList.png" alt="Review-List" width="150">

### Admin
### Admin Log In
- Use admin credentials to access admin functionalities
- Admin log in credentials:
    - email: admin
    - password: admin


<img src="screenshots/AdminCredentials.png" alt="Sign-In" width="150">

### Admin - Dashboard
- Displays the admin dashboard allowing the user to access admin functionalities from cars, users, and bookings

<img src="screenshots/AdminDashboard.png" alt="Admin Dashboard" width="150">

### Admin - Car
- Admin cars dashboard displaying all the cars 
- Allows admin to edit each car
- Functionality to add a car to the rental listings 


<img src="screenshots/AdminCars.png" alt="Admin Cars" width="150">
<img src="screenshots/AdminEditCar.png" alt="Admin Edit Car" width="150">
<img src="screenshots/AdminAddCar.png" alt="Admin Add Car" width="150">


### Admin - User
- Manage users 
- User profiles, edit user information (including email), and remove users.
- Add users

<img src="screenshots/AdminUsers.png" alt="Admin Users" width="150">
<img src="screenshots/AdminEditUser.png" alt="Admin Edit User" width="150">
<img src="screenshots/AdminAddUser.png" alt="Admin Users" width="150">

### Admin - Bookings
- Manage Bookings
- View all bookings, and remove bookings

<img src="screenshots/AdminBookings.png" alt="Admin Booking" width="150">


## Project Structure
<img src="screenshots/ProjectStructure.png" alt="Project Structure" width="400">


# Dependencies

The project requires the following dependencies:

- `image_picker`
- `firebase_core`
- `firebase_auth`
- `cloud_firestore`
- `firebase_storage`
- `flutter_local_notifications`
- `flutter_rating_bar`
- `intl`
- `firebase_messaging`



You can find them listed in the **`pubspec.yaml`** file.

## Contributions From:
- Shiv Amin - 100867326
- Samir Chowdhury - 100701372
- Karan Patel - 100869607
- Vibhavan Saibuvis - 100872481
- Saksham Tejpal - 100874871
- Aryan Ved - 100866032
