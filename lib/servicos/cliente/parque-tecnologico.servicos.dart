import 'package:flutter/widgets.dart';
import 'package:erp/servicos/produto/produto.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class ParqueTecnologicoService {
  RequestUtil _request = new RequestUtil();
  ProdutoService produto = new ProdutoService();

  Future<dynamic> parqueTecnologicoListaTeste({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/ParqueTecnologicos',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      },
    );
  }

  Future<dynamic> getParqueTecnologicoTeste({@required int idParque, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/ParqueTecnologico/$idParque',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarParqueTecnologico({@required String parque, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/ParqueTecnologico/',
      data: parque,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarParqueTecnologico({@required String parque, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/ParqueTecnologico/',
      data: parque,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaParque({@required int idParque, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/ParqueTecnologico/$idParque',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosParques({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/ParqueTecnologico/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaParquesLote({@required List<int> idParques, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/ParqueTecnologico/',
      data: idParques,
      loading: true,
      context: context
    );
  }
}
