import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class RegiaoService {
  RequestUtil request = new RequestUtil();
  int empresaId;

  Future<dynamic> getRegiao(int idRegiao) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'Regiao/Lookup/', 
      data: {
        'id': idRegiao,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> listaRegiao({int skip = 0, String search = ''}) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'Regiao/Lookup/', 
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> adicionaRegiao(String regiao, {BuildContext context}) async {
    return await request.postReq(
      endpoint: 'Regiao/', 
      data: regiao,
      context: context
    );
  }
}
