import 'dart:convert';

import 'package:erp/servicos/offiline/offline.modelo.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class LookupOfflineDBProvider {
  
  static Database _database;

  static final LookupOfflineDBProvider db = LookupOfflineDBProvider._();

  // Create the Table colums
  static const String TABLE_ProdutoLookUp = 'prudutolookup';

  static const String DB_NAME = 'offline.db';

  LookupOfflineDBProvider._();

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

      await db.execute('CREATE TABLE $TABLE_ProdutoLookUp ('
          
          'id INTEGER PRIMARY KEY,'
          'codigo TEXT,'
          'descricao TEXT,'
          'descricaoResumida TEXT,'
          'marca TEXT,'
          'saldoEstoque TEXT,'
          'valorVenda TEXT,'
          'unidadeMedida TEXT,'
          'locacaoBens TEXT,'
          
          // ------> parametros
          'lookupNome TEXT'
          'empresaId TEXT'
          'search TEXT,'
          'tipos TEXT,'
          'situacoes TEXT,'
          // ------> parametros

          'entered TEXT,'
          'updated TEXT'

          ')');

    });
  }

  Future<bool> checkProdutoLookUp(endpoint, data, tipos, empresaID) async {

    final db = await database;
    final res = await db.query(TABLE_ProdutoLookUp,
        where: "tipos = ? and endpoint and lookupNome = ?",
        whereArgs: [tipos, endpoint, empresaID]);

    return res.isEmpty;
  }

  Future<Map<String, dynamic>> getProdutoLookUp(endpoint, empresaId, tipos) async {

    final db = await database;
    List<Map> res =
        await db.query(TABLE_ProdutoLookUp, where: "endpoint = ? and tipos = ?", whereArgs: [endpoint, tipos]);

    List<Offline> listaOffline =
        res.isNotEmpty ? res.map((c) => Offline.fromJson(c)).toList() : [];

    Offline retorno = new Offline();
    retorno = listaOffline[0];

    dynamic jsonObject = json.decode(retorno.object);

    return jsonObject;
  }

  createProdutoLookUp(empresaId, tipo, response) async {

    var newProdutoLookUp = {
      "endpoint": empresaId.toString(),
      "parameters": tipo.toString(),
      "object": json.encode(response),
      "entered": DateTime.now().toString()
    };

    final db = await database;
    final res = await db.insert(TABLE_ProdutoLookUp, newProdutoLookUp);
    return res;
  }

  Future<int> deleteAllProdutoLookUp() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM offline');

    return res;
  }

  Future<List<Offline>> getAllProdutoLookUp() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM offline");

    List<Offline> list =
        res.isNotEmpty ? res.map((c) => Offline.fromJson(c)).toList() : [];

    return list;
  }
}
