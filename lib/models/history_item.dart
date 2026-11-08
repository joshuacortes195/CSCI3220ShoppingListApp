import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';

// one item the user checked off, saved on the phone in the purchase history
class HistoryItem {
  const HistoryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    required this.purchasedAt,
  });

  final int id; // row id that sqlite gives the entry
  final String name;
  final int quantity;
  final Category category;
  final DateTime purchasedAt; // when the item was checked off

  // turns a sqlite row back into a history entry
  factory HistoryItem.fromMap(Map<String, Object?> map) {
    // finds the matching category by its name
    final category = categories.values.firstWhere(
      (cat) => cat.title == map['category'],
      orElse: () => categories[Categories.other]!, 
    );
    return HistoryItem(
      id: map['id'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      category: category,
      purchasedAt:
          DateTime.fromMillisecondsSinceEpoch(map['purchasedAt'] as int),
    );
  }
}