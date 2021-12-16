
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class TabelaPrecoService {

  RequestUtil request = new RequestUtil();
  int empresaId;

  Future<dynamic> getTabelaPreco(int idTabelaPreco) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'TabelaDePreco/Lookup/', 
      data: {
        'id': idTabelaPreco,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
        'empresaId': empresaId
      }
    );
  }

  Future<dynamic> listaTabelaPreco({int skip = 0, String search = ''}) async {
    empresaId = await request.obterIdEmpresaShared();
    return await request.getReq(
      endpoint: 'TabelaDePreco/Lookup/', 
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': empresaId
      }
    );
  }
}
