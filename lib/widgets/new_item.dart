import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/grocery_item.dart';

// screen with the form for adding a new item
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>(); // lets us validate, save and reset the form
  var _enteredName = ''; 
  var _enteredQuantity = 1; 
  var _selectCategory = categories[Categories.vegetables]!; 
  var _isSending = false; 

  // checks the form and saves the item to firebase
  void _saveItem() async {
    // only saves if everything in the form is valid
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // stores the typed values in our variables
      // turns on the spinner and locks the buttons
      setState(() {
        _isSending = true;
      });
      // link to our shopping list in firebase
      final url = Uri.https(
          'shoppinglistapp-c9024-default-rtdb.firebaseio.com',
          'shopping-list.json');
      // sends the new item to firebase
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json', // tells firebase we're sending json
        },
        // the item data we're saving
        body: json.encode(
          {
            'name': _enteredName,
            'quantity': _enteredQuantity,
            'category': _selectCategory.title,
          },
        ),
      );
      final Map<String, dynamic> resData = json.decode(response.body); // firebase sends back the new id

      // stops if the screen was closed while saving
      if (!context.mounted) {
        return;
      }
      // closes the screen and sends the new item back to the list
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'], // id firebase made for it
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectCategory,
        ),
      );
    }
  }

  // builds the add item screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // top bar with the title
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12), // space around the form
        // the form that holds all the inputs
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // name input
              TextFormField(
                maxLength: 50, // limits the name to 50 characters
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                // makes sure the name isn't too short or too long
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }

                  return null; // name is good
                },
                // saves the name when the form saves
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              // quantity and category side by side
              Row(
                crossAxisAlignment: CrossAxisAlignment.end, // lines them up at the bottom
                children: [
                  // quantity input
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number, // opens the number keyboard
                      initialValue: _enteredQuantity.toString(), // starts at 1
                      // makes sure the quantity is a positive number
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }

                        return null; // quantity is good
                      },
                      // saves the quantity as a number when the form saves
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  // category dropdown
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectCategory, // shows the picked category
                      items: [
                        // one dropdown option per category
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            // color square and name for each option
                            child: Row(children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: category.value.color, // category color
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(category.value.title), // category name
                            ]),
                          ),
                      ],
                      // updates the picked category when you choose one
                      onChanged: (value) {
                        setState(() {
                          _selectCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              // reset and add buttons on the right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // clears the form, turned off while saving
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  // saves the item, turned off while saving
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    // shows a small spinner while saving, otherwise the button text
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}