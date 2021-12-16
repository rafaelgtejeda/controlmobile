import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/helperFontSize.dart';
import 'package:provider/provider.dart';

/// Tile usado na `Tela Principal - Dashboard` usados para a nevagação para outras telas
/// Recomanda-se o uso do widget `Wrap` para encaixar os tiles responsiamente
/// 
class PrincipalTile extends StatelessWidget {
  /// String do caminho da imagem em `assets`
  final String img;

  /// String do texto a ser exibido nesse tile
  final String texto;

  /// Função a ser executada pelo tile
  final Function funcao;

  final bool desabilitarEmOffline;

  // /// Contexto pasado para adquirir propriedades da tela
  // final BuildContext context;

  PrincipalTile(
      {@required this.img, @required this.texto, @required this.funcao, this.desabilitarEmOffline = false});
  MediaQueryData _media = MediaQueryData();

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    _media = MediaQuery.of(context);

    return Container(
      width: _media.size.width * 0.4 > 150 ? 150 : 125,
      // width: _media.size.width * 0.4,
      // width: 110,
      // width: helper.adjustSize(
      //     value: helper.size.width * 0.00, min: 151, max: 100),
      height: _media.size.width * 0.4 > 150 ? 150 : 125,
      // height: _media.size.width * 0.4,
      // height: 110,
      // height: helper.adjustSize(
      //     value: helper.size.height * 0.00, min: 151, max: 110),
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            child: desabilitarEmOffline
              ? CustomOfflineWidget(
                borderRadius: 10,
                disabledIconOnly: true,
                child: _tile(),
              )
              : _tile(),
          ),
          onTap: desabilitarEmOffline && !_isOnline ? () {} : funcao,
        )
      ),
    );
  }
  Widget _tile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              img,
              height: 36,
              width: 36,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * _media.textScaleFactor,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      ),
    );
  }
  
}
