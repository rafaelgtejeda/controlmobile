import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class OutrosEnderecosService {
  RequestUtil _request = new RequestUtil();

  Future<dynamic> enderecosListaTeste({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Enderecos',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      }
    );
  }

  Future<dynamic> getEnderecoTeste({@required int idEndereco, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Endereco/$idEndereco',
      data: null,
      context: context,
      loading: true
    );
  }

  Future<dynamic> adicionarEndereco({@required String endereco, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/Endereco/',
      data: endereco,
      context: context,
      loading: true
    );
  }

  Future<dynamic> editarEndereco({@required String endereco, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/Endereco/',
      data: endereco,
      context: context,
      loading: true
    );
  }

  Future<dynamic> getTiposEnderecosTeste(int parceiroId) async {
    return _request.getReq(
      endpoint: 'Parceiro/Endereco/TiposEndereco/',
      data: {
        'parceiroId': parceiroId
      }
    );
  }

  Future<dynamic> deletaEndereco({@required int idEndereco, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/Endereco/$idEndereco',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosEnderecos({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/Endereco/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaEnderecosLote({@required List<int> idEnderecos, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/Endereco/',
      data: idEnderecos,
      loading: true,
      context: context
    );
  }
}
