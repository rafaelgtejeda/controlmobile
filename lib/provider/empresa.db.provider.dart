import 'dart:convert';

import 'package:erp/servicos/offiline/offline.modelo.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class EmpresaDBProvider {
  static Database _database;
  static final EmpresaDBProvider db = EmpresaDBProvider._();

  // Create the Table colums
  static const String TABLE_OFFLINE = 'offline';
  static const String TABLE_EMPRESA = 'empresas';

             static const String Id = 'id';
       static const String Endpoint = 'endpoint';
      static const String Parameter = 'parameter';
         static const String Object = 'object';
        static const String Entered = 'entered';
        static const String Updated = 'updated';

        static const String DB_NAME = 'offline.db';

  EmpresaDBProvider._();

  Future<Database> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the Employee table
  initDB() async {
    
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, DB_NAME);

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      
      await db.execute('CREATE TABLE $TABLE_OFFLINE ('
          'id INTEGER PRIMARY KEY,'
          'endpoint TEXT,'
          'parameters TEXT,'
          'object TEXT,'
          'entered TEXT,'
          'updated TEXT'
          ')');

      await db.execute('CREATE TABLE $TABLE_EMPRESA ('
          'id INTEGER PRIMARY KEY,'
          'nome TEXT,'
          'nomeFantasia TEXT,'
          'entered TEXT,'
          'updated TEXT'
          ')');
    });
  }

  Future<bool> checkOffline(endpoint, data) async {
    final db = await database;
    final res =
        await db.query("offline", where: "endpoint = ?", whereArgs: [endpoint]);
    return res.isEmpty;
  }

  Future<Map<String, dynamic>> getOffline(endpoint) async {
    final db = await database;
    List<Map> res =
        await db.query("offline", where: "endpoint = ?", whereArgs: [endpoint]);

    List<Offline> listaOffline =
        res.isNotEmpty ? res.map((c) => Offline.fromJson(c)).toList() : [];

    Offline retorno = new Offline();
    retorno = listaOffline[0];

    dynamic jsonObject =  json.decode(retorno.object);

    return jsonObject;
  }

  createOffline(endpoint, data, response) async {
  
    var newOffline = {
      "endpoint": endpoint.toString(),
      "parameters": data.toString(),
      "object": json.encode(response),
      "entered": DateTime.now().toString()
    };

    final db = await database;
    final res = await db.insert(TABLE_OFFLINE, newOffline);
    return res;
  }

  createEmpresa(endpoint, data, response) async {
  
    var newEmpresa = {
      "nome": response[0].nome.toString(),
      "nomeFantasia": response[0].nomeFantasia.toString(),
      "entered": DateTime.now().toString()
    };

      final db = await database;
     final res = await db.insert(TABLE_EMPRESA, newEmpresa);
 
    return res;

  }

  // Insert employee on database
  createEmployee(Offline newOffline) async {
    await deleteAllEmployees();
    final db = await database;
    final res = await db.insert('offline', newOffline.toJson());
    return res;
  }

  // Delete all employees
  Future<int> deleteAllEmployees() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM offline');

    return res;
  }

  Future<List<Offline>> getAllOffline() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM offline");

    List<Offline> list =
        res.isNotEmpty ? res.map((c) => Offline.fromJson(c)).toList() : [];

    return list;
  }
}
