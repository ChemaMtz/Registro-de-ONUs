# ONU Management System

A robust, multi-platform application built with Flutter to manage, track, and provision Optical Network Units (ONUs). 

## 🚀 Key Features

- **Comprehensive Inventory**: Track serial numbers, MAC addresses, SSIDs, and WiFi passwords of deployed ONUs.
- **Role-Based Access Control**: Differentiated permissions for Admins, Support, and Warehouse staff.
- **Real-Time Database**: Powered by Firebase Firestore for live updates across all connected clients.
- **Cross-Platform**: Built with Flutter, supporting Web, Android, and iOS from a single codebase.
- **CSV Export/Import**: Bulk management of inventory using CSV files.

## 🛠 Tech Stack

- **Frontend**: Flutter & Dart
- **Backend**: Firebase (Firestore, Auth, Cloud Functions)
- **State Management**: Provider / Riverpod (depending on implementation)
- **Deployment**: Vercel (Web), Firebase Hosting

## 📂 Project Architecture

- `lib/presentation/`: UI screens and custom widgets.
- `lib/models/`: Data classes representing ONUs, Users, and Catalogs.
- `lib/services/`: Firebase database and authentication handlers.
- `scripts/`: Node.js scripts for bulk database operations and cleanup.

## ⚙️ Setup and Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ChemaMtz/Registro-de-ONUs.git
   cd Registro-de-ONUs
   ```

2. **Install Flutter Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Make sure you have your `firebase_options.dart` configured in `lib/` or connect the project using the FlutterFire CLI:
   ```bash
   flutterfire configure
   ```

4. **Run the App:**
   ```bash
   flutter run -d chrome
   ```

## 📱 Screenshots

*(Include screenshots of the dashboard, ONU form, and user roles management here to showcase the UI)*

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
