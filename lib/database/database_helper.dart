// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'expanses.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expanses.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'expanses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expanses (
            localId INTEGER PRIMARY KEY AUTOINCREMENT,
            _id TEXT,
            authorId TEXT,
            name TEXT,
            description TEXT,
            amount REAL,
            currency TEXT,
            placeOfPurchase TEXT,
            category TEXT,
            isSynced INTEGER DEFAULT 0,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertExpanse(Expanses expanse) async {
    final db = await database;
    return await db.insert('expanses', expanse.toJson());
  }

  Future<List<Expanses>> getUnsyncedExpanses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
    await db.query('expanses', where: 'isSynced = 0');
    return maps.map((map) => Expanses.fromJson(map)).toList();
  }

  Future<void> markAsSynced(String id) async {
    final db = await database;
    await db.update('expanses', {'isSynced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> saveExpensesToLocalDB(List<Expanses> expenses) async {
    final db = await database;
    for (var exp in expenses) {
      await db.insert(
        'expanses',
        exp.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Update existing records
      );
    }
    print("Expenses saved to local DB");
  }

  Future<List<Expanses>> getExpensesFromLocalDB() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expanses');

    return List.generate(maps.length, (i) {
      return Expanses.fromMap(maps[i]);
    });
  }

  getExpensesGroupedByCategory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('expanses', groupBy: 'category');
  }

  getExpensesGroupedByMonth() async {
    final db = await database;
    // final List<Map<String, dynamic>> maps = await db.query('expanses', groupBy: 'category');
    // Define the SQL query
    const String query = '''
      SELECT 
        strftime('%Y-%m', createdAt) AS yearMonth,
        *
      FROM expenses
      ORDER BY createdAt DESC;
    ''';

    // Execute the query
    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    // Group the results by yearMonth
    final Map<String, List<Expanses>> groupedExpenses = {};

    for (var row in result) {
      // Extract the yearMonth and expense data
      final String yearMonth = row['yearMonth'];
      final Expanses expense = Expanses.fromMap(row);

      // Add the expense to the corresponding yearMonth group
      if (!groupedExpenses.containsKey(yearMonth)) {
        groupedExpenses[yearMonth] = [];
      }
      groupedExpenses[yearMonth]!.add(expense);
    }

    return groupedExpenses;
  }

}
