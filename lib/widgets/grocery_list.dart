import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

// main screen that shows the grocery list
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = []; // items shown on the screen
  var _isLoading = true; // shows the loading spinner while true
  String? _error; // error message to show if something fails

  // runs once when the screen opens
  @override
  void initState() {
    super.initState();
    _loadItems(); // grabs the saved items from firebase
  }

  // loads all the items from firebase
  void _loadItems() async {
    // link to our shopping list in firebase
    final url = Uri.https(
      'shoppinglistapp-c9024-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );

    try {
      final response = await http.get(url); // asks firebase for the list
      // shows an error if the request failed
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }

      // firebase sends back null when the list is empty, so stop loading
      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body); // turns the response into a map
      final List<GroceryItem> loadedtems = []; // holds the items
      // turns each firebase entry into a grocery item
      for (final item in listData.entries) {
        // finds the matching category by its name
        final category = categories.entries
            .firstWhere(
              (catItem) => catItem.value.title == item.value['category'],
            )
            .value;
        // adds the item to our loaded list
        loadedtems.add(
          GroceryItem(
            id: item.key, // firebase id
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      // shows the loaded items and hides the spinner
      setState(() {
        _groceryItems = loadedtems;
        _isLoading = false;
      });
    } catch (error) {
      // shows an error if something else went wrong
      setState(
        () {
          _error = 'Something went wrong. Please try again later.';
        },
      );
    }
  }

  // opens the add item screen and adds the new item to the list
  void _addItem() async {
    // goes to the new item screen and waits for the item it sends back
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    // stops if they backed out without adding anything
    if (newItem == null) {
      return;
    }
    // adds the new item to the list on screen
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  // removes an item when it gets swiped away
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item); // remembers where the item was

    // takes it off the screen right away
    setState(() {
      _groceryItems.remove(item);
    });

    // link to this item in firebase
    final url = Uri.https(
      'shoppinglistapp-c9024-default-rtdb.firebaseio.com',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(url); // deletes it from firebase

    // puts the item back if the delete failed
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  // builds the grocery list screen
  @override
  Widget build(BuildContext context) {
    // message shown when the list is empty
    Widget content = const Center(
      child: Text('No items added yet.'),
    );

    // loading spinner while the items load
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    // the list of items once we have some
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length, // one row per item
        // lets you swipe a row away to delete it
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]); // deletes the swiped item
          },
          // one row in the list
          child: ListTile(
            title: Text(_groceryItems[index].name), // item name
            // colored square for the category
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()), // quantity on the right
          ),
        ),
      );
    }
    // error message if loading failed
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      // top bar with the title and add button
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          // plus button that opens the add item screen
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content, // shows whichever content we picked above
    );
  }
}