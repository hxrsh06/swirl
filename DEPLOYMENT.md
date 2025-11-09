# Deployment Guide for Shopping Swipe App

## Prerequisites

Before deploying the app, ensure you have:

- Flutter SDK (3.0.0 or higher)
- Firebase project set up
- Stripe account for payments
- App signing keys for Android/iOS

## Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android and iOS apps to the project
3. Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files
4. Place these files in the appropriate directories:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`

## Environment Configuration

Create a `.env` file in the project root with the following variables:

```
STRIPE_PUBLISHABLE_KEY=pk_test_your_publishable_key_here
FIREBASE_API_KEY=your_firebase_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:android:abcdef1234567890
```

## Build for Android

### 1. Configure App Signing
```bash
# Generate a keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Add to android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=~/upload-keystore.jks
```

### 2. Build APK
```bash
flutter build apk --release
```

### 3. Build App Bundle (Recommended for Google Play)
```bash
flutter build appbundle --release
```

## Build for iOS

### 1. Configure Code Signing
- Open `ios/Runner.xcworkspace` in Xcode
- Select your team in Project Settings
- Configure bundle identifier
- Enable required capabilities (Push Notifications, etc.)

### 2. Build IPA
```bash
flutter build ios --release
```

## CI/CD Setup

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Stores

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests
        run: flutter test
        
      - name: Build APK
        run: flutter build apk --release
        
      - name: Build App Bundle
        run: flutter build appbundle --release
        
      - name: Upload to Google Play
        run: |
          # Add Google Play deployment steps
```

### Codemagic Example

Create `codemagic.yaml`:

```yaml
workflows:
  flutter-workflow:
    name: Flutter workflow
    max_build_duration: 30
    instance_type: mac_mini_m1
    environment:
      flutter: stable
    scripts:
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Run tests
        script: |
          flutter test
      - name: Build for Android
        script: |
          flutter build apk --release
      - name: Build for iOS
        script: |
          flutter build ios --release --no-codesign
    artifacts:
      - build/**/outputs/**/*.apk
      - build/**/outputs/**/mapping.txt
      - build/ios/ipa/*.ipa
      - build/**/outputs/bundle/**/*.aab
    publishing:
      email:
        recipients:
          - user@example.com
        notify:
          success: true
          failure: true
```

## Analytics and Monitoring

### Firebase Analytics
- Enable Analytics in your Firebase project
- The app automatically tracks:
  - User engagement
  - Screen views
  - In-app purchases
  - Crashlytics (if enabled)

### Performance Monitoring
- Add Firebase Performance SDK for performance tracking
- Monitor app load times and API response times

## App Store Submission

### Google Play Store
1. Create a developer account
2. Prepare app store assets (screenshots, descriptions, etc.)
3. Upload the app bundle
4. Complete store listing
5. Submit for review

### Apple App Store
1. Enroll in Apple Developer Program
2. Prepare app store assets
3. Archive and upload via Xcode
4. Create app listing in App Store Connect
5. Submit for review

## Post-Launch Monitoring

### Crash Reporting
- Firebase Crashlytics is integrated
- Monitor crash reports in Firebase Console

### Performance
- Use Firebase Performance Monitoring
- Track user engagement metrics

### Updates
- Plan for regular updates based on user feedback
- Monitor app store reviews and ratings

## Troubleshooting

### Common Issues

1. **Firebase Setup Issues**
   - Ensure correct `google-services.json` and `GoogleService-Info.plist` files
   - Verify SHA-1 fingerprints for Android

2. **Payment Issues**
   - Verify Stripe keys are correctly configured
   - Test with Stripe test keys initially

3. **ML Model Issues**
   - Ensure TensorFlow Lite models are properly included in assets
   - Verify model compatibility with target devices

## Maintenance

### Regular Tasks
- Monitor app store reviews
- Update dependencies regularly
- Test with new OS versions
- Monitor app performance metrics
- Update ML models periodically based on user data