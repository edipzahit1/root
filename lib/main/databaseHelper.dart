import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "root.db";
  static const _databaseVersion = 1;

  static const userInfoTable = 'user_info';
  static const userInfoColumnId = 'id';
  static const userInfoColumnName = 'name';
  static const userInfoColumnEmail = 'email';
  static const userInfoColumnPhoto = 'photo';

  static const userListTable = 'user_lists';
  static const userListColumnId = 'id';
  static const userListColumnUserId = 'userId';
  static const userListColumnItem = 'item';

  static const userInfoColumnGoogleId = 'googleID';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute
      ('''CREATE TABLE $userInfoTable (
        $userInfoColumnId INTEGER PRIMARY KEY,
        $userInfoColumnGoogleId TEXT NOT NULL,
        $userInfoColumnName TEXT NOT NULL,
        $userInfoColumnEmail TEXT NOT NULL,
        $userInfoColumnPhoto TEXT
      )
    ''');

    await db.execute
      ('''CREATE TABLE $userListTable (
        $userListColumnId INTEGER PRIMARY KEY,
        $userInfoColumnGoogleId TEXT NOT NULL,
        $userListColumnItem TEXT NOT NULL,
        FOREIGN KEY ($userInfoColumnGoogleId) REFERENCES $userInfoTable($userInfoColumnGoogleId)
      )
    ''');
  }

  Future<int> insertRoute(Map<String, dynamic> route) async {
    Database db = await instance.database;
    return await db.insert(userListTable, route);
  }

  Future<int> insertUserInfo(Map<String, dynamic> currentUserMap) async {
    Database db = await instance.database;
    return await db.insert(userInfoTable, currentUserMap);
  }

  Future<Map<String, dynamic>?> queryUserInfo(int userId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      userInfoTable,
      where: '$userInfoColumnId = ?',
      whereArgs: [userId],
    );
    return result.isNotEmpty ? result.first : null;
  }
}
