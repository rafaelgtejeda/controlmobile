import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/models/os/detalhe-os-agendada.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/models/os/osProximosChamados.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:flutter/material.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:sqflite/sqflite.dart';

class OrdemServicoService {

       RequestUtil _request = new RequestUtil();
  // GridOSAgendada gridOSitem = new GridOSAgendada();
  //  GridOSAgendada parameter = new GridOSAgendada();

     int _tecnicoId;
  String _dataInicial;
  String _dataFinal;
  
  /// 
  /// Endpoint 'OrdemServico/GridOSProximosChamados'
  /// 
  /// Endpoint 'OrdemServico/GridOSAgendada'
  /// 

  Future<dynamic> osService({int skip = 0, String search = '', String endpoint, String dia, String data}) async {

    _tecnicoId = await _request.obterIdUsuarioSharedPreferences();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    var data = {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'dataInicio': (dia == null || dia == '') ? _dataInicial: dia,
        'dataFim': (dia == null || dia == '') ? _dataFinal: dia,
        'tecnicoId': _tecnicoId
      };

    return _request.getReq(
      endpoint: endpoint,
      data: data
    );
  }

  Future<dynamic> gridProximosChamadosListagem({int skip = 0}) async {

    _tecnicoId = await _request.obterIdUsuarioSharedPreferences();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    var data = {
      'skip': skip * Request.TAKE,
      'take': Request.TAKE,
      'dataInicio': _dataInicial,
      'dataFim': _dataFinal,
      'tecnicoId': _tecnicoId
    };

    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.GRID_OS_PRXIMOS_CHAMADOS,
        data: data
      );
    }
    else {
      return await OrdemServicoProximosChamadosProvider().getProximosChamadosList(
        dataInicio: _dataInicial, dataFim: _dataFinal, skip: skip
      );
    }
  }

  Future<List<OsProximosChamados>> downloadTodosProximosChamados({String dataInicio, String dataFim}) async {
    _tecnicoId = await _request.obterIdUsuarioSharedPreferences();
    // _dataInicial = dataInicio ?? await _request.obterDataInicialSharedPreferences();
    // _dataFinal = dataFim ?? await _request.obterDataFinalSharedPreferences();
    DateTime _hoje = DateTime.now();

    _dataInicial = dataInicio ?? DateTime(
      _hoje.year,
      _hoje.month - 1,
      1
    ).toString();

    _dataFinal = dataFim ?? DateTime(
      _hoje.year,
      _hoje.month + 2,
      0,
      23, 59, 59, 999, 999
    ).toString();

    List<OsProximosChamados> _proximosChamados = List<OsProximosChamados>();
    dynamic resultado;
    resultado = await _request.getReq(
      endpoint: Endpoints.GRID_OS_PRXIMOS_CHAMADOS,
      data: {
        'dataInicio': _dataInicial,
        'dataFim': _dataFinal,
        'tecnicoId': _tecnicoId,
        'skip': 0,
        'take': 93
      },
      ignorarArmazenamentoAutomatico: true
    );
    resultado.forEach((e) => _proximosChamados.add(OsProximosChamados.fromJson(e)));
    return _proximosChamados;
  }

  Future<dynamic> gridOSAgendada({int skip = 0, String dia}) async {

    _tecnicoId = await _request.obterIdUsuarioSharedPreferences();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    var data = {
      'skip': skip * Request.TAKE,
      'take': Request.TAKE,
      'dataInicio': dia,
      'dataFim': dia,
      'tecnicoId': _tecnicoId
    };

    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.GRID_OS_AGENDADA,
        data: data
      );
    }
    else {
      return await OrdemServicoAgendadaProvider().getOSAgendadaList(data: dia, skip: skip);
    }
  }

  Future<List<GridOSAgendadaModelo>> downloadTodasOSAgendadas({String dataInicio, String dataFim}) async {
    _tecnicoId = await _request.obterIdUsuarioSharedPreferences();
    // _dataInicial = dataInicio ?? await _request.obterDataInicialSharedPreferences();
    // _dataFinal = dataFim ?? await _request.obterDataFinalSharedPreferences();
    DateTime _hoje = DateTime.now();
    _dataInicial = dataInicio ?? DateTime(
      _hoje.year,
      _hoje.month - 1,
      1
    ).toString();

    _dataFinal = dataFim ?? DateTime(
      _hoje.year,
      _hoje.month + 2,
      0,
      23, 59, 59, 999, 999
    ).toString();

    List<GridOSAgendadaModelo> _osAgendadas = List<GridOSAgendadaModelo>();
    dynamic resultado;
    resultado = await _request.getReq(
      endpoint: Endpoints.GRID_OS_AGENDADA,
      data: {
        'dataInicio': _dataInicial,
        'dataFim': _dataFinal,
        'tecnicoId': _tecnicoId,
        'ignorarPaginacao': true,
      },
      ignorarArmazenamentoAutomatico: true
    );
    resultado.forEach((e) => _osAgendadas.add(GridOSAgendadaModelo.fromJson(e)));
    return _osAgendadas;
  }

  Future<dynamic> osAgendadaDetalhes({int idOS}) async {
    dynamic data = {'id': idOS};

    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.DETALHE_OS_AGENDADA,
        data: data
      );
    }
    else {
      return await OrdemServicoAgendadaDetalhesProvider().getDetalhesOSList(osId: idOS);
    }
  }

  Future<List<dynamic>> downloadTodasOSAgendadaDetalhes(List<GridOSAgendadaModelo> osAgendada) async {
    List<DetalheOSAgendada> _listaDetalhesOS = new List<DetalheOSAgendada>();
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    osAgendada.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.DETALHE_OS_AGENDADA,
        data: {
          'id': element.id,
          // 'id': element.osId,
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    resultados.forEach((el) {
      _listaDetalhesOS.add(DetalheOSAgendada.fromJson(el));
    });
    return _listaDetalhesOS;
  }

  /// 
  /// Endpoint '/OrdemServico/Reagendar'
  /// 
  
  Future<dynamic> reagendar(String data, {BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.REAGENDAR,
      data: data,
      loading: true,
      context: context
    );
  }

  Future<dynamic> atualizarCheckListOS({String checklist, BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ATUALIZAR_STATUS_CHECKLISTS,
      data: checklist,
      context: context,
      loading: true
    );
  }

  Future<dynamic> getOSConfig({BuildContext context}) async {
    int empresaId = await _request.obterIdEmpresaShared();
    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.GET_OS_CONFIG,
        data: {
          'empresaId': empresaId
        },
        context: context,
        loading: true
      );
    }
    else {
      return await OrdemServicoGetOSConfigProvider().getOSConfigList(empresaId: empresaId);
    }
  }

  Future<List<OSConfig>> downloadTodasOsConfig(List<Empresa> empresa) async {
    List<OSConfig> _listaConfig = new List<OSConfig>();
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    empresa.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.GET_OS_CONFIG,
        data: {
          'empresaId': element.id,
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    resultados.forEach((el) {
      if(el is Response) {
        OSConfig vazio = new OSConfig();
        _listaConfig.add(vazio);
      }
      else {
        _listaConfig.add(OSConfig.fromJson(el));
      }
    });
    return _listaConfig;
  }

  Future<dynamic> getOSConfigMaterial({int osId}) async {
    if (await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.GET_OS_CONFIG_MATERIAL,
        data: {
          'id': osId
        },
      );
    }
    else {
      return await OrdemServicoGetOSConfigMaterialProvider().getOSConfigMaterialList(osId: osId);
    }
  }

  Future<List<OSConfigMaterial>> downloadTodasOsConfigMaterial(List<GridOSAgendadaModelo> empresa) async {
    List<OSConfigMaterial> _listaConfig = new List<OSConfigMaterial>();
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    empresa.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.GET_OS_CONFIG_MATERIAL,
        data: {
          'osId': element.osId,
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    resultados.forEach((el) {
      if(el is Response) {
        OSConfigMaterial vazio = new OSConfigMaterial();
        _listaConfig.add(vazio);
      }
      else {
        _listaConfig.add(OSConfigMaterial.fromJson(el));
      }
    });
    return _listaConfig;
  }

  Future<dynamic> getGridFinalizacaoTecnicoXServico({int osId, int osXTecId}) async {
    return _request.getReq(
      endpoint: Endpoints.GRID_FINALIZACAO_TECNICO_X_SERVICO,
      data: {
        'osId': osId,
        'osXTecId': osXTecId
      },
    );
  }

  Future<dynamic> atualizarStatusServicoXTecnico({String checkServico, BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ATUALIZAR_STATUS_SERVICO_X_TECNICO,
      data: checkServico,
      loading: true,
      context: context
    );
  }

  Future<dynamic> getGridFinalizacaoServicoXCheckList({int osXTecXServId, int osXTecId, int osXMatId}) async {
    return _request.getReq(
      endpoint: Endpoints.GRID_FINALIZACAO_SERVICO_X_CHECKLIST,
      data: {
        'osXTecXServId': osXTecXServId,
        'osXMatId': osXMatId,
        'osXTecId': osXTecId
      },
    );
  }

  Future<dynamic> atualizarStatusCheckXServico({String checkServico, BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ATUALIZAR_STATUS_CHECK_X_SERVICO,
      data: checkServico,
      loading: true,
      context: context
    );
  }

  Future<dynamic> finalizarOS({String finalizacaoOS, BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.FINALIZAR_TECNICO_OS,
      data: finalizacaoOS,
      loading: true,
      context: context
    );
  }

  Future<dynamic> atualizarStatusOS({String osStatus, BuildContext context}) async {
    return _request.putReq(
      endpoint: Endpoints.ATUALIZAR_STATUS_OS,
      data: osStatus,
      loading: true,
      context: context
    );
  }

}




class OrdemServicoProximosChamadosProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistenteProximosChamados() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_OS_PROXIMOS_CHAMADOS);
    return res.isNotEmpty;
  }

  insertProximoChamado(OsProximosChamados proximoChamado) async {
    // Insere o próximo chamado na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_OS_PROXIMOS_CHAMADOS, proximoChamado.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertOSProximosChamadosBatch(List<OsProximosChamados> proximosChamados) async {
    // Insere os próximos chamados na tabela via batches
    List<OsProximosChamados> listaProximosChamados = new List<OsProximosChamados>();
    Database db = await dbProvider.database;
    int batchCounter = (proximosChamados.length ~/ 10) + (proximosChamados.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < proximosChamados.length; i++) {
      listaProximosChamados.add(proximosChamados[i]);
      if ((i+1) % 10 == 0 || i+1 == proximosChamados.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaProximosChamados.forEach((element) {
            batch.insert(
              DBProvider.TABLE_OS_PROXIMOS_CHAMADOS, element.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore
            );
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaProximosChamados.clear();
      }
    }

    if(currentBatch == batchCounter) return true;
    else return false;
  }

  updateProximoChamado(OsProximosChamados proximoChamado) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_OS_PROXIMOS_CHAMADOS, proximoChamado.toJson());
    return res;
  }

  updateAllProximosChamados(OsProximosChamados proximoChamado) async {
    await deleteAllProximosChamados();
    await insertProximoChamado(proximoChamado);
  }

  // getProximosChamadosList({int skip = 0, int idVendedor, String search = ''}) async {
  getProximosChamadosList({int skip = 0, String dataInicio, String dataFim}) async {
    // int dataInicial = DateTime.parse(dataInicio).toUtc().millisecondsSinceEpoch;
    int dataInicial = DateTime.parse(dataInicio).millisecondsSinceEpoch;
    // int dataFinal = DateTime.parse(dataFim).toUtc().millisecondsSinceEpoch;
    int dataFinal = DateTime.parse(dataFim).millisecondsSinceEpoch;
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;
    
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_OS_PROXIMOS_CHAMADOS,
      where: 'date BETWEEN ? AND ?', whereArgs: [dataInicial, dataFinal],
      limit: Request.TAKE, offset: skip
    );
    return res;
  }

  deleteProximoChamado(OsProximosChamados proximoChamado) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_OS_PROXIMOS_CHAMADOS, where: 'id = ?', whereArgs: [proximoChamado]);
  }

  deleteAllProximosChamados() async {
    // Realiza Truncate na tabela Vendedor.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistenteProximosChamados()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_OS_PROXIMOS_CHAMADOS);
    }
  }
}

class OrdemServicoAgendadaProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistenteOSAgendada() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_OS_AGENDADA);
    return res.isNotEmpty;
  }

  insertOSAgendada(GridOSAgendadaModelo osAgendada) async {
    // Insere o próximo chamado na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_OS_AGENDADA, osAgendada.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertOSAgendadaBatch(List<GridOSAgendadaModelo> osAgendada) async {
    // Insere os próximos chamados na tabela via batches
    List<GridOSAgendadaModelo> listaOSAgendada = new List<GridOSAgendadaModelo>();
    Database db = await dbProvider.database;
    int batchCounter = (osAgendada.length ~/ 10) + (osAgendada.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < osAgendada.length; i++) {
      listaOSAgendada.add(osAgendada[i]);
      if ((i+1) % 10 == 0 || i+1 == osAgendada.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaOSAgendada.forEach((element) {
            batch.insert(
              DBProvider.TABLE_OS_AGENDADA, element.toJson(), conflictAlgorithm: ConflictAlgorithm.replace
            );
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaOSAgendada.clear();
      }
    }

    if(currentBatch == batchCounter) return true;
    else return false;
  }

  updateOSAgendada(OsProximosChamados osAgendada) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_OS_AGENDADA, osAgendada.toJson());
    return res;
  }

  updateAllOSAgendada(GridOSAgendadaModelo osAgendada) async {
    await deleteAllOSAgendada();
    await insertOSAgendada(osAgendada);
  }

  getOSAgendadaList({int skip = 0, String data}) async {
    // String dataConvertida = DateTime.parse(data).toUtc();
    String dataConvertida = DateTime.parse(data).toIso8601String();
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;

    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_OS_AGENDADA,
      where: 'data = ?', whereArgs: [dataConvertida],
      limit: Request.TAKE, offset: skip
    );
    return res;
  }

  deleteOSAgendada(GridOSAgendadaModelo osAgendada) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_OS_AGENDADA, where: 'id = ?', whereArgs: [osAgendada.id]);
  }

  deleteAllOSAgendada() async {
    // Realiza Truncate na tabela Vendedor.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistenteOSAgendada()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_OS_AGENDADA);
    }
  }
}

class OrdemServicoAgendadaDetalhesProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_OS_AGENDADA_DETALHES);
    return res.isNotEmpty;
  }
  
  // insertEmpresaAcesso(DiretivasAcessoModelo diretivas) async {
  insertDetalhesOS({DetalheOSAgendada osAgendada}) async {
    // Insere a diretiva na tabela
    Database db = await dbProvider.database;
    var osDetalhes = {
      'id': osAgendada.id,
      'osId': osAgendada.osId,
      'object': json.encode(osAgendada)
    };

    int res = await db.insert(DBProvider.TABLE_OS_AGENDADA_DETALHES, osDetalhes, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertDetalhesOSBatch(List<DetalheOSAgendada> detalhesOS) async {
    // Insere as detalhes OS na tabela via batches
    List<DetalheOSAgendada> listaDetalhesOSBatch = new List<DetalheOSAgendada>();
    Database db = await dbProvider.database;
    int batchCounter = (detalhesOS.length ~/ 10) + (detalhesOS.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < detalhesOS.length; i++) {
      listaDetalhesOSBatch.add(detalhesOS[i]);
      if ((i+1) % 10 == 0 || i+1 == detalhesOS.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaDetalhesOSBatch.forEach((element) {
            var detalheOSAgendada = {
              'id': element.id,
              'osId': element.osId,
              'object': json.encode(element)
            };
            batch.insert(DBProvider.TABLE_OS_AGENDADA_DETALHES, detalheOSAgendada, conflictAlgorithm: ConflictAlgorithm.ignore);
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          debugPrint(results.toString());
        });
        listaDetalhesOSBatch.clear();
      }
    }

    if(currentBatch == batchCounter) return true;
    else return false;
  }

  updateEmpresaAcesso(DetalheOSAgendada detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_OS_AGENDADA_DETALHES, detalhesOS.toJson());
    return res;
  }

  updateAllEmpresaAcesso(DetalheOSAgendada detalhesOS) async {
    await deleteAllDetalhesOS();
    // await insertEmpresaAcesso(diretiva);
  }

  Future<dynamic> getDetalhesOSList({int osId}) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_OS_AGENDADA_DETALHES,
      where: 'id = ?', whereArgs: [osId],
      // where: 'osId = ?', whereArgs: [osId],
    );

    dynamic empresaAcessosJson = json.decode(res[0]['object']);

    return empresaAcessosJson;
  }

  deleteEmpresaAcesso(DetalheOSAgendada detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_OS_AGENDADA_DETALHES, where: 'id = ?', whereArgs: [detalhesOS.id]);
  }

  deleteAllDetalhesOS() async {
    // Realiza Truncate na tabela Diretivas.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_OS_AGENDADA_DETALHES);
    }
  }
}

class OrdemServicoGetOSConfigProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_GET_OS_CONFIG);
    return res.isNotEmpty;
  }
  
  // insertEmpresaAcesso(DiretivasAcessoModelo diretivas) async {
  insertGetOSConfig({dynamic osConfig, int empresaId}) async {
    // Insere a diretiva na tabela
    Database db = await dbProvider.database;
    var osDetalhes = {
      'empresaId': empresaId,
      'object': json.encode(osConfig)
    };

    int res = await db.insert(DBProvider.TABLE_GET_OS_CONFIG, osDetalhes, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertGetOSConfigBatch(List<OSConfig> osConfigList, List<Empresa> empresas) async {
    // Insere as detalhes OS na tabela via batches
    List<OSConfig> listaDetalhesOSBatch = new List<OSConfig>();
    Database db = await dbProvider.database;
    int batchCounter = (osConfigList.length ~/ 10) + (osConfigList.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < osConfigList.length; i++) {
      // listaDetalhesOSBatch.add(detalhesOS[i]);
      // if ((i+1) % 10 == 0 || i+1 == detalhesOS.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          // listaDetalhesOSBatch.forEach((element) {
            var detalheOSAgendada = {
              'empresaId': empresas[i].id,
              'object': json.encode(osConfigList[i])
            };
            batch.insert(DBProvider.TABLE_GET_OS_CONFIG, detalheOSAgendada, conflictAlgorithm: ConflictAlgorithm.ignore);
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

  updateGetOSConfig(OSConfig detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_GET_OS_CONFIG, detalhesOS.toJson());
    return res;
  }

  updateAllGetOSConfig(OSConfig detalhesOS) async {
    await deleteAllgetOSConfig();
    // await insertEmpresaAcesso(diretiva);
  }

  Future<dynamic> getOSConfigList({int empresaId}) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_GET_OS_CONFIG,
      where: 'empresaId = ?', whereArgs: [empresaId],
    );

    dynamic empresaAcessosJson = json.decode(res[0]['object']);

    return empresaAcessosJson;
  }

  deleteEmpresaAcesso(OSConfig detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_GET_OS_CONFIG, where: 'empresaId = ?', whereArgs: [detalhesOS]);
  }

  deleteAllgetOSConfig() async {
    // Realiza Truncate na tabela Diretivas.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_GET_OS_CONFIG);
    }
  }
}

class OrdemServicoGetOSConfigMaterialProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL);
    return res.isNotEmpty;
  }
  
  // insertEmpresaAcesso(DiretivasAcessoModelo diretivas) async {
  insertGetOSConfigMaterial({OSConfigMaterial osConfigMaterial, int osId}) async {
    // Insere a diretiva na tabela
    Database db = await dbProvider.database;
    var osDetalhes = {
      'osId': osId,
      'object': json.encode(osConfigMaterial)
    };

    int res = await db.insert(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL, osDetalhes, conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertGetOSConfigMaterialBatch(List<OSConfigMaterial> configMaterial, List<GridOSAgendadaModelo> osAgendada) async {
    // Insere as detalhes OS na tabela via batches
    List<OSConfigMaterial> listaDetalhesOSBatch = new List<OSConfigMaterial>();
    Database db = await dbProvider.database;
    int batchCounter = (configMaterial.length ~/ 10) + (configMaterial.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < configMaterial.length; i++) {
      // listaDetalhesOSBatch.add(detalhesOS[i]);
      // if ((i+1) % 10 == 0 || i+1 == detalhesOS.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          // listaDetalhesOSBatch.forEach((element) {
            var osConfigMaterial = {
              'osId': osAgendada[i].id,
              'object': json.encode(configMaterial[i])
            };
            batch.insert(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL, osConfigMaterial, conflictAlgorithm: ConflictAlgorithm.ignore);
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

  updateGetOSConfigMaterial(OSConfigMaterial detalhesOS) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL, detalhesOS.toJson());
    return res;
  }

  updateAllGetOSConfigMaterial(OSConfigMaterial detalhesOS) async {
    await deleteAllgetOSConfigMaterial();
    // await insertEmpresaAcesso(diretiva);
  }

  Future<dynamic> getOSConfigMaterialList({int osId}) async {
    Database db = await dbProvider.database;
    List<Map<String, dynamic>> res;
    res = await db.query(
      DBProvider.TABLE_GET_OS_CONFIG_MATERIAL,
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

  deleteEmpresaAcesso(int osId) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL, where: 'osId = ?', whereArgs: [osId]);
  }

  deleteAllgetOSConfigMaterial() async {
    // Realiza Truncate na tabela Diretivas.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_GET_OS_CONFIG_MATERIAL);
    }
  }
}
