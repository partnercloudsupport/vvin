import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class CompanyDB {
  static final _databaseName = "CompanyDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'details';
  static final id = 'id';
  static final name = 'name';
  static final phone = 'phone';
  static final email = 'email';
  static final website = 'website';
  static final address = 'address';

  CompanyDB._privateConstructor();
  static final CompanyDB instance = CompanyDB._privateConstructor();
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
            $name TEXT,
            $phone TEXT,
            $email TEXT,
            $website TEXT,
            $address TEXT
          )
          ''');
  }
}
