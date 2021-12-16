import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class RamoAtividadeService {
  RequestUtil request = new RequestUtil();
  int empresaId;

  Future<dynamic> getRamoAtividade(int idRamoAtividade) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'RamoDeAtividade/Lookup', 
      data: {
        'id': idRamoAtividade,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> listaRamoAtividade({int skip = 0, String search = ''}) async {
    empresaId = await request.obterIdEmpresaShared();
    return request.getReq(
      endpoint: 'RamoDeAtividade/Lookup/',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> getUltimoCodigoRamoAtividade() async {
    empresaId = await request.obterIdEmpresaShared();
    return request.getReq(
      endpoint: 'RamoDeAtividade/UltimoCodigoInserido/',
      data: {
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> adicionaRamoAtividade(String ramoAtividade, {BuildContext context}) async {
    return request.postReq(
      endpoint: 'RamoDeAtividade/',
      data: ramoAtividade,
      context: context
    );
  }
}
