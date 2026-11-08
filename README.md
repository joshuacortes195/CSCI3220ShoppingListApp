# Shopping List App

A Flutter grocery app where you sign in, build a cart, star your favorites, and see the same cart on any device you log into.

## Features

- Email and password sign in with Firebase Auth
- Cart tab: add items with a name, quantity and category, swipe to remove, tap the star to favorite
- Favorites tab: every starred item, with a button to put it back in the cart
- Cart and favorites sync live through Cloud Firestore, so changes on one device show up on the others

## How it works

- **State (Provider):** `lib/providers/cart_provider.dart` is a `ChangeNotifier` shared with every screen from `main.dart`. The cart tab, favorites tab and add item screen all read and write through it.
- **Sync (Firestore):** each user's items live at `users/{uid}/items`. The provider listens to that collection with `snapshots()`, so the UI updates on its own whenever anything changes.
- **Items** have two flags, `inCart` and `favorite`. Swiping a favorite out of the cart keeps it in favorites; an item is only deleted once it's in neither.
- **Security:** `firestore.rules` only lets a signed in user read and write their own `users/{uid}` data.

## Project layout

```
lib/
  main.dart                     firebase setup, provider, login or tabs
  providers/cart_provider.dart  shared cart + favorites state, firestore sync
  screens/auth_screen.dart      log in / sign up
  screens/tabs_screen.dart      bottom nav with cart and favorites
  screens/favorites_screen.dart starred items
  widgets/grocery_list.dart     cart tab
  widgets/new_item.dart         add item form
  models/                       grocery item and category
  data/categories.dart          category names and colors
```

## Running it

```
flutter pub get
flutter run
```

Firebase is already configured for Android (`android/app/google-services.json`, `lib/firebase_options.dart`). Email/password sign in must be enabled in the Firebase console, and the rules in `firestore.rules` need to be deployed with `firebase deploy --only firestore:rules`.
