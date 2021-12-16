import 'dart:convert';

import 'package:erp/servicos/offiline/offline.modelo.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBProvider {
  
  static Database _database;
  static DBProvider db = DBProvider._();

  // Create the Table colums
  static const String TABLE_OFFLINE = 'offline';
  static const String TABLE_OFFLINE_SAVE = 'offlinesalvar';
  static const String TABLE_OFFLINE_EXHIBITION = 'offlineExibicao';

  static const String TABLE_DIRETIVAS_EMPRESA = 'diretivasEmpresa';
  static const String TABLE_LOOKUP_PRODUTO = 'lookupProduto';
  static const String TABLE_LOOKUP_PARCEIRO = 'lookupParceiro';
  static const String TABLE_LOOKUP_VENDEDOR = 'lookupVendedor';

  static const String TABLE_OS_PROXIMOS_CHAMADOS = 'lookupOSProximosChamados';
  static const String TABLE_OS_AGENDADA = 'lookupOSAgendada';
  static const String TABLE_OS_AGENDADA_DETALHES = 'lookupOSAgendadaDetalhes';
  static const String TABLE_GRID_MATERIAL = 'gridMaterial';
  static const String TABLE_SUMARIO_GRID_MATERIAL = 'sumarioGridMaterial';
  static const String TABLE_GRID_CHECKLIST_OS = 'gridCheckList';
  static const String TABLE_GRID_FINALIZACAO_TECNICO_X_SERVICO = 'lookupGridFinalizacaoTecnicoXServico';
  static const String TABLE_GRID_FINALIZACAO_X_SERVICO_CHECKLIST = 'lookupGridFinalizacaoServicoXCheckList';
  static const String TABLE_GET_OS_CONFIG = 'getOSConfig';
  static const String TABLE_GET_OS_CONFIG_MATERIAL = 'getOSConfigMaterial';

  static const String Id = 'id';
  static const String Endpoint = 'endpoint';
  static const String Parameter = 'parameter';
  static const String Object = 'object';
  
  static const String EntryDate = 'entryDate';
  static const String Updated = 'updated';

  static const String DB_NAME = 'offline.db';

  DBProvider._();
  factory DBProvider() {
    if(db == null) {
      db = DBProvider._();
    }
    return db;
  }

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

    bool existe = await databaseExists(path);

    if(!existe) {
      return await openDatabase(
        path,
        version: 1,
        onOpen: (db) {},
        onCreate: (Database db, int version) async {

          await db.execute('CREATE TABLE $TABLE_OFFLINE ('
            'id INTEGER PRIMARY KEY, endpoint TEXT, parameters TEXT, object TEXT, entryDate TEXT, updated TEXT'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_OFFLINE_SAVE ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, endpoint TEXT, parameters TEXT, object TEXT, method TEXT,'
            'entryDate TEXT, updated TEXT'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_OFFLINE_EXHIBITION ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, endpoint TEXT, object TEXT, entryDate TEXT, updated TEXT'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_DIRETIVAS_EMPRESA (id INTEGER PRIMARY KEY, object TEXT)');

          await db.execute('CREATE TABLE $TABLE_LOOKUP_PRODUTO ('
            'id INTEGER, empresaId INTEGER, codigo TEXT, descricao TEXT, descricaoResumida TEXT,'
            'marca TEXT, saldoEstoque REAL, valorVenda REAL, unidadeMedida TEXT,'
            'locacaoBens INTEGER, tipo INTEGER, situacao INTEGER,'
            'PRIMARY KEY (id, empresaId)'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_LOOKUP_PARCEIRO ('
            'id INTEGER, empresaId INTEGER, nome TEXT, nomeFantasia TEXT,'
            'PRIMARY KEY (id, empresaId)'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_LOOKUP_VENDEDOR ('
            'id INTEGER PRIMARY KEY, nome TEXT, email TEXT'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_OS_PROXIMOS_CHAMADOS ('
            'id INTEGER PRIMARY KEY, saldoDiario INTEGER, mesDescricao TEXT, diaDescricao TEXT,'
            'dia TEXT, mes TEXT, ano TEXT, date INTEGER'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_OS_AGENDADA ('
            'id INTEGER PRIMARY KEY, osId INTEGER, numeroOS INTEGER, status INTEGER, descStatus TEXT,'
            'statusTecnico INTEGER, descStatusTecnico TEXT, descTipo TEXT, horaInicio TEXT, horaFim TEXT,'
            'endereco TEXT, numero TEXT, complemento TEXT, bairro TEXT, estado TEXT, cidade TEXT, cep TEXT,'
            'nomeCliente TEXT, nomeFantasiaCliente TEXT, data TEXT'
            ')'
          );

          await db.execute(
            'CREATE TABLE $TABLE_OS_AGENDADA_DETALHES (id INTEGER PRIMARY KEY, osId INTEGER, object TEXT)'
          );

          await db.execute('CREATE TABLE $TABLE_GRID_MATERIAL ('
            'id INTEGER PRIMARY KEY, descricao TEXT, osId INTEGER, produtoId INTEGER, produtoTipo INTEGER,'
            'quantidade REAL, codigoUnidade TEXT, valorTotal REAL, valor REAL, cobrar TEXT, locacao TEXT'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_SUMARIO_GRID_MATERIAL ('
            'osId INTEGER PRIMARY KEY, total REAL, totalCobrar REAL'
            ')'
          );

          await db.execute('CREATE TABLE $TABLE_GRID_CHECKLIST_OS (osId INTEGER, object TEXT)');

          await db.execute('CREATE TABLE $TABLE_GET_OS_CONFIG (empresaId INTEGER PRIMARY KEY, object TEXT)');

          await db.execute('CREATE TABLE $TABLE_GET_OS_CONFIG_MATERIAL (osId INTEGER PRIMARY KEY, object TEXT)');
        }
      );
    }
    else {
      return await openDatabase(path);
    }

  }

  checkOffline(endpoint, parameters) async {
    final db = await database;
    final res = await db.query(TABLE_OFFLINE, where: "endpoint = ? AND parameters = ?", whereArgs: [endpoint, parameters.toString()]);
    return res.isEmpty;
  }

  Future<dynamic> getOffline(endpoint, parameters) async {
    final db = await database;
    List<Map> resOnline = await db.query(
      TABLE_OFFLINE, where: "endpoint = ? AND parameters = ?", whereArgs: [endpoint, parameters.toString()]
    );
    List<Offline> listOnline = resOnline.isNotEmpty ? resOnline.map((c) => Offline.fromJson(c)).toList() : [];

    Offline retorno = new Offline();
    retorno = listOnline[0];

    dynamic jsonObject = json.decode(retorno.object);

    return jsonObject;
  }

  Future<dynamic> getOfflineSalvar(endpoint, parameters) async {
    final db = await database;
    List<Map> resOffline = await db.query(
      TABLE_OFFLINE_SAVE, where: "endpoint = ? AND parameters = ?", whereArgs: [endpoint, parameters.toString()]
    );
    List<OfflineSalvar> listOffline = resOffline.isNotEmpty ? resOffline.map((c) => OfflineSalvar.fromJson(c)).toList() : [];

    OfflineSalvar retorno = new OfflineSalvar();
    retorno = listOffline[0];

    dynamic jsonObject = json.decode(retorno.object);

    return jsonObject;
  }

  Future<List<dynamic>> getOfflineExibicao(endpoint) async {
    final db = await database;
    List<Map> resOffline = await db.query(
      TABLE_OFFLINE_EXHIBITION, where: "endpoint = ?", whereArgs: [endpoint]
    );
    List<OfflineExibicao> listOfflineSalvar =
    resOffline.isNotEmpty
      ? resOffline.map((c) => OfflineExibicao.fromJson(c)).toList()
      : new List<OfflineExibicao>();

    List<dynamic> listaRetorno = List<dynamic>();

    listOfflineSalvar.forEach((element) {
      dynamic jsonObject = json.decode(element.object);
      listaRetorno.add(json.decode(jsonObject));
    });
    
    return listaRetorno;
  }

  createOffline(endpoint, parameters, response) async {
    var newOffline = {
      "endpoint": endpoint.toString(),
      "parameters": parameters.toString(),
      "object": json.encode(response),
      "entryDate": DateTime.now().toString()
    };

    final db = await database;
    final res = await db.insert(TABLE_OFFLINE, newOffline, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  salvarEmOffline({String endpoint, dynamic parameters, String method, dynamic object}) async {
    // var newSalvaOffline = {
    //   "endpoint": endpoint.toString(),
    //   "parameters": parameters.toString(),
    //   "object": json.encode(response),
    //   "method": method.toString(),
    //   "entryDate": DateTime.now().toString()
    // };

    OfflineSalvar newSalvarOffline = OfflineSalvar(
      endpoint: endpoint,
      parameters: parameters.toString(),
      method: method,
      object: json.encode(object),
    );
    // newSalvarOffline.endpoint = endpoint;
    // newSalvarOffline.parameter = parameters;
    // newSalvarOffline.method = method;
    // newSalvarOffline.object = json.encode(response);

    final db = await database;
    final res = await db.insert(TABLE_OFFLINE_SAVE, newSalvarOffline.toJson(), conflictAlgorithm: ConflictAlgorithm.replace,);

    return res;
  }

  Future<List<OfflineSalvar>> checkOfflineSalvar() async {
    final db = await database;
    var res = await db.query(TABLE_OFFLINE_SAVE);
    List<OfflineSalvar> listOffline = res.isNotEmpty ? res.map((c) => OfflineSalvar.fromJson(c)).toList() : [];
    return listOffline;
  }

  salvarEmOfflineExibicao(endpoint, response) async {
    var newSalvaOfflineExibicao = {
      "endpoint": endpoint.toString(),
      "object": json.encode(response),
      "entryDate": DateTime.now().toString()
    };

    final db = await database;
    final res = await db.insert(TABLE_OFFLINE_EXHIBITION, newSalvaOfflineExibicao, conflictAlgorithm: ConflictAlgorithm.replace,);

    return res;
  }

  Future<int> getOfflineId() async {
    final db = await database;
    final res = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $TABLE_OFFLINE_EXHIBITION'));
    return res;
  }

  updateOffline(endpoint, data, response) async {
    var newOffline = {
      "endpoint": endpoint.toString(),
      "parameters": data.toString(),
      "object": json.encode(response),
      "entryDate": DateTime.now().toString()
    };

    final db = await database;
    final res = await db.update(TABLE_OFFLINE, newOffline, where: 'endpoint = ? AND parameters = ?', whereArgs: [endpoint, data.toString()], conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  // Delete all employees
  Future<int> deleteAllOffline() async {
    final db = await database;
    // final res1 = await db.rawDelete('DELETE FROM $TABLE_OFFLINE');
    // final res2 = await db.rawDelete('DELETE FROM $TABLE_OFFLINE_SAVE');
    // final res3 = await db.rawDelete('DELETE FROM $TABLE_OFFLINE_EXHIBITION');
    // final res4 = await db.rawDelete('DELETE FROM $TABLE_DIRETIVAS_EMPRESA');
    // final res5 = await db.rawDelete('DELETE FROM $TABLE_LOOKUP_VENDEDOR');
    // final res6 = await db.rawDelete('DELETE FROM $TABLE_LOOKUP_PARCEIRO');
    // final res7 = await db.rawDelete('DELETE FROM $TABLE_LOOKUP_PRODUTO');
    // final res8 = await db.rawDelete('DELETE FROM $TABLE_OS_PROXIMOS_CHAMADOS');
    // final res9 = await db.rawDelete('DELETE FROM $TABLE_OS_AGENDADA');
    // final res10 = await db.rawDelete('DELETE FROM $TABLE_GET_OS_CONFIG');
    // final res11 = await db.rawDelete('DELETE FROM $TABLE_GET_OS_CONFIG_MATERIAL');
    // final res12 = await db.rawDelete('DELETE FROM $TABLE_GRID_MATERIAL');
    // final res13 = await db.rawDelete('DELETE FROM $TABLE_GRID_CHECKLIST_OS');
    // final res14 = await db.rawDelete('DELETE FROM $TABLE_SUMARIO_GRID_MATERIAL');

    final res1 = await db.delete(TABLE_OFFLINE);
    final res2 = await db.delete(TABLE_OFFLINE_SAVE);
    final res3 = await db.delete(TABLE_OFFLINE_EXHIBITION);
    final res4 = await db.delete(TABLE_DIRETIVAS_EMPRESA);
    final res5 = await db.delete(TABLE_LOOKUP_VENDEDOR);
    final res6 = await db.delete(TABLE_LOOKUP_PARCEIRO);
    final res7 = await db.delete(TABLE_LOOKUP_PRODUTO);
    final res8 = await db.delete(TABLE_OS_PROXIMOS_CHAMADOS);
    final res9 = await db.delete(TABLE_OS_AGENDADA);
    final res10 = await db.delete(TABLE_GET_OS_CONFIG);
    final res11 = await db.delete(TABLE_GET_OS_CONFIG_MATERIAL);
    final res12 = await db.delete(TABLE_GRID_MATERIAL);
    final res13 = await db.delete(TABLE_GRID_CHECKLIST_OS);
    final res14 = await db.delete(TABLE_SUMARIO_GRID_MATERIAL);

    return res1;
  }

  Future<int> deleteOffline() async {
    final db = await database;
    final res = await db.rawDelete('DELETE FROM $TABLE_OFFLINE');
    return res;
  }

  Future<int> deleteOfflineSalvar() async {
    final db = await database;
    // final res2 = await db.rawDelete('DELETE FROM $TABLE_OFFLINE_SAVE');
    final res2 = await db.delete(TABLE_OFFLINE_SAVE);
    return res2;
  }

  Future<int> deleteOfflineExibicao() async {
    final db = await database;
    // final res2 = await db.rawDelete('DELETE FROM $TABLE_OFFLINE_EXHIBITION');
    final res2 = await db.delete(TABLE_OFFLINE_EXHIBITION);
    return res2;
  }

  Future<List<Offline>> getAllOffline() async {
    final db = await database;
    final res = await db.rawQuery("SELECT * FROM $TABLE_OFFLINE");

    List<Offline> list = res.isNotEmpty ? res.map((c) => Offline.fromJson(c)).toList() : [];

    return list;
  }
}
