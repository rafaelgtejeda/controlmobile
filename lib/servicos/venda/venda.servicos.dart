import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class VendaService {
  RequestUtil _request = new RequestUtil();

  int _empresaId;
  String _dataInicio;
  String _dataFim;

  Future<dynamic> dashboardVendas() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicio = await _request.obterDataInicialSharedPreferences();
    _dataFim = await _request.obterDataFinalSharedPreferences();
    
    return _request.getReq(
      endpoint: 'DashboardVenda/DadosPrincipais',
      data: {
        'empresaId': _empresaId,
        'dataInicio': _dataInicio,
        'dataFim': _dataFim,
      }
    );
  }

  Future<dynamic> vendas({int skip = 0, String search = '', @required int status}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicio = await _request.obterDataInicialSharedPreferences();
    _dataFim = await _request.obterDataFinalSharedPreferences();
    
    return _request.getReq(
      endpoint: 'Vendas',
      data: {
        'empresaId': _empresaId,
        'dataInicio': _dataInicio,
        'dataFim': _dataFim,
        'skip': Request.TAKE * skip,
        'take': Request.TAKE,
        'search': search,
        'status': status
      }
    );
  }

  Future<dynamic> obterVendaDetalhes({int id, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Venda/ObterVenda',
      data: {
        'id': id,
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> obterComparativoVendas() async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicio = await _request.obterDataInicialSharedPreferences();
    _dataFim = await _request.obterDataFinalSharedPreferences();
    
    return _request.getReq(
      endpoint: 'Venda/ObterComparativoVenda',
      data: {
        'empresaId': _empresaId,
        'dataInicio': _dataInicio,
        'dataFim': _dataFim,
      }
    );
  }

  Future<dynamic> obterVendaPDF({int vendaId, BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    
    return _request.getReq(
      endpoint: 'Venda/Pdf',
      data: {
        'empresaId': _empresaId,
        'vendaId': vendaId
      },
      context: context,
      loading: true
    );
  }
}
