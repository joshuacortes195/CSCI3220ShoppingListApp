import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/models/history_item.dart';

// saves the purchase history in a sqlite database on the phone
class HistoryItems {
  HistoryItems._();
  static final HistoryItems instance = HistoryItems._();

  Database? _db;

  // opens the database and makes the history table the first time
  Future<Database> get _database async {
    if (_db != null) {
      return _db!;
    }
    final dbPath = await getDatabasesPath(); 
    _db = await openDatabase(
      p.join(dbPath, 'shopping_history.db'),
      version: 1,
      // runs once to set up the table
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE history('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'uid TEXT, '
          'name TEXT, '
          'quantity INTEGER, '
          'category TEXT, '
          'purchasedAt INTEGER)',
        );
      },
    );
    return _db!;
  }

  // saves an item to the history for this user
  Future<void> addEntry(String uid, GroceryItem item) async {
    final db = await _database;
    await db.insert('history', {
      'uid': uid,
      'name': item.name,
      'quantity': item.quantity,
      'category': item.category.title,
      'purchasedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // gets the users history with newest first
  Future<List<HistoryItem>> getHistory(String uid) async {
    final db = await _database;
    final rows = await db.query(
      'history',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'purchasedAt DESC',
    );
    return rows.map(HistoryItem.fromMap).toList();
  }

  // deletes one entry
  Future<void> deleteEntry(int id) async {
    final db = await _database;
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  // deletes every entry for this user
  Future<void> clearHistory(String uid) async {
    final db = await _database;
    await db.delete('history', where: 'uid = ?', whereArgs: [uid]);
  }
}