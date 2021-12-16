import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class FormasPagamentoService {
  RequestUtil _request = new RequestUtil();
  int _empresaId;

  Future<dynamic> buscaFormasPorId({int idForma, @required int tipoRetorno}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return await _request.getReq(
      endpoint: 'FormaPagamento/LookupFormaPagamento/', 
      data: {
        'id': idForma,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
        'empresaId': _empresaId,
        'tipoRetorno': tipoRetorno,
      }
    );
  }

  Future<dynamic> buscaFormaPorCodigo({int formaPagamentoCodigo, int parceiroId, @required int tipoRetorno}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'FormaPagamento/LookupFormaPagamento/',
      data: {
        'codigo': formaPagamentoCodigo,
        'empresaId': _empresaId,
        'parceiroId': parceiroId,
        'tipoRetorno': tipoRetorno,
      },
    );
  }

  Future<dynamic> listaFormas({int skip = 0, String search = '', int parceiroId, @required int tipoRetorno}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'FormaPagamento/LookupFormaPagamento/',
      data: {
        'skip': skip * Request.SKIP,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId,
        'parceiroId': parceiroId,
        'tipoRetorno': tipoRetorno,
      }
    );
  }

  Future<dynamic> listaFormasOrcamento({int skip = 0, String search = '', int parceiroId, @required int tipoRetorno}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'FormaPagamento/LookupFormaPagamento/',
      data: parceiroId == null ? {
        'skip': skip * Request.SKIP,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId,
        'tipoRetorno': tipoRetorno,
      }
      : {
        'skip': skip * Request.SKIP,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId,
        'parceiroId': parceiroId,
        'tipoRetorno': tipoRetorno,
      }
    );
  }
}
