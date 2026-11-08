import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list_app/firebase_options.dart';
import 'package:shopping_list_app/providers/cart_provider.dart';
import 'package:shopping_list_app/screens/auth_screen.dart';
import 'package:shopping_list_app/screens/tabs_screen.dart';

// starts the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // lets us run firebase setup before the app shows
  // connects the app to our firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // shares the cart provider with every screen in the app
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

// root of the app, sets up the theme and the first screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // builds the whole app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Groceries',
      // dark theme for the whole app
      theme: ThemeData.dark().copyWith(
        // colors used across the app
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60), // background color for every screen
      ),
      // shows the tabs when signed in, otherwise the login screen
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), // fires whenever someone signs in or out
        builder: (ctx, snapshot) {
          // spinner while firebase checks if we're already signed in
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // signed in, so go to the cart and favorites tabs
          if (snapshot.hasData) {
            return const TabsScreen();
          }
          return const AuthScreen(); // not signed in yet
        },
      ),
    );
  }
}
