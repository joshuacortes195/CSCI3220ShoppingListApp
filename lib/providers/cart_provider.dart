import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:shopping_list_app/data/history_items.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/models/history_item.dart';

// holds the cart and favorites for every screen and keeps them synced with firestore
class CartProvider extends ChangeNotifier {
  // starts listening for sign in and sign out as soon as the app opens
  CartProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen(_onAuthChanged);
  }

  List<GroceryItem> _items = []; // every item this user has saved
  List<HistoryItem> _history = []; // items user saved on the phone
  var _isLoading = true; // shows the loading spinner while true
  String? _error; // error message to show if something fails
  StreamSubscription<User?>? _authSub; // watches who is signed in
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _itemsSub; // watches the user's items in firestore

  bool get isLoading => _isLoading;
  String? get error => _error;

  // items that show up on the cart tab
  List<GroceryItem> get cart => _items.where((item) => item.inCart).toList();

  // items that show up on the favorites tab
  List<GroceryItem> get favorites =>
      _items.where((item) => item.favorite).toList();

  // items that show up on the history tab
  List<HistoryItem> get history => _history;

  // the signed in user's items folder in firestore
  CollectionReference<Map<String, dynamic>> get _itemsRef {
    final uid = FirebaseAuth.instance.currentUser!.uid; // id of whoever is signed in
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('items');
  }

  // swaps to the new user's items whenever someone signs in or out
  void _onAuthChanged(User? user) {
    _itemsSub?.cancel(); // stops listening to the last user's items
    _items = [];
    _history = []; // clears the last users history from the screen
    _error = null;

    // nobody signed in, so there's nothing to load
    if (user == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _loadHistory(user.uid); // loads users history from the phone

    // live feed of this user's items, updates on every device right away
    _itemsSub = _itemsRef.orderBy('createdAt').snapshots().listen(
      (snapshot) {
        _items = snapshot.docs
            .map((doc) => GroceryItem.fromFirestore(doc))
            .toList(); // turns each document into a grocery item
        _isLoading = false;
        _error = null;
        notifyListeners(); // tells every screen to rebuild
      },
      // shows an error if firestore can't be reached
      onError: (_) {
        _error = 'Failed to fetch data. Please try again later.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // reads users purchase history from the database on the phone
  Future<void> _loadHistory(String uid) async {
    final entries = await HistoryItems.instance.getHistory(uid);
    // ignores the result if a different user signed in while it was loading
    if (FirebaseAuth.instance.currentUser?.uid != uid) {
      return;
    }
    _history = entries;
    notifyListeners();
  }

  // saves a new item to the cart in firestore
  Future<void> addItem(GroceryItem item) async {
    await _itemsRef.add(item.toMap());
  }

  // takes an item out of the cart when it gets swiped away
  Future<void> removeFromCart(GroceryItem item) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // saves the item to the history on the phone before it leaves the cart
    await HistoryItems.instance.addEntry(uid, item);
    await _loadHistory(uid);

    // keeps favorites around so they stay on the favorites tab
    if (item.favorite) {
      await _itemsRef.doc(item.id).update({'inCart': false});
    } else {
      await _itemsRef.doc(item.id).delete(); // not a favorite, so delete it for good
    }
  }

  // puts a history item back in the cart as a new item
  Future<void> addFromHistory(HistoryItem entry) async {
    await addItem(
      GroceryItem(
        id: '', 
        name: entry.name,
        quantity: entry.quantity,
        category: entry.category,
      ),
    );
  }

  // deletes one entry from the history
  Future<void> deleteHistoryItem(HistoryItem entry) async {
    // removes it from the screen right away so the swipe animation finishes cleanly
    _history = _history.where((e) => e.id != entry.id).toList();
    notifyListeners();
    await HistoryItems.instance.deleteEntry(entry.id);
  }

  // deletes the whole history for the signed in user
  Future<void> clearHistory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    _history = [];
    notifyListeners();
    await HistoryItems.instance.clearHistory(uid);
  }

  // stars or unstars an item
  Future<void> toggleFavorite(GroceryItem item) async {
    if (item.favorite && !item.inCart) {
      await _itemsRef.doc(item.id).delete();
    } else {
      await _itemsRef.doc(item.id).update({'favorite': !item.favorite});
    }
  }

  // puts a favorite back in the cart with one tap
  Future<void> addFavoriteToCart(GroceryItem item) async {
    await _itemsRef.doc(item.id).update({'inCart': true});
  }

  // stops listening when the app closes
  @override
  void dispose() {
    _authSub?.cancel();
    _itemsSub?.cancel();
    super.dispose();
  }
}