# Running the Shopping Swipe App

## Prerequisites

Before running the app, you need to:

1. Install Flutter SDK (3.0.0 or higher)
2. Install an IDE with Flutter support (VS Code or Android Studio)
3. Set up emulators or connect physical devices
4. Install dependencies

## Installation Steps

### 1. Clone or download the project
```bash
git clone <your-project-repository>
# or download and extract the project files
```

### 2. Install dependencies
```bash
cd shopping_swipe_app
flutter pub get
```

### 3. Configure Firebase
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android and iOS apps to the project
3. Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
4. Place these files in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

### 4. Configure environment variables
Create a `.env` file in the project root with your API keys:
```
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:android:abcdef1234567890
```

## Running the App

### For Android:
```bash
flutter run
```

### For iOS:
```bash
flutter run
```

### For specific devices:
```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d <device-id>
```

### For web (if supported):
```bash
flutter run -d chrome
```

## Development Commands

### Hot reload during development:
- In your IDE: Save the file (Ctrl+S) or use hot reload (Ctrl+\ in VS Code)
- Or use command line:
```bash
flutter run --hot
```

### Run tests:
```bash
flutter test
```

### Build for different platforms:

#### APK for Android:
```bash
flutter build apk --debug  # For development
flutter build apk --release  # For production
```

#### App Bundle for Google Play:
```bash
flutter build appbundle --release
```

#### iOS:
```bash
flutter build ios --debug  # For development
flutter build ios --release  # For production
```

## Troubleshooting

### Common Issues:

1. **Missing dependencies**:
   - Run `flutter pub get` again
   - Check your `pubspec.yaml` for any syntax errors

2. **Gradle build errors (Android)**:
   - Try `cd android && ./gradlew clean && cd ..`
   - Run `flutter clean` and `flutter pub get`

3. **iOS build errors**:
   - Run `cd ios && pod install && cd ..`
   - Open `ios/Runner.xcworkspace` in Xcode and fix any build settings

4. **Firebase setup errors**:
   - Verify that `google-services.json` and `GoogleService-Info.plist` are in the correct locations
   - Ensure SHA-1 fingerprints are added for Android

5. **ML model not loading**:
   - Make sure your TensorFlow Lite model is in `assets/models/`
   - Verify the model file path in the code

## Development Tips

- Use `flutter run --debug` for development with debugging capabilities
- Use `flutter run --profile` for performance profiling
- Use `flutter run --release` for release testing
- Check the Flutter logs with `flutter logs`
- Use Flutter DevTools for performance analysis: `flutter pub global run devtools`

## Next Steps

1. Implement the missing dependencies that are currently throwing `UnimplementedError`
2. Add the TensorFlow Lite model to the assets folder
3. Configure your backend API endpoints
4. Set up proper error handling and loading states
5. Add unit and integration tests