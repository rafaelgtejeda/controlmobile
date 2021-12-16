import 'package:erp/servicos/autenticacao/autenticacao.servicos.dart';

abstract class AutenticacaoContract {
  void onAutenticacaoSucesso(dynamic resposta);
  void onAutenticacaoErro(String errorTxt);
}

class AutenticacaoPresenter {
  AutenticacaoContract _view;
  AutenticacaoService api = new AutenticacaoService();
  AutenticacaoPresenter(this._view);

  doAutenticacao(String ddi, String telefone, int tipoDeEnvio, String idioma) {
    api.autenticacao(ddi, telefone, tipoDeEnvio, idioma).then((resposta) {
      _view.onAutenticacaoSucesso(resposta);
    }).catchError((Object error) => _view.onAutenticacaoErro(error.toString()));
  }
}
