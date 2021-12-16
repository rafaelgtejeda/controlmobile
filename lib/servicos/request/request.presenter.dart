import 'package:erp/servicos/request/request.servico.dart';

abstract class RequestContract {
  // ->
  void onLoginSucesso(dynamic resposta);
  void onLoginErro(String errorTxt);
  // ->
}

class RequestPresenter {
  // ->
  RequestContract _view;
  RequestService api = new RequestService();
  RequestPresenter(this._view);
  // ->
  doExecutaRequest(
      String method, String endpoint, dynamic data, dynamic params) {
    api.executaRequest(method, endpoint, data, params).then((resposta) {
      _view.onLoginSucesso(resposta);
    }).catchError((Object error) => _view.onLoginErro(error.toString()));
  }
  // ->
}
