import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constantes/shared_preferences.constante.dart';

class DatePickerUtil {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Future<DateTime> datePicker({BuildContext context, DateTime dataInicial}) async {
    await _locate.iniciaLocalizacao(context);
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String idioma = _prefs.getString(SharedPreference.IDIOMA);
    return await showDatePicker(
      context: context,
      initialDate: dataInicial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: _locate.locale['SelecionarData'],
      locale: Locale(idioma)
    );
  }
}
