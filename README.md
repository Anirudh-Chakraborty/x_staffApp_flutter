# Staff Flutter App

Flutter mobile app for staff to manage inventory orders.

## Features
- Staff signup and login
- Browse and search products
- Place orders
- View order history
- Logout

## Setup

### 1. Install Flutter
Make sure Flutter is installed: https://flutter.dev/docs/get-started/install

### 2. Install Dependencies
```bash
cd StaffFlutterApp
flutter pub get
```

### 3. Configure Backend URL
Edit `lib/services/api_service.dart` and change the `baseUrl`:

- **For Android Emulator**: Use `http://10.0.2.2:3000`
- **For iOS Simulator**: Use `http://localhost:3000`
- **For Physical Device**: Use your computer's IP like `http://192.168.x.x:3000`

### 4. Start Backend Server
Make sure the InventoryBackend is running:
```bash
cd ../InventoryBackend
npm install
node server.js
```

### 5. Run the App

**Option 1: Run on macOS (recommended for testing)**
```bash
cd ../StaffFlutterApp
flutter run -d macos
```

**Option 2: Run on Web**
```bash
flutter run -d chrome
```

**Option 3: Run on Android/iOS device**
Connect your device and run:
```bash
flutter run
```

## API Integration
The app connects to the InventoryBackend APIs:
- `POST /api/signup` - Create staff account
- `POST /api/login` - Staff login
- `GET /api/products` - List all products
- `GET /api/products/search?q=query` - Search products
- `POST /api/orders` - Place order
- `GET /api/orders` - Get order history

## Notes
- This is a demo app with plain text password storage
- Staff role is automatically assigned during signup
- Requires backend server to be running and accessible
