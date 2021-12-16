import 'package:flutter/widgets.dart';
import 'package:erp/servicos/email-sms/email-sms.servico.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class CobrancaPagamentoService {
  RequestUtil _request = new RequestUtil();
  int _empresaId;
  EmailSMSService emailSMS = new EmailSMSService();

  Future<dynamic> cartoesLista({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CartoesDeCredito',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      },
    );
  }

  Future<dynamic> getCartao({@required int idCartao, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CartaoDeCredito/$idCartao',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> getCartaoLink(int parceiroId, {BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: 'Parceiro/CartaoDeCredito/LinkRegistro',
      data: {
        'parceiroId': parceiroId,
        'empresaId': _empresaId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarCartao({@required String cartao, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/CartaoDeCredito/',
      data: cartao,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarCartao({@required String cartao, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/CartaoDeCredito/',
      data: cartao,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaCartao({@required int idCartao, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/CartaoDeCredito/$idCartao',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosCartoes({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CartaoDeCredito/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaCartoesLote({@required List<int> idCartoes, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/CartaoDeCredito/',
      data: idCartoes,
      loading: true,
      context: context
    );
  }
}
