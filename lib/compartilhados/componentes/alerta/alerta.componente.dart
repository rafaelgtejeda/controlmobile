import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';

class AlertaComponente {

  LocalizacaoServico _locate = new LocalizacaoServico();

  Future showAlerta({
    @required BuildContext context,
    String mensagem = '',
    String titulo = '',
    List<Widget> acoes,
    bool barrierDismissible = false,
    Widget conteudo,
    double height,
  }) {
    if(!Platform.isIOS || !Platform.isMacOS)
    {
      return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return AlertDialog(
                title: Text(titulo),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    conteudo ?? Container(
                      child: Text(mensagem),
                    ),
                  ],
                ),
                actions: acoes,
              );
            }
          ),
        ),
      );
    }
    else {
      return showCupertinoDialog(
        context: context,
        builder: (_) => LocalizacaoWidget(
          child: StreamBuilder(
            builder: (context, snapshot) {
              return CupertinoAlertDialog(
                title: Text(titulo),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    conteudo ?? Container(
                      // height: height,
                      child: Text(mensagem)
                    ),
                  ],
                ),
                actions: acoes
              );
            }
          ),
        ),
      );
    }
  }

  Future<bool> showAlertaConfirmacao({BuildContext context, String mensagem}) async {
    await _locate.iniciaLocalizacao(context);
    return await showAlerta(
      context: context,
      mensagem: mensagem,
      titulo: _locate.locale[TraducaoStringsConstante.Aviso],
      barrierDismissible: true,
      acoes: [
        FlatButton(
          child: Text(_locate.locale[TraducaoStringsConstante.Ok]),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text(_locate.locale[TraducaoStringsConstante.Cancelar]),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ]
    );
  }

  Future<bool> showAlertaErro({BuildContext context, String mensagem, bool localedMessage = false}) async {
    await _locate.iniciaLocalizacao(context);
    return await showAlerta(
      context: context,
      // titulo: _locate.locale[TraducaoStringsConstante.Erro],
      titulo: _locate.locale[TraducaoStringsConstante.Aviso],
      mensagem: localedMessage ? _locate.locale['$mensagem'] : mensagem,
      barrierDismissible: true,
      acoes: [
        FlatButton(
          child: Text(_locate.locale['Ok']),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]
    );
  }

  Future<bool> showAlertaErros({BuildContext context, List<String> erros}) async {
    await _locate.iniciaLocalizacao(context);
    return await showAlerta(
      context: context,
      titulo: _locate.locale[TraducaoStringsConstante.Erro],
      conteudo: Container(
        height: 200,
        width: double.maxFinite,
        child: Scrollbar(
          child: ListView.builder(
            itemCount: erros.length,
            itemBuilder: (context, index) {
              return Text(erros[index]);
            },
          ),
        ),
      ),
      // mensagem: mensagem,
      barrierDismissible: true,
      acoes: [
        FlatButton(
          child: Text(_locate.locale[TraducaoStringsConstante.Ok]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ]
    );
  }
}
