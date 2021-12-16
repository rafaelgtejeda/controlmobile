import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';

class CarregandoAlertaComponente {

  LocalizacaoServico _locate = new LocalizacaoServico();

  showCarregar(BuildContext context, {bool exibirTexto = true}) {
    _locate.iniciaLocalizacao(context);
    if(!Platform.isIOS || !Platform.isMacOS)
    {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return AlertDialog(
                content: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Carregando(size: 30),
                      Visibility(
                        visible: exibirTexto,
                        child: Text("${_locate.locale['Carregando']}"),
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      );
    }
    else {
      showCupertinoDialog(
        context: context,
        builder: (_) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return CupertinoAlertDialog(
                content: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Carregando(size: 30),
                      Visibility(
                        visible: exibirTexto,
                        child: Text("${_locate.locale['Carregando']}")
                      )
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      );
    }
  }

  showCarregarSemTexto(BuildContext context) {
    if(!Platform.isIOS || !Platform.isMacOS)
    {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return AlertDialog(
                content: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Carregando(size: 30),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      );
    }
    else {
      showCupertinoDialog(
        context: context,
        builder: (_) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return CupertinoAlertDialog(
                content: Container(
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Carregando(size: 30),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      );
    }
  }

  dismissCarregar(BuildContext context) {
    // Navigator.pop(context);
    Navigator.of(context).pop();
  }
}
