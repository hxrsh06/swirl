import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:shopping_swipe_app/presentation/pages/home_page.dart';
import 'package:shopping_swipe_app/presentation/pages/cart_page.dart';
import 'package:shopping_swipe_app/presentation/pages/favorites_page.dart';
import 'package:shopping_swipe_app/presentation/pages/notifications_page.dart';
import 'package:shopping_swipe_app/presentation/pages/search_page.dart';
import 'package:shopping_swipe_app/presentation/pages/profile_page.dart';
import 'package:shopping_swipe_app/presentation/providers/swipe_provider.dart';
import 'package:shopping_swipe_app/presentation/theme/app_theme.dart';
import 'package:shopping_swipe_app/presentation/utils/page_transitions.dart';
import 'package:shopping_swipe_app/presentation/constants/app_spacing.dart';
import 'config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Connect to emulators during development
    // Only connect to emulators if running in debug mode
    if (const bool.fromEnvironment("dart.vm.product") == false) {
      try {
        // Connect to Firestore emulator
        FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8082);
        
        // Connect to Authentication emulator
        await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9098);
        
        // Connect to Storage emulator
        FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9198);
        
        // Connect to Functions emulator
        FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5002);
      } catch (e) {
        // Emulators not available, will use production Firebase services
      }
    }
  } catch (e) {
    // Firebase initialization failed - app may not function correctly
    // Consider using a proper logging service in production
  }
  
  runApp(
    ProviderScope(
      child: ShoppingSwipeApp(),
    ),
  );
}

class ShoppingSwipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SWIRL.',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: MainApp(),
      routes: {
        '/cart': (context) => const CartPage(),
        '/search': (context) => const SearchPage(),
        '/profile': (context) => const ProfilePage(),
        '/notifications': (context) => const NotificationsPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FavoritesPage(),
    CartPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartItemCount = ref.watch(swipeProvider.select((state) => state.cartItems.length));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: cartItemCount > 0
                ? Badge(
                    label: Text('$cartItemCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  )
                : const Icon(Icons.shopping_cart_outlined),
            selectedIcon: cartItemCount > 0
                ? Badge(
                    label: Text('$cartItemCount'),
                    child: const Icon(Icons.shopping_cart),
                  )
                : const Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
      ),
    );
  }
}