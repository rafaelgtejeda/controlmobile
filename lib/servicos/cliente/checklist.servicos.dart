import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class CheckListService {

  RequestUtil _request = new RequestUtil();

  Future<dynamic> checkListLista({int skip = 0, String search = '', int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CheckLists',
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'parceiroId': parceiroId
      }
    );
  }
  
  Future<dynamic> getCheckList({int idCheckList, BuildContext context}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CheckList/$idCheckList',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarCheckList({@required String checkList, BuildContext context}) async {
    return _request.postReq(
      endpoint: 'Parceiro/CheckList',
      data: checkList,
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarCheckList({@required String checkList, BuildContext context}) async {
    return _request.putReq(
      endpoint: 'Parceiro/CheckList',
      data: checkList,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaCheckList({@required int idCheckList, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/CheckList/$idCheckList',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosCheckLists({BuildContext context, int parceiroId}) async {
    return _request.getReq(
      endpoint: 'Parceiro/CheckList/SelecionarTodos/',
      data: {
        'parceiroId': parceiroId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaCheckListsLote({@required List<int> idCheckLists, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: 'Parceiro/CheckList/',
      data: idCheckLists,
      loading: true,
      context: context
    );
  }
}
