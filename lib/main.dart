import 'package:flutter/material.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';

// starts the app
void main() {
  runApp(const MyApp());
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
      home: const GroceryList(), // first screen is the grocery list
    );
  }
}