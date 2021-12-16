import 'package:flutter/widgets.dart';
import 'package:erp/servicos/cliente/lookup/formaPagamento.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class LimiteCreditoService {
  RequestUtil _request = new RequestUtil();
  FormasPagamentoService formaPagamento = new FormasPagamentoService();

  Future<dynamic> limitesCreditoLista({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/LimitesCredito',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      },
    );
  }

  Future<dynamic> getLimiteCredito({@required int idLimite, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/LimiteCredito/$idLimite',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarLimiteCredito({@required String limite, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/LimiteCredito/',
      data: limite,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarLimiteCredito({@required String limite, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/LimiteCredito/',
      data: limite,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaLimite({@required int idLimite, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/LimiteCredito/$idLimite',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosLimites({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/LimiteCredito/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaLimitesLote({@required List<int> idLimites, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/LimiteCredito/',
      data: idLimites,
      loading: true,
      context: context
    );
  }
}
