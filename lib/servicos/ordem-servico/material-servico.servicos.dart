import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:sqflite/sqflite.dart';

class MarterialServicoService {

  RequestUtil _request = new RequestUtil();
  int osId;

  Future<dynamic> getMaterialServico({int skip = 0, int osId}) async {
    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.GRID_MATERIAL,
        data: {
          'skip': skip * Request.TAKE,
          'take': Request.TAKE,
          'osId': osId
        }
      );
    }
    else {
      return await MateriaisServicosProvider().getMaterialServicoList(osId: osId, skip: skip);
    }
  }

  Future<dynamic> downloadTodosMaterialServico({List<GridOSAgendadaModelo> osAgendada}) async {
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    osAgendada.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.GRID_MATERIAL,
        data: {
          'skip': 0,
          'take': 1000,
          'osId': element.osId
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    return resultados;
  }

  Future<dynamic> adicionaMaterialServico({String materialServico, BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ADICIONAR_MATERIAL,
      data: materialServico,
      loading: true,
      context: context
    );
  }

  Future<dynamic> atualizaMaterialServico({String materialServico, BuildContext context}) async {
    return _request.putReq(
      endpoint: Endpoints.ATUALIZAR_MATERIAL,
      data: materialServico,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaMaterialServico({@required int idMaterialServico, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: Endpoints.REMOVER_MATERIAL + '$idMaterialServico',
      data: null,
      loading: true,
      context: context
    );
  }

}

class MateriaisServicosProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_GRID_MATERIAL);
    return res.isNotEmpty;
  }

  insertProduto(MaterialServico produto) async {
    // Insere o produto na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_GRID_MATERIAL, produto.toJson(offline: true), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  List<MaterialServicoGrid> _converteListaMaterialServico(List<dynamic> lista, List<GridOSAgendadaModelo> osAgendada){
    List<MaterialServicoGrid> _resultado = new List<MaterialServicoGrid>();

    for(int i = 0; i < osAgendada.length; i++) {
      int osId = osAgendada[i].osId;
      lista[i]['lista'].forEach((produto) {
        produto['osId'] = osId;
      });
      lista[i]['sumario']['osId'] = osId;
      _resultado.add(MaterialServicoGrid.fromJson(lista[i]));
    }

    return _resultado;
  }

  int _countBatch(List<MaterialServicoGrid> lista) {
    int resultado = 0;
    lista.forEach((element) {
      resultado+= (element.lista.length ~/ 10) + (element.lista.length % 10 == 0 ? 0 : 1);
    });
    return resultado;
  }

  insertProdutosBatch(List<dynamic> materiaisServicos, List<GridOSAgendadaModelo> osAgendadas) async {
    List<MaterialServicoGrid> materiaisServicosResponseLista = _converteListaMaterialServico(materiaisServicos, osAgendadas);
    List<MaterialServico> listaMateriaisServicos = new List<MaterialServico>();

    // Insere os produtos na tabela via batches
    Database db = await dbProvider.database;
    int batchCounter = _countBatch(materiaisServicosResponseLista);
    int currentBatch = 0;

    for(int i = 0; i < materiaisServicosResponseLista.length; i++) {
      for(int j = 0; j < materiaisServicosResponseLista[i].lista.length; j++) {
        listaMateriaisServicos.add(materiaisServicosResponseLista[i].lista[j]);
        if ((j+1) % 10 == 0 || j+1 == materiaisServicosResponseLista[i].lista.length) {
          await db.transaction((txn) async {
            Batch batch = txn.batch();
            listaMateriaisServicos.forEach((element) {
              batch.insert(DBProvider.TABLE_GRID_MATERIAL, element.toJson(offline: true), conflictAlgorithm: ConflictAlgorithm.ignore);
            });
            // await batch.commit(continueOnError: true, noResult: true);

            // As duas últimaslinhas são apenas para confirmação de resultados
            // Foram omitidas para melhorar a performance
            var results = await batch.commit(continueOnError: true);
            currentBatch++;
            debugPrint(results.toString());
            return results;
          });
          listaMateriaisServicos.clear();
        }
      }

      await db.transaction((txn) async {
        Batch batch = txn.batch();
        batch.insert(DBProvider.TABLE_SUMARIO_GRID_MATERIAL, materiaisServicosResponseLista[i].sumario.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore);
        // await batch.commit(continueOnError: true, noResult: true);

        // As duas últimaslinhas são apenas para confirmação de resultados
        // Foram omitidas para melhorar a performance
        var results = await batch.commit(continueOnError: true);
        currentBatch++;
        debugPrint(results.toString());
        return results;
      });
    }
    
    if (currentBatch == batchCounter) return true;
    else return false;
  }

  insertProdutosBatchSingular(MaterialServicoGrid materiais) async {
    List<MaterialServico> listaProdutos = new List<MaterialServico>();
    // Insere os produtos na tabela via batches
    Database db = await dbProvider.database;
    int batchCounter = (materiais.lista.length ~/ 10) + (materiais.lista.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < materiais.lista.length; i++) {
      listaProdutos.add(materiais.lista[i]);
      if ((i+1) % 1000 == 0 || i+1 == materiais.lista.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaProdutos.forEach((element) {
            batch.insert(DBProvider.TABLE_GRID_MATERIAL, element.toJson(offline: true), conflictAlgorithm: ConflictAlgorithm.ignore);
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaProdutos.clear();
      }
      await db.transaction((txn) async {
        Batch batch = txn.batch();
        batch.insert(DBProvider.TABLE_SUMARIO_GRID_MATERIAL, materiais.sumario.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore);
        // await batch.commit(continueOnError: true, noResult: true);

        // As duas últimaslinhas são apenas para confirmação de resultados
        // Foram omitidas para melhorar a performance
        var results = await batch.commit(continueOnError: true);
        currentBatch++;
        debugPrint(results.toString());
        return results;
      });
    }


    if (currentBatch == batchCounter) return true;
    else return false;
  }

  updateMaterialServico(MaterialServico material) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_GRID_MATERIAL, material.toJson(offline: true), conflictAlgorithm: ConflictAlgorithm.replace);
    await _updateSumario(osId: material.osId);
    return res;
  }

  updateAllMaterialServico(MaterialServico material) async {
    await deleteAllMaterialServico();
    await insertProduto(material);
  }

  getMaterialServicoList({int skip = 0, int osId}) async {
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;
    // List<Map<String, dynamic>> res;
    var res = await db.query(
      DBProvider.TABLE_GRID_MATERIAL,
      where: 'osId = ?', whereArgs: [osId],
      limit: Request.TAKE, offset: skip
    );
    var res2 = await db.query(
      DBProvider.TABLE_SUMARIO_GRID_MATERIAL,
      where: 'osId = ?', whereArgs: [osId],
      limit: Request.TAKE, offset: skip
    );
    var retorno = {
      'lista': res,
      'sumario': res2[0]
    };
    return retorno;
  }

  deleteMaterialServico(MaterialServico material) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_GRID_MATERIAL, where: 'id = ?', whereArgs: [material.id]);
  }

  _updateSumario({@required int osId}) async {}

  deleteAllMaterialServico() async {
    // Realiza Truncate na tabela Cliente.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_GRID_MATERIAL);
      int res2 = await db.delete(DBProvider.TABLE_SUMARIO_GRID_MATERIAL);
    }
  }
}
