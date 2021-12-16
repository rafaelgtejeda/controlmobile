import 'dart:async';
import 'dart:io' as io;

import 'package:erp/models/datefilter.modelo.dart';
import 'package:path/path.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatefilterHelper {
  static final DatefilterHelper _instance = new DatefilterHelper.internal();
  factory DatefilterHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatefilterHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE DateFilter(id INTEGER PRIMARY KEY, inicio TEXT, fim TEXT)");
    print("Created tables");
  }

  Future<int> saveDateFilter(DateFilter dateFilter) async {
    var dbClient = await db;
    int res = await dbClient.insert("DateFilter", dateFilter.toMap());
    return res;
  }

  Future<int> deleteDateFilter() async {
    var dbClient = await db;
    int res = await dbClient.delete("DateFilter");
    return res;
  }

  Future<List<DateFilter>> getDateFilter() async {

    var dbClient = await db;

    final List<Map<String, dynamic>> maps = await dbClient.query('DateFilter');

    return List.generate(maps.length, (i) {
      return DateFilter(
         inicio: maps[i]['inicio'],
         fim: maps[i]['fim'],
      );
    });
  }
}
