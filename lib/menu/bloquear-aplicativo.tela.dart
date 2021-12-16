import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BloquearAplicativoTela extends StatefulWidget {
  final bool removerBloqueio;
  final bool desbloquearApp;
  BloquearAplicativoTela({Key key, this.removerBloqueio, this.desbloquearApp}) : super(key: key);
  @override
  _BloquearAplicativoTelaState createState() => _BloquearAplicativoTelaState();
}

class _BloquearAplicativoTelaState extends State<BloquearAplicativoTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();

  String logo = "";

  String _senha = '';
  String _senhaConfirmacao = '';
  String _senhaParaDesbloqueio = '';
  bool _digitouSenhaUmaVez = false;
  bool _senhaConfirmada = false;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    getLogo();
    if (widget.desbloquearApp != null || widget.removerBloqueio != null){
      _recuperaSenhaParaDesbloqueio();
    }
  }

  _recuperaSenhaParaDesbloqueio() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _senhaParaDesbloqueio = _prefs.getString(SharedPreference.SENHA_BLOQUEIO);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: LocalizacaoWidget(
        child: StreamBuilder(
          builder: (context, snapshot) {
            return Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey[800],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Spacer(),
                  Spacer(),
                  _logo(),
                  Spacer(),
                  Center(
                    child: Texto(
                      (widget.desbloquearApp == true || widget.removerBloqueio == true)
                      ? widget.removerBloqueio == true
                        ? _locate.locale[TraducaoStringsConstante.DigiteCodigoDesbloqueio]
                        : _locate.locale[TraducaoStringsConstante.CodigoProsseguir]
                      : !_digitouSenhaUmaVez
                        ? _locate.locale[TraducaoStringsConstante.DigiteCodigo2Vezes]
                        : _locate.locale[TraducaoStringsConstante.DigiteCodigo1Vez],
                      color: Colors.white
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _digitos(1),
                      _digitos(2),
                      _digitos(3),
                      _digitos(4),
                    ],
                  ),
                  Spacer(),
                  _primeiraLinha(),
                  Spacer(),
                  _segundaLinha(),
                  Spacer(),
                  _terceiraLinha(),
                  Spacer(),
                  _quartaLinha(),
                  Spacer(),
                  _quintaLinha(),
                  Spacer(),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  getLogo() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logo = prefs.getString('logo');
  }

  Widget _logo() {
    return Container(
      padding: Constant.spacingAllSmall,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Constant.screenWidthTenth),
        child: Image.asset(
          logo,
          width: 300 ?? Constant.defaultImageHeight,
        )
      ),
    );
  }

  Widget _digitos(int index) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            height: 20,
            width: 20,
            decoration: ShapeDecoration(shape: CircleBorder(side: BorderSide(color: Colors.white, width: 2),)),
          ),
          !_digitouSenhaUmaVez
          ? index <= _senha.length
            ? Container(
              // height: 100,
              // width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(200)),
                border: Border.all(width: 5,color: Colors.green,style: BorderStyle.solid)
              ),
            )
            : Container()
          : index <= _senhaConfirmacao.length
            ? Container(
              // height: 100,
              // width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(200)),
                border: Border.all(width: 5,color: Colors.green,style: BorderStyle.solid)
              ),
            )
            : Container(),
        ],
      ),
    );
  }

  Widget _primeiraLinha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _botao1(),
        _botao2(),
        _botao3(),
      ],
    );
  }

  Widget _segundaLinha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _botao4(),
        _botao5(),
        _botao6(),
      ],
    );
  }

  Widget _terceiraLinha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _botao7(),
        _botao8(),
        _botao9(),
      ],
    );
  }

  Widget _quartaLinha() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _botao0(),
      ],
    );
  }

  Widget _quintaLinha() {
    if(widget.desbloquearApp == true) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          _botaoApagar(),
        ],
      );
    }
    else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _botaoVoltar(),
          _botaoApagar(),
        ],
      );
    }
  }

  // Botões

  _funcaoBotao(String valor) {
    if(!_digitouSenhaUmaVez) {
      setState(() {
        _senha += valor;
      });
      _verificacaoSenha();
    }
    else {
      setState(() {
        _senhaConfirmacao += valor;
      });
      _verificacaoSenha();
    }
  }

  _verificacaoSenha() {
    if(widget.desbloquearApp == null && widget.removerBloqueio == null) {
      if(_senha.length == 4 && !_digitouSenhaUmaVez) {
        setState(() {
          _digitouSenhaUmaVez = true;
        });
      }
      if(_senhaConfirmacao.length == 4) {
        if(_senhaConfirmacao.contains(_senha)) {
          setState(() {
            _senhaConfirmada = true;
          });
        }
        else {
          setState(() {
            _senhaConfirmada = false;
            _senha = '';
            _senhaConfirmacao = '';
            _digitouSenhaUmaVez = false;
          });
          AlertaComponente().showAlertaErro(context: context, mensagem: _locate.locale[TraducaoStringsConstante.SenhaNaoConfere]);
        }
      }
    }

    if(widget.removerBloqueio != null || widget.desbloquearApp != null) {
      if(_senha.length == 4 && _senha.contains(_senhaParaDesbloqueio)) {
        _senhaConfirmada = true;
        // _senha = '';
      }
    }

    if(_senhaConfirmada == true && widget.desbloquearApp == true) {
      Navigator.pop(context, true);
    }

    if(_senhaConfirmada == true && widget.desbloquearApp == null && widget.removerBloqueio == null) {
      _armazenaSenha();
      Navigator.pop(context, true);
    }

    if(_senhaConfirmada == true && (widget.desbloquearApp == null && widget.removerBloqueio == true)) {
      _armazenaSenha();
      Navigator.pop(context, true);
    }

    if(_senhaConfirmada == false) {
      if((widget.desbloquearApp == null && widget.removerBloqueio == null) && _digitouSenhaUmaVez && _senhaConfirmacao.length == 4) {
        setState(() {
          _senha = '';
        });
        AlertaComponente().showAlertaErro(context: context, mensagem: _locate.locale[TraducaoStringsConstante.SenhaNaoConfere]);
      }
      if((widget.desbloquearApp != null || widget.removerBloqueio != null) && _senha.length == 4) {
        setState(() {
          _senha = '';
        });
        AlertaComponente().showAlertaErro(context: context, mensagem: _locate.locale[TraducaoStringsConstante.SenhaNaoConfere]);
      }
    }
  }

  _armazenaSenha() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(SharedPreference.SENHA_BLOQUEIO, _senhaConfirmacao);
  }
  
  Widget _botao1() {
    return BotaoSenha(
      texto: '1',
      funcao: () {
        _funcaoBotao('1');
      }
    );
  }

  Widget _botao2() {
    return BotaoSenha(
      texto: '2',
      funcao: () {
        _funcaoBotao('2');
      }
    );
  }

  Widget _botao3() {
    return BotaoSenha(
      texto: '3',
      funcao: () {
        _funcaoBotao('3');
      }
    );
  }
  
  Widget _botao4() {
    return BotaoSenha(
      texto: '4',
      funcao: () {
        _funcaoBotao('4');
      }
    );
  }

  Widget _botao5() {
    return BotaoSenha(
      texto: '5',
      funcao: () {
        _funcaoBotao('5');
      }
    );
  }

  Widget _botao6() {
    return BotaoSenha(
      texto: '6',
      funcao: () {
        _funcaoBotao('6');
      }
    );
  }
  
  Widget _botao7() {
    return BotaoSenha(
      texto: '7',
      funcao: () {
        _funcaoBotao('7');
      }
    );
  }

  Widget _botao8() {
    return BotaoSenha(
      texto: '8',
      funcao: () {
        _funcaoBotao('8');
      }
    );
  }

  Widget _botao9() {
    return BotaoSenha(
      texto: '9',
      funcao: () {
        _funcaoBotao('9');
      }
    );
  }
  
  Widget _botao0() {
    return BotaoSenha(
      texto: '0',
      funcao: () {
        _funcaoBotao('0');
      }
    );
  }

  Widget _botaoVoltar() {
    return FlatButton(
      child: Texto(
        _locate.locale[TraducaoStringsConstante.Cancelar],
        bold: true,
        fontSize: 20,
        color: Colors.white
      ),
      onPressed: () {
        Navigator.pop(context, false);
      },
    );
  }

  Widget _botaoApagar() {
    return FlatButton.icon(
      label: Container(),
      icon: Icon(Icons.backspace, color: Colors.white,),
      onPressed: () {
        if(_senha.length < 4 && _senha.length > 0 && !_digitouSenhaUmaVez) {
          setState(() {
            _senha = _senha.substring(0, _senha.length - 1);
          });
          print(_senha);
        }
        else if(_senhaConfirmacao.length < 4 && _senhaConfirmacao.length > 0) {
          setState(() {
            _senhaConfirmacao = _senhaConfirmacao.substring(0, _senhaConfirmacao.length - 1);
          });
          print(_senhaConfirmacao);
        }
      },
    );
  }

}

Padding BotaoSenha({Function funcao, String texto = ''}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: OutlineButton(
      onPressed: funcao == null
        ? () {}
        : funcao,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Texto(texto, color: Colors.white, fontSize: 32),
      ),
      shape: CircleBorder(),
      borderSide: BorderSide(
        color: Colors.white,
        width: 3
      ),
    ),
  );
}
