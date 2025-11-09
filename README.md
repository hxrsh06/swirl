# Shopping Swipe App

A Flutter application that allows users to discover and shop for products using a swipe interface similar to dating apps.

## Architecture

This app follows a clean architecture pattern:

- **Presentation Layer**: Flutter UI components, widgets, animations, and swipe logic
- **Domain Layer**: Business logic, models, and ML prediction handlers
- **Data Layer**: Firebase/REST API integrations and caching

## Features

- Swipe interface for product discovery (right to like, left to dislike)
- ML-powered recommendation engine
- Product catalog with images and details
- Shopping cart functionality
- Payment integration
- Push notifications

## Project Structure

```
lib/
├── main.dart
├── presentation/
│   ├── pages/
│   ├── widgets/
│   └── providers/
├── domain/
│   ├── models/
│   ├── repositories/
│   └── usecases/
└── data/
    ├── datasources/
    ├── models/
    └── repositories/
```

## Getting Started

1. Install Flutter SDK
2. Clone the repository
3. Run `flutter pub get`
4. Configure Firebase settings
5. Run the app with `flutter run`

## Dependencies

- flutter_tindercard: For swipe card functionality
- firebase_core: Firebase integration
- cloud_firestore: Firestore database
- firebase_auth: Authentication
- stripe_sdk: Payment processing
- tflite_flutter: ML model inference
- riverpod: State management
- cached_network_image: Image caching