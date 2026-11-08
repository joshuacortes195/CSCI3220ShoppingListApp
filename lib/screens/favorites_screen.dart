import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shopping_list_app/providers/cart_provider.dart';

// favorites tab that shows every starred item
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // builds the favorites tab
  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>(); // rebuilds when the favorites change
    final favorites = cartProvider.favorites;

    // loading spinner while the items load
    if (cartProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // error message if loading failed
    if (cartProvider.error != null) {
      return Center(child: Text(cartProvider.error!));
    }

    // message shown when nothing is starred yet
    if (favorites.isEmpty) {
      return const Center(
        child: Text('No favorites yet. Tap the star on a cart item.'),
      );
    }

    // the list of favorites
    return ListView.builder(
      itemCount: favorites.length, // one row per favorite
      itemBuilder: (ctx, index) {
        final item = favorites[index];
        // one row in the list
        return ListTile(
          title: Text(item.name), // item name
          // colored square for the category
          leading: Container(
            width: 24,
            height: 24,
            color: item.category.color,
          ),
          // shows if it's already in the cart
          subtitle: Text(item.inCart ? 'In your cart' : 'Not in your cart'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min, // keeps the buttons tight on the right
            children: [
              // adds the favorite back to the cart, turned off if it's already there
              IconButton(
                onPressed: item.inCart
                    ? null
                    : () {
                        cartProvider.addFavoriteToCart(item);
                      },
                icon: const Icon(Icons.add_shopping_cart),
              ),
              // unstars the item
              IconButton(
                onPressed: () {
                  cartProvider.toggleFavorite(item);
                },
                icon: const Icon(Icons.star),
              ),
            ],
          ),
        );
      },
    );
  }
}
