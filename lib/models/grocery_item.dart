import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';

// one item in the cart
class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.favorite = false,
    this.inCart = true,
  });

  final String id; // unique id that firestore gives the item
  final String name;
  final int quantity;
  final Category category;
  final bool favorite; // true when the item is starred as a favorite
  final bool inCart; // true when the item shows up in the cart

  // turns a firestore document back into a grocery item
  factory GroceryItem.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!; // the saved fields for this item
    // finds the matching category by its name
    final category = categories.values.firstWhere(
      (cat) => cat.title == data['category'],
      orElse: () => categories[Categories.other]!, // falls back to other if it's missing
    );
    return GroceryItem(
      id: doc.id, // firestore id
      name: data['name'],
      quantity: data['quantity'],
      category: category,
      favorite: data['favorite'] ?? false, // older items won't have this yet
      inCart: data['inCart'] ?? true, // older items count as in the cart
    );
  }

  // turns the item into the map we save in firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'category': category.title,
      'favorite': favorite,
      'inCart': inCart,
      'createdAt': FieldValue.serverTimestamp(), // keeps the cart in the order items were added
    };
  }
}
