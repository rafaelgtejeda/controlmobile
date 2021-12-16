import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class OrcamentoService {
  RequestUtil _request = new RequestUtil();

  int _empresaId;
  String _dataInicio;
  String _dataFim;
  int _usuarioId;

  Future<dynamic> orcamentosLista({int status, String search = '', int skip = 0}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _dataInicio = await _request.obterDataInicialSharedPreferences();
    _dataFim = await _request.obterDataFinalSharedPreferences();
    _usuarioId = await _request.obterIdUsuarioSharedPreferences();
    
    return _request.getReq(
      endpoint: Endpoints.ORCAMENTOS,
      data: {
        'skip': Request.TAKE * skip,
        'take': Request.TAKE,
        'search': search,
        'dataInicio': _dataInicio,
        'dataFim': _dataFim,
        'empresaId': _empresaId,
        'usuarioId': _usuarioId,
        'status': status
      }
    );
  }

  Future<dynamic> getOrcamento({int id, BuildContext context}) async {
    return _request.getReq(
      endpoint: Endpoints.ORCAMENTO_OBTER,
      data: {
        'id': id
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaOrcamento({int idOrcamento, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: '${Endpoints.ORCAMENTO_REMOVER}?id=$idOrcamento',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> obterParcelasVencimentos({BuildContext context, String infoParcela}) async {
    return _request.postReq(
      endpoint: Endpoints.ORCAMENTO_OBTER_PARCELAS_VENCIMENTOS,
      data: infoParcela,
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarOrcamento(String orcamento, {BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ORCAMENTO_INCLUIR,
      data: orcamento,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarOrcamento(String orcamento, {BuildContext context}) async {
    return _request.putReq(
      endpoint: Endpoints.ORCAMENTO_ATUALIZAR,
      data: orcamento,
      loading: true,
      context: context
    );
  }

  Future<dynamic> obterOrcamentoPDF({int orcamentoId, BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();

    return _request.getReq(
      endpoint: Endpoints.ORCAMENTO_PDF,
      data: {
        'orcamentoId': orcamentoId,
        'empresaId': _empresaId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> assinarOrcamento(String orcamentoAssinado, {BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.ORCAMENTO_ASSINAR,
      data: orcamentoAssinado,
      loading: true,
      context: context
    );
  }
}
