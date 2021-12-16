import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class GrupoContatoService {

  RequestUtil request = new RequestUtil();
  int empresaId;

  Future<dynamic> getGrupoContato(int idGrupoContato) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'GrupoDeContato/Lookup/', 
      data: {
        'id': idGrupoContato,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> listaGrupoContato({int skip = 0, String search = ''}) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'GrupoDeContato/Lookup/', 
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> adicionaGrupoContato(String contato, {BuildContext context}) async {
    return await request.postReq(
      endpoint: 'GrupoDeContato/', 
      data: contato,
      context: context
    );
  }
}
