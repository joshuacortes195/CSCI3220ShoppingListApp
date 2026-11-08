import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list_app/providers/cart_provider.dart';
import 'package:shopping_list_app/screens/favorites_screen.dart';
import 'package:shopping_list_app/screens/history_screen.dart';
import 'package:shopping_list_app/widgets/grocery_list.dart';
import 'package:shopping_list_app/widgets/new_item.dart';

// holds the cart, favorites and history tabs with the bottom nav bar
class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  var _selectedPageIndex = 0; // which tab is open, 0 is cart, 1 is favorites and 2 is history

  // switches tabs when you tap the bottom bar
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // opens the add item screen
  void _addItem() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
  }

  // builds the screen with the tabs
  @override
  Widget build(BuildContext context) {
    // shows the cart unless another tab is picked
    Widget activePage = const GroceryList();
    var activePageTitle = 'Your Cart';

    // favorites tab
    if (_selectedPageIndex == 1) {
      activePage = const FavoritesScreen();
      activePageTitle = 'Your Favorites';
    }

    // history tab
    if (_selectedPageIndex == 2) {
      activePage = const HistoryScreen();
      activePageTitle = 'Purchase History';
    }

    return Scaffold(
      // top bar with the title and buttons
      appBar: AppBar(
        title: Text(activePageTitle),
        actions: [
          // clears the whole history, only shown on the history tab
          if (_selectedPageIndex == 2)
            IconButton(
              onPressed: () {
                context.read<CartProvider>().clearHistory();
              },
              icon: const Icon(Icons.delete_sweep),
            ),
          // plus button that opens the add item screen
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
          // logs you out and goes back to the login screen
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: activePage,
      // bottom bar for switching between cart, favorites and history
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}