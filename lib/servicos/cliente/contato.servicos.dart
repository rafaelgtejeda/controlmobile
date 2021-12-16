import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class ContatoService {
  RequestUtil _request = new RequestUtil();

  Future<dynamic> contatosListaTeste({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Contatos',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      },
    );
  }

  Future<dynamic> getContatoTeste({@required int idContato, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Contato/$idContato',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarContato({@required String contato, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/Contato/',
      data: contato,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarContato({@required String contato, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/Contato/',
      data: contato,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaContato({@required int idContato, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/Contato/$idContato',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosContatos({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Contato/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaContatosLote({@required List<int> idContatos, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/Contato/',
      data: idContatos,
      loading: true,
      context: context
    );
  }
}
