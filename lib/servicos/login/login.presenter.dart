import 'package:erp/servicos/login/login.servicos.dart';

abstract class LoginContract {
  // ->
  void onLoginSucesso(dynamic resposta);
  void onLoginErro(String errorTxt);
  // ->
}

class LoginPresenter {
  // ->
  LoginContract _view;
  LoginService api = new LoginService();
  LoginPresenter(this._view);
  // ->
  doLogin(codigo) {
    api
        .login(codigo)
        .then((resposta) {
      _view.onLoginSucesso(resposta);
    }).catchError((Object error) => _view.onLoginErro(error.toString()));
  }
  // ->
}
