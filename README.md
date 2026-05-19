# Explore Lithuania! 🇱🇹

## Overview

**Explore Lithuania!** is a mobile application developed using **Flutter** and **Node.js** that allows users to discover events, tourist attractions, and interesting places across Lithuania. The application provides a modern and responsive user interface together with a scalable backend system for managing users, events, and authentication.

The project was developed as part of coursework in Software Engineering at Vilnius University Šiauliai Academy.

---

# Main Features

## User Features
- User registration
- User login/logout
- Secure authentication with JWT
- Password changing and resetting
- User profile management
- Avatar uploading
- Event browsing
- Event filtering by category
- Event creation
- Viewing places and cultural locations

## Admin/Backend Features
- REST API integration
- Event management
- User management
- MongoDB database storage
- Secure password hashing
- Authentication middleware

---

# Technologies Used

## Frontend
| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform mobile development |
| Dart | Programming language |
| HTTP Package | API communication |
| Flutter Secure Storage | Secure token storage |
| Material Design | User interface components |

## Backend
| Technology | Purpose |
|------------|---------|
| Node.js | Backend runtime |
| Express.js | REST API framework |
| MongoDB | Database |
| Mongoose | MongoDB object modeling |
| JWT | Authentication |
| bcrypt | Password hashing |

---

# Project Structure

```bash
explore_lithuania/
│
├── android/              # Android native files
├── ios/                  # iOS native files
├── lib/                  # Flutter source code
│   ├── pages/            # Application screens
│   ├── widgets/          # Reusable widgets
│   ├── models/           # Data models
│   ├── services/         # API services
│   ├── utils/            # Utility/helper classes
│   └── main.dart         # Entry point
│
├── assets/               # Images and assets
├── test/                 # Flutter tests
├── pubspec.yaml          # Dependencies
└── README.md             # Documentation
```

---

# Requirements

Before running the project, install the following:

## Software Requirements
- Flutter SDK
- Dart SDK
- Node.js
- MongoDB
- Android Studio or VS Code
- Android Emulator or physical Android device

---

# Flutter Installation

## Install Flutter SDK

Download Flutter SDK:

https://docs.flutter.dev/get-started/install

Check installation:

```bash
flutter doctor
```

---

# Backend Setup

## 1. Clone Backend Repository

```bash
git clone YOUR_BACKEND_REPOSITORY_LINK
```

## 2. Open Backend Folder

```bash
cd backend
```

## 3. Install Dependencies

```bash
npm install
```

## 4. Create `.env` File

Example:

```env
PORT=3000
MONGO_URI=your_mongodb_connection
JWT_SECRET=your_secret_key
```

## 5. Start Backend Server

```bash
npm start
```

or

```bash
node server.js
```

Server should run on:

```bash
http://localhost:3000
```

---

# Flutter Project Setup

## 1. Clone Repository

```bash
git clone YOUR_PROJECT_LINK
```

## 2. Navigate to Project Folder

```bash
cd explore_lithuania
```

## 3. Install Flutter Dependencies

```bash
flutter pub get
```

## 4. Configure Backend URL

Inside service files or pages, replace backend URL:

```dart
final String backendUrl = 'http://YOUR_IP_ADDRESS:3000';
```

Example for Android Emulator:

```dart
http://10.0.2.2:3000
```

Example for physical device:

```dart
http://192.168.X.X:3000
```

---

# Running the Application

## Start Flutter App

```bash
flutter run
```

If multiple devices are connected:

```bash
flutter devices
```

Then:

```bash
flutter run -d DEVICE_ID
```

---

# Build APK

## Debug APK

```bash
flutter build apk --debug
```

## Release APK

```bash
flutter build apk --release
```

Generated APK location:

```bash
build/app/outputs/flutter-apk/
```

---

# Running Tests

```bash
flutter test
```

---

# API Communication

The application communicates with the backend using REST APIs.

## Main API Functionalities
- User authentication
- Event retrieval
- Event creation
- Profile updates
- Password changing

Example API request:

```dart
final response = await http.get(
  Uri.parse('$backendUrl/events'),
);
```

---

# Authentication

Authentication is implemented using JWT tokens.

## Security Features
- Password hashing with bcrypt
- JWT authentication
- Secure token storage
- Protected API routes

---

# Database

MongoDB is used to store:
- User information
- Event data
- Categories
- Authentication data

---

# Screenshots

## Login Screen
(Add screenshot here)

## Home Screen
(Add screenshot here)

## Event Screen
(Add screenshot here)

## Profile Screen
(Add screenshot here)

---

# Advantages of Flutter in This Project

- Single codebase for Android and iOS
- Fast development using Hot Reload
- High UI performance
- Large widget library
- Easy API integration

---

# Advantages of Node.js in This Project

- Non-blocking asynchronous architecture
- Real-time support
- Fast API response time
- Scalable backend system
- Large ecosystem with npm

---

# Known Issues

- Push notifications are not implemented yet
- Some UI elements may require optimization for tablets
- Offline mode is not supported

---

# Future Improvements

- Google Maps integration
- Push notifications
- Event booking system
- Event commenting system
- Admin dashboard
- Multi-language support

---

# Useful Commands

## Clean Flutter Build

```bash
flutter clean
```

## Get Packages Again

```bash
flutter pub get
```

## Analyze Project

```bash
flutter analyze
```

---

# .gitignore Recommendations

.dart_tool/
.packages
.pub/
build/
.idea/
.vscode/
*.iml
.flutter-plugins
.flutter-plugins-dependencies
.metadata
*.log
.DS_Store
android/.gradle/
ios/Pods/
coverage/
```

---

# Author

Developed by:
Kateryna Patsui
kate160203@gmail.com

Vilnius University Šiauliai Academy  
Software Engineering Study Programme

Coursework:
**Mobile App Development for Android using Flutter**

---

# References

- https://flutter.dev/
- https://dart.dev/
- https://nodejs.org/
- https://expressjs.com/
- https://mongodb.com/

---