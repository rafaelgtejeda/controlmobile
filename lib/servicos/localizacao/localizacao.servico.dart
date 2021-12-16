import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizacaoServico {
  var locale;

  RequestUtil _request = new RequestUtil();
  int _usuarioId;

  Future<String> _localizacao(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var idioma = prefs.getString(SharedPreference.IDIOMA);
    int timer = 5;
    switch (idioma) {
      case ConfigIdioma.PORTUGUES_BRASIL:
        {
          return Future.delayed(Duration(milliseconds: timer), () {
            return DefaultAssetBundle.of(context).loadString('locale/br.json');
          });
        }
        break;

      case ConfigIdioma.ENGLISH_US:
        {
          return Future.delayed(Duration(milliseconds: timer), () {
            return DefaultAssetBundle.of(context).loadString('locale/en.json');
          });
        }
        break;

      case ConfigIdioma.ESPANOL_ESP:
        {
          return Future.delayed(Duration(milliseconds: timer), () {
            return DefaultAssetBundle.of(context).loadString('locale/es.json');
          });
        }
        break;

      case ConfigIdioma.DEUTSCH_DE:
        {
          return Future.delayed(Duration(milliseconds: timer), () {
            return DefaultAssetBundle.of(context).loadString('locale/de.json');
          });
        }
        break;

      default:
        {
          return Future.delayed(Duration(milliseconds: timer), () {
            return DefaultAssetBundle.of(context).loadString('locale/br.json');
          });
        }
        break;
    }
  }

  Future<dynamic> iniciaLocalizacao(BuildContext context) async {
    
    var resultadoLocalizacao = await _localizacao(context);
    locale = json.decode(resultadoLocalizacao.toString());
    return locale;
  }

  Future<dynamic> alterarIdiomaEmBanco(
      {String idioma, BuildContext context}) async {
    _usuarioId = await _request.obterIdUsuarioSharedPreferences();
    return _request.postReq(
        endpoint: 'Usuario/TrocarIdioma',
        data: {'usuarioId': _usuarioId, 'idioma': idioma},
        loading: true,
        context: context);
  }
}
