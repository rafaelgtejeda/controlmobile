import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:erp/models/diretivas-acesso/diretivas-acesso.modelo.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
class EmpresaService {

  RequestUtil request = new RequestUtil();
  
  int usuarioId;

  Future<dynamic> listaEmpresas() async {
    usuarioId = await request.obterIdUsuarioSharedPreferences();
    return request.getReq(
      endpoint: Endpoints.EMPRESAS,
      data: {
        'usuarioId': usuarioId
      }
    );
  }

  Future<dynamic> obterDiretivasAcessoEmpresa({BuildContext context, int empresaId}) async {
    usuarioId = await request.obterIdUsuarioSharedPreferences();
    if(await request.verificaOnline()) {
      return request.getReq(
        endpoint: Endpoints.EMPRESA_ACESSOS,
        data: {
          'usuarioId': usuarioId,
          'empresaId': empresaId
        },
        loading: true,
        context: context
      );
    }
    else {
      return await EmpresaAcessosProvider().getEmpresasAcessosList(empresaId: empresaId);
    }
  }

  Future<dynamic> downloadTodosAcessosEmpresa(List<Empresa> empresa) async {
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    usuarioId = await request.obterIdUsuarioSharedPreferences();
    empresa.forEach((element) {
      dynamic resultado = request.getReq(
        endpoint: Endpoints.EMPRESA_ACESSOS,
        data: {
          'usuarioId': usuarioId,
          'empresaId': element.id,
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    return resultados;
  }

  Future<dynamic> refazLogin() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String _ddi = _prefs.getString(SharedPreference.DDI);
    String _telefone = _prefs.getString(SharedPreference.TELEFONE);
    String _codigo = _prefs.getString(SharedPreference.CODIGO);
    String _idioma = _prefs.getString(SharedPreference.IDIOMA);
    String _modeloCelular = await request.getDeviceModel();
    String _uuid = '';
    if(_prefs.getString(SharedPreference.UUID).isEmpty) {
      _uuid = await request.getUUID();
      _prefs.setString(SharedPreference.UUID, _uuid);
    }
    else {
      _uuid = _prefs.getString(SharedPreference.UUID);
    }

    return request.postReq(
      endpoint: Endpoints.ACCOUNT_LOGIN,
      data: {
        'ddi': _ddi,
        'telefone': _telefone,
        'codigoAtivacao': _codigo,
        'idioma': _idioma,
        'modeloCelular': _modeloCelular,
        'uuid': _uuid
      },
    );
  }

}

class EmpresaAcessosProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_DIRETIVAS_EMPRESA);
    return res.isNotEmpty;
  }
  
  // insertEmpresaAcesso(DiretivasAcessoModelo diretivas) async {
  insertEmpresaAcesso({int empresaId, dynamic object}) async {
    // Insere a diretiva na tabela
    Database db = await dbProvider.database;
    var empresaDiretiva = {
      'id': empresaId,
      'object': json.encode(object)
    };

    int res = await db.insert(DBProvider.TABLE_DIRETIVAS_EMPRESA, empresaDiretiva, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertEmpresasAcessosBatch(List<dynamic> diretivas) async {
    // Insere as diretivas na tabela via batches
    List<dynamic> listaDiretivasBatch = new List<dynamic>();
    Database db = await dbProvider.database;
    int batchCounter = (diretivas.length ~/ 10) + (diretivas.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < diretivas.length; i++) {
      listaDiretivasBatch.add(diretivas[i]);
      if ((i+1) % 10 == 0 || i+1 == diretivas.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaDiretivasBatch.forEach((element) {
            var empresaDiretiva = {
              'id': element['id'],
              'object': json.encode(element)
            };
            batch.insert(DBProvider.TABLE_DIRETIVAS_EMPRESA, empresaDiretiva, conflictAlgorithm: ConflictAlgorithm.ignore);
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          debugPrint(results.toString());
        });
        listaDiretivasBatch.clear();
      }
    }

    if(currentBatch == batchCounter) return true;
    else return false;
  }

  updateEmpresaAcesso(DiretivasAcessoModelo diretiva) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_DIRETIVAS_EMPRESA, diretiva.toJson());
    return res;
  }

  updateAllEmpresaAcesso(DiretivasAcessoModelo diretiva) async {
    await deleteAllEmpresaAcesso();
    // await insertEmpresaAcesso(diretiva);
  }

  Future<dynamic> getEmpresasAcessosList({int empresaId}) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_DIRETIVAS_EMPRESA,
      where: 'id = ?', whereArgs: [empresaId],
    );

    dynamic empresaAcessosJson = json.decode(res[0]['object']);

    return empresaAcessosJson;
  }

  deleteEmpresaAcesso(DiretivasAcessoModelo diretiva) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_DIRETIVAS_EMPRESA, where: 'id = ?', whereArgs: [diretiva.id]);
  }

  deleteAllEmpresaAcesso() async {
    // Realiza Truncate na tabela Diretivas.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_DIRETIVAS_EMPRESA);
    }
  }
}
