import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list_app/providers/cart_provider.dart';

// history tab that shows everything you've checked off, saved on the phone
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  // builds the history tab
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>(); 
    final history = cartProvider.history;

    // message shown when nothing has been checked off yet
    if (history.isEmpty) {
      return const Center(
        child: Text('No history yet. Swipe an item off your cart to save it here.'),
      );
    }

    // the list of past items, newest first
    return ListView.builder(
      itemCount: history.length, // one row per entry
      itemBuilder: (ctx, index) {
        final entry = history[index];
        final date = entry.purchasedAt;
        // lets you swipe a row away to delete it from the history
        return Dismissible(
          key: ValueKey(entry.id),
          onDismissed: (direction) {
            cartProvider.deleteHistoryItem(entry);
          },
          // one row in the list
          child: ListTile(
            title: Text(entry.name), // item name
            subtitle: Text('Qty ${entry.quantity} · ${date.month}/${date.day}/${date.year}'),
            // colored square for the category
            leading: Container(
              width: 24,
              height: 24,
              color: entry.category.color,
            ),
            // button that puts the item back in the cart
            trailing: IconButton(
              onPressed: () {
                cartProvider.addFromHistory(entry);
                // confirms the item went back to the cart
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ${entry.name} to your cart.')),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
            ),
          ),
        );
      },
    );
  }
}