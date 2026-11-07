import 'package:shopping_list_app/models/category.dart';

// one item on the grocery list
class GroceryItem {
  const GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });

  final String id; // unique id that firebase gives the item
  final String name;
  final int quantity;
  final Category category;
}