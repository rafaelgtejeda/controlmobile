import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class CidadeEstrangeiraService {
  RequestUtil request = new RequestUtil();

  Future<dynamic> getCidadeEstrangeira(int idCidadeEstrangeira) async {
    return await request.getReq(
      endpoint: 'Cidade/Lookup/', 
      data: {
        'id': idCidadeEstrangeira,
        'skip': Request.SKIP,
        'take': Request.TAKE,
        'search': "",
      }
    );
  }

  // Future<dynamic> getCidadeEstrangeiraTeste(int idCidadeEstrangeira) async {
  //   return await request.get(
  //     endpoint: 'Cidade/Lookup/', 
  //     data: {
  //       'id': idCidadeEstrangeira,
  //       'skip': Request.SKIP,
  //       'take': Request.TAKE,
  //       'search': "",
  //     }
  //   );
  // }

  Future<dynamic> listaCidadeEstrangeira({int skip = 0, String search}) async {
    return await request.getReq(
      endpoint: 'Cidade/Lookup/', 
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
      }
    );
  }
}
