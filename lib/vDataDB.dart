import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class VDataDB {
  static final _databaseName = "VDataDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'vdata';
  static final id = 'id';
  static final date = 'date';
  static final name = 'name';
  static final phone = 'phone';
  static final handler = 'handler';
  static final remark = 'remark';
  static final status = 'status';
  static final total = 'total';

  VDataDB._privateConstructor();
  static final VDataDB instance = VDataDB._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $id INTEGER PRIMARY KEY,
            $date TEXT,
            $name TEXT,
            $phone TEXT,
            $handler TEXT,
            $remark TEXT,
            $status TEXT,
            $total TEXT
          )
          ''');
  }
}
