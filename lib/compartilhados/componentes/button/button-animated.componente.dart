import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

/// Botão Componente
/// 
/// Parametros:
/// 
/// Texto: Texto de chamada do botão.
/// 
/// Função: Recebe uma função. Ex Navegação para outra tela.
/// 
/// imagemCaminho: Caminho do icone Cadastrar em AssetsIconApp.
/// 
/// backgroundCaminho: Cor do background. Ex: Colors.blue.
/// 
/// textColor: Cor do texto. Ex: Colors.white.
/// 
/// ladoIcone: Esquerdo / Direito
/// 
/// SomenteTexto: True /False
/// 
/// somenteIcone: True / False
/// 
/// width: Largura do Botão
/// 
/// height: Altura do Botão
/// 
class ButtonAnimatedComponente extends StatelessWidget {

  final String texto;
  final dynamic funcao;
  final String imagemCaminho;
  final Color backgroundColor;
  final Color textColor;
  final String ladoIcone;
  final bool somenteTexto;
  final bool somenteIcone;
  final double width;
  final double height;
  
  ButtonAnimatedComponente({Key key,
                    this.texto, 
          @required this.funcao, 
                    this.imagemCaminho, 
          @required this.backgroundColor,
          @required this.textColor,
                    this.ladoIcone,
                    this.somenteTexto,
                    this.somenteIcone,
                    this.width, 
                    this.height}) : super(key: key);
  
        bool _visibleEsquerdo;
        bool _visibleDireito;
        bool _visibleTexto;
  

  @override
  Widget build(BuildContext context) {

    if(somenteTexto == true && somenteIcone == true ) {

      print('Nao pode.');
      _visibleEsquerdo = false;
      _visibleTexto = true;
      _visibleDireito = false;
      print('Nao pode.');
        
    } else {

      if(ladoIcone == 'Esquerdo'){
          _visibleEsquerdo = true;
          _visibleTexto = true;
          _visibleDireito = false;
        } else {
          _visibleEsquerdo = false;
          _visibleTexto = true;
          _visibleDireito = true;
        }

        if(somenteIcone == true && somenteTexto == false) {
          _visibleEsquerdo = true;
          _visibleTexto = false;
          _visibleDireito = false;
        }

        if(somenteTexto == true && somenteIcone == false ) {
          _visibleEsquerdo = false;
          _visibleTexto = true;
          _visibleDireito = false;
        }
      
    }
  
    return ArgonTimerButton(
            initialTimer: 10, // Optional
            height: height,
            width: MediaQuery.of(context).size.width * width,
            minWidth: MediaQuery.of(context).size.width * 0.30,
            color: backgroundColor,
            elevation: 0,
            borderRadius: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Visibility(
                    visible: _visibleEsquerdo,
                    child: Flexible(
                    flex: 2, 
                    child: Padding(
                      padding: const EdgeInsets.only(right: 13),
                      child: Image.asset(imagemCaminho, width: 20 ),
                    )
                  ),
                ),
                Visibility(
                    visible: _visibleTexto,
                    child: Flexible(flex: 2, child: Text(
                    texto.toUpperCase(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: FontSize.s14,                   
                    ),
                    )
                  ),
                ),
                Visibility(
                    visible: _visibleDireito,
                    child: Flexible(
                    flex: 2, 
                    child: Padding(
                      padding: const EdgeInsets.only(left: 13),
                      child: Image.asset(imagemCaminho, width: 20 ),
                    )
                  ),
                ),
              ],
            ),
            loader: (timeLeft) {
              return Container(
                padding: EdgeInsets.all(10),
                child: SpinKitWave(
                  color: textColor,
                   size: 16 ,
                ),
              );
            },
            onTap: (startTimer, btnState) {
              if (btnState == ButtonState.Idle) {
                startTimer(1);
                funcao;
              }
              
            },
          );
  }

  nav(funcao) {
    funcao;
  }

}
