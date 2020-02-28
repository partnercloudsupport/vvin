import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class VAnalyticsDB {
  static final _databaseName = "VAnalyticsDB.db";
  static final _databaseVersion = 1;
  static final table = 'analytics';
  static final id = 'id';
  static final startDate = 'start_date';
  static final endDate = 'end_date';
  static final totalLeads = 'total_leads';
  static final totalLeadsPercentage = 'total_leads_percentage';
  static final unassignedLeads = 'unassigned_leads';
  // static final unassignedLeadsPercentage = 'unassigned_leads_percentage';
  static final newLeads = 'new_leads';
  static final contactingLeads = 'contacting_leads';
  static final contactedLeads = 'contacted_leads';
  static final qualifiedLeads = 'qualified_leads';
  static final convertedLeads = 'converted_leads';
  static final followupLeads = 'followup_leads';
  static final unqualifiedLeads = 'unqualified_leads';
  static final badInfoLeads = 'bad_info_leads';
  static final noResponseLeads = 'no_response_leads';
  static final vflex = 'vflex';
  static final vcard = 'vcard';
  static final vcatelogue = 'vcatelogue';
  static final vbot = 'vbot';
  static final vhome = 'vhome';
  static final messenger = 'messenger';
  static final whatsappForward = 'whatsapp_forward';
  static final import = 'import';
  static final contactForm = 'contact_form';
  static final minimumDate = 'minimum_date';

  VAnalyticsDB._privateConstructor();
  static final VAnalyticsDB instance = VAnalyticsDB._privateConstructor();
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
            $startDate TEXT,
            $endDate TEXT,
            $totalLeads TEXT,
            $totalLeadsPercentage TEXT,
            $unassignedLeads TEXT,
            $newLeads TEXT,
            $contactingLeads TEXT,
            $contactedLeads TEXT,
            $qualifiedLeads TEXT,
            $convertedLeads TEXT,
            $followupLeads TEXT,
            $unqualifiedLeads TEXT,
            $badInfoLeads TEXT,
            $noResponseLeads TEXT,
            $vflex TEXT,
            $vcard TEXT,
            $vcatelogue TEXT,
            $vbot TEXT,
            $vhome TEXT,
            $messenger TEXT,
            $whatsappForward TEXT,
            $import TEXT,
            $contactForm TEXT,
            $minimumDate TEXT
          )
          ''');
  }
}
