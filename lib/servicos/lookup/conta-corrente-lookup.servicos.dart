import 'package:flutter/widgets.dart';
import 'package:erp/utils/request.util.dart';

class ContaCorrenteLookupService {

  RequestUtil _request = new RequestUtil();

  int _empresaId;
  
  Future<dynamic> obterContas({BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'ContaCorrente/Lookup/',
      data: {
        'empresaId': _empresaId,
      },
      loading: true,
      context: context
    );
  }
}
