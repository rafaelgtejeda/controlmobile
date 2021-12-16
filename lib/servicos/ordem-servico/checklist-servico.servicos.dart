import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:erp/models/os/checklist-os-grid.modelo.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:sqflite/sqflite.dart';

class ChecklistService {
  RequestUtil _request = new RequestUtil();
  int osId;

  Future<dynamic> getChecklistServico({int osId}) async {
    if(await _request.verificaOnline()) {
      return _request.getReq(
        // endpoint: '/OrdemServico/GridCheckList/',
        endpoint: Endpoints.GRID_CHECKLISTS_OS,
        data: {'osId': osId}
      );
    }
    else {
      return await CheckListOSProvider().getCheckListOS(osId: osId);
    }
  }

  Future<List<dynamic>> downloadTodasOsConfigMaterial({List<GridOSAgendadaModelo> osAgendada}) async {
    List<dynamic> _listaConfig = new List<dynamic>();
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    osAgendada.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.GRID_CHECKLISTS_OS,
        data: {
          'osId': element.osId,
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    // resultados.forEach((el) {
    //   if(el is Response) {
    //     OSConfigMaterial vazio = new OSConfigMaterial();
    //     _listaConfig.add(vazio);
    //   }
    //   else {
    //     _listaConfig.add(OSConfigMaterial.fromJson(el));
    //   }
    // });
    return resultados;
    // return _listaConfig;
  }

  // Future<dynamic> adicionaMaterialServico(
  //     {String materialServico, BuildContext context}) async {
  //   return _request.postReq(
  //       endpoint: '/OrdemServico/AdicionarMaterial',
  //       data: materialServico,
  //       loading: true,
  //       context: context);
  // }

  // Future<dynamic> deletaMaterialServico(
  //     {@required int idMaterialServico, BuildContext context}) async {
  //   return _request.deleteReq(
  //       endpoint: '/OrdemServico/RemoverMaterial/$idMaterialServico',
  //       data: null,
  //       loading: true,
  //       context: context);
  // }
}

class CheckListOSProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_GRID_CHECKLIST_OS);
    return res.isNotEmpty;
  }
  
  // insertEmpresaAcesso(DiretivasAcessoModelo diretivas) async {
  insertCheckListOS({dynamic listaCheckListJson, int osId}) async {
    // Insere a diretiva na tabela
    Database db = await dbProvider.database;
    var osDetalhes = {
      'osId': osId,
      'object': json.encode(listaCheckListJson)
    };

    int res = await db.insert(DBProvider.TABLE_GRID_CHECKLIST_OS, osDetalhes, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertChecklistOSBatch(List<dynamic> listaCheckListJson, List<GridOSAgendadaModelo> osAgendada) async {
    // Insere as detalhes OS na tabela via batches
    List<dynamic> listaDetalhesOSBatch = new List<dynamic>();
    Database db = await dbProvider.database;
    int batchCounter = (listaCheckListJson.length ~/ 10) + (listaCheckListJson.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < listaCheckListJson.length; i++) {
      // listaDetalhesOSBatch.add(detalhesOS[i]);
      // if ((i+1) % 10 == 0 || i+1 == detalhesOS.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          // listaDetalhesOSBatch.forEach((element) {
            var osCheckList = {
              'osId': osAgendada[i].osId,
              'object': json.encode(listaCheckListJson[i])
            };
            batch.insert(DBProvider.TABLE_GRID_CHECKLIST_OS, osCheckList, conflictAlgorithm: ConflictAlgorithm.ignore);
          // });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          debugPrint(results.toString());
        });
        // listaDetalhesOSBatch.clear();
      // }
    }

    // if(currentBatch == batchCounter) return true;
    // else return false;

    return true;
  }

  updateCheckListOS(ChecklistOSGrid detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_GRID_CHECKLIST_OS, detalhesOS.toJson());
    return res;
  }

  updateAllCheckListOS(ChecklistOSGrid detalhesOS) async {
    await deleteAllCheckListOS();
    // await insertEmpresaAcesso(diretiva);
  }

  Future<dynamic> getCheckListOS({int osId}) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_GRID_CHECKLIST_OS,
      where: 'osId = ?', whereArgs: [osId],
    );

    if (res != []) {
      dynamic empresaAcessosJson = json.decode(res[0]['object']);
      return empresaAcessosJson;
    }
    else {
      return null;
    }

  }

  deleteCheckListOS(int osId) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_GRID_CHECKLIST_OS, where: 'osId = ?', whereArgs: [osId]);
  }

  deleteAllCheckListOS() async {
    // Realiza Truncate na tabela Diretivas.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_GRID_CHECKLIST_OS);
    }
  }
}
