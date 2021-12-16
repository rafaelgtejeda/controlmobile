import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:erp/utils/request.util.dart';

class ParametroService {
  RequestUtil _request = new RequestUtil();
  int _empresaId;

  Future<dynamic> getParametro({int parametro}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'Parametro/',
      data: {
        'param': parametro,
        'empresaId': _empresaId
      }
    );
  }

  Future<dynamic> getParametroPadraoLimiteCredito() async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'Parametro',
      data: {
        'param': ParametrosConstante.PADRAO_LIMITE_CREDITO,
        'empresaId': _empresaId
      }
    );
  }
}

class ParametrosConstante {
  static const int PADRAO_LIMITE_CREDITO = 45;
}
