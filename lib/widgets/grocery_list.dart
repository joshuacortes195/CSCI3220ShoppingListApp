import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list_app/providers/cart_provider.dart';

// cart tab that shows the grocery list
class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  // builds the cart tab
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>(); // rebuilds when the cart changes
    final cart = cartProvider.cart; // items shown on the screen

    // loading spinner while the items load
    if (cartProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // error message if loading failed
    if (cartProvider.error != null) {
      return Center(child: Text(cartProvider.error!));
    }

    // message shown when the cart is empty
    if (cart.isEmpty) {
      return const Center(
        child: Text('No items added yet.'),
      );
    }

    // the list of items once we have some
    return ListView.builder(
      itemCount: cart.length, // one row per item
      itemBuilder: (ctx, index) {
        final item = cart[index];
        // lets you swipe a row away to take it out of the cart
        return Dismissible(
          key: ValueKey(item.id),
          onDismissed: (direction) {
            cartProvider.removeFromCart(item); // removes the swiped item in firestore
          },
          // one row in the list
          child: ListTile(
            title: Text(item.name), // item name
            // colored square for the category
            leading: Container(
              width: 24,
              height: 24,
              color: item.category.color,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min, // keeps the quantity and star tight on the right
              children: [
                Text(item.quantity.toString()), // quantity on the right
                // star button that saves the item as a favorite
                IconButton(
                  onPressed: () {
                    cartProvider.toggleFavorite(item);
                  },
                  icon: Icon(item.favorite ? Icons.star : Icons.star_border), // filled star when it's a favorite
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
