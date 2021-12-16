import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class ServicoService {
  RequestUtil _request = new RequestUtil();

  int _empresaId;

  Future<dynamic> buscaServicoCodigo({String produtoCodigo, int empresaId, List situacao, int}) async {
    return _request.getReq(
      endpoint: 'Produto/Lookup',
      data: {
        'codigo': produtoCodigo,
        'empresaId': empresaId
      },
    );
  }

  Future<dynamic> buscaServicoId({int produtoId, int empresaId}) async {
    return _request.getReq(
      endpoint: 'Produto/Lookup',
      data: {
        'id': produtoId,
        'empresaId': empresaId
      },
    );
  }

  Future<dynamic> listaServicos({int skip = 0, String search = '', List tipo, int situacao}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'Produto/Lookup',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId,
        'situacoes': situacao,
        'tipos': tipo
        
      }
    );
  }
}
