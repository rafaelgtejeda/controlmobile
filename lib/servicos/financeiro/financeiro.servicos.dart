import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:erp/servicos/lookup/conta-corrente-lookup.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class FinanceiroService {

  RequestUtil _request = new RequestUtil();

  int _empresaId;
  String _dataInicial;
  String _dataFinal;
  List<String> _contasIds;
  Response response = new Response(); 

  ContaCorrenteLookupService contaCorrente = new ContaCorrenteLookupService();

  Future<String> _retornaContasString() async {
    _contasIds = await _request.obterIdsContasSharedPreferences();
    String contasString = '';
    for(int i = 0; i < _contasIds.length; i++) {
      if(i == 0) {
        contasString += '${_contasIds[i]}';
      }
      else {
        contasString += ',${_contasIds[i]}';
      }
    }
    return contasString;
  }

  Future<dynamic> obterDashboard() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_DASHBOARD,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal
      }
    );
  }

  Future<dynamic> obterDRE({int tipo}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();
    
    
    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_DRE,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
        'tipo': tipo
      }
    );
  }

  Future<dynamic> obterPrevistoRealizado() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();
    
    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_PREVISTO_REALIZADO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
      }
    );
  }

  Future<dynamic> obterContasAReceber() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_LANCAMENTO_PREVISTO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
        'tipoRetorno': 1
      }
    );
  }

  Future<dynamic> obterContasAPagar() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_LANCAMENTO_PREVISTO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
        'tipoRetorno': 2
      }
    );
  }

  Future<dynamic> obterLancamentosPrevistoRealizadoReceita() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_LANCAMENTO_PREVISTO_REALIZADO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
        'tipoRetorno': 3
      }
    );
  }

  Future<dynamic> obterLancamentosPrevistoRealizadoDespesa({@required int categoria}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = await _request.obterDataInicialSharedPreferences();
    _dataFinal = await _request.obterDataFinalSharedPreferences();

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_LANCAMENTO_PREVISTO_REALIZADO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
        'tipoRetorno': 4,
        'categoria': categoria
      }
    );
  }

  Future<dynamic> obterHistoricoLancamentos({String dataInicial}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = dataInicial;

    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_HISTORICO_LANCAMENTO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
      }
    );
  }

  Future<dynamic> obterComparativo({String dataInicial, String dataFinal}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicial = dataInicial;
    _dataFinal = dataFinal;
    
    String contasIdsString = '';
    contasIdsString = await _retornaContasString();

    return _request.getReq(
      endpoint: Endpoints.FINANCEIRO_OBTER_COMPARATIVO,
      data: {
        'contas': contasIdsString,
        'empresaId': _empresaId,
        'dataInicial': _dataInicial,
        'dataFinal': _dataFinal,
      }
    );
  }
}
