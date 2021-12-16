import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:erp/utils/screen_util.dart';

/// Botão Componente
///
/// Parametros:
///
/// Texto: Texto de chamada do botão.
/// Função: Recebe uma função. Ex Navegação para outra tela.
/// imagemCaminho: Caminho do icone Cadastrar em AssetsIconApp.
/// backgroundCaminho: Cor do background. Ex: Colors.blue.
/// textColor: Cor do texto. Ex: Colors.white.
/// ladoIcone: Esquerdo / Direito
/// SomenteTexto: True /False
/// somenteIcone: True / False
/// width: Largura do Botão
/// height: Altura do Botão
///
class ButtonComponente extends StatelessWidget {
  final String texto;
  final Function funcao;
  final String imagemCaminho;
  final Color backgroundColor;
  final Color textColor;
  final String ladoIcone;
  final bool somenteTexto;
  final bool somenteIcone;
  final int width;
  final int height;

  ButtonComponente(
      {Key key,
      this.texto,
      @required this.funcao,
      this.imagemCaminho,
      @required this.backgroundColor,
      @required this.textColor,
      this.ladoIcone,
      this.somenteTexto,
      this.somenteIcone,
      this.width,
      this.height})
      : super(key: key);

  bool _isLoading = false;
  bool _visibleEsquerdo;
  bool _visibleDireito;
  bool _visibleTexto;

  @override
  Widget build(BuildContext context) {
    if (somenteTexto == true && somenteIcone == true) {
      _visibleEsquerdo = false;
      _visibleTexto = true;
      _visibleDireito = false;
      print('Nao pode.');
    } else {
      if (ladoIcone == 'Esquerdo') {
        _visibleEsquerdo = true;
        _visibleTexto = true;
        _visibleDireito = false;
      } else {
        _visibleEsquerdo = false;
        _visibleTexto = true;
        _visibleDireito = true;
      }

      if (somenteIcone == true && somenteTexto == false) {
        _visibleEsquerdo = true;
        _visibleTexto = false;
        _visibleDireito = false;
      }

      if (somenteTexto == true && somenteIcone == false) {
        _visibleEsquerdo = false;
        _visibleTexto = true;
        _visibleDireito = false;
      }
    }

    return Container(
      child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Material(
            elevation: 5,
            color: backgroundColor,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: funcao,
              child: Center(
                child: Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(40)),
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 18),
                    child: Align(
                        alignment: Alignment.center,
                        child: _isLoading
                            ? SpinKitWave(color: textColor, size: FontSize.s13)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Visibility(
                                    visible: _visibleEsquerdo,
                                    child: Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 13),
                                          child: Image.asset(imagemCaminho,
                                              width: 20),
                                        )),
                                  ),
                                  Visibility(
                                    visible: _visibleTexto,
                                    child: Flexible(
                                        flex: 2,
                                        child: Text(
                                          texto.toUpperCase(),
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: FontSize.s14,
                                          ),
                                        )),
                                  ),
                                  Visibility(
                                    visible: _visibleDireito,
                                    child: Flexible(
                                        flex: 2,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 13),
                                          child: Image.asset(imagemCaminho,
                                              width: 20),
                                        )),
                                  ),
                                ],
                              ))),
              ),
            ),
          )),
    );
  }
}
