import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateUtil {
  Future<String> _carregaIdioma()async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(SharedPreference.IDIOMA);
  }

  Future<String> retornaMes (int mes) async {
    String idioma = await _carregaIdioma();
    String resultado = '';
    switch (idioma) {
      case ConfigIdioma.PORTUGUES_BRASIL:
        switch (mes) {
          case 1:
            resultado = 'Janeiro';
            break;
          case 2:
            resultado = 'Fevereiro';
            break;
          case 3:
            resultado = 'Março';
            break;
          case 4:
            resultado = 'Abril';
            break;
          case 5:
            resultado = 'Maio';
            break;
          case 6:
            resultado = 'Junho';
            break;
          case 7:
            resultado = 'Julho';
            break;
          case 8:
            resultado = 'Agosto';
            break;
          case 9:
            resultado = 'Setembro';
            break;
          case 10:
            resultado = 'Outubro';
            break;
          case 11:
            resultado = 'Novembro';
            break;
          case 12:
            resultado = 'Dezembro';
            break;
          default:
            resultado = '';
        }
        break;
      case ConfigIdioma.ENGLISH_US:
        switch (mes) {
          case 1:
            resultado = 'January';
            break;
          case 2:
            resultado = 'February';
            break;
          case 3:
            resultado = 'March';
            break;
          case 4:
            resultado = 'April';
            break;
          case 5:
            resultado = 'May';
            break;
          case 6:
            resultado = 'June';
            break;
          case 7:
            resultado = 'July';
            break;
          case 8:
            resultado = 'August';
            break;
          case 9:
            resultado = 'September';
            break;
          case 10:
            resultado = 'October';
            break;
          case 11:
            resultado = 'November';
            break;
          case 12:
            resultado = 'December';
            break;
          default:
            resultado = '';
        }
        break;
      case ConfigIdioma.ESPANOL_ESP:
        switch (mes) {
          case 1:
            resultado = 'Enero';
            break;
          case 2:
            resultado = 'Febrero';
            break;
          case 3:
            resultado = 'Marzo';
            break;
          case 4:
            resultado = 'Abril';
            break;
          case 5:
            resultado = 'Mayo';
            break;
          case 6:
            resultado = 'Junio';
            break;
          case 7:
            resultado = 'Julio';
            break;
          case 8:
            resultado = 'Agosto';
            break;
          case 9:
            resultado = 'Septiembre';
            break;
          case 10:
            resultado = 'Octubre';
            break;
          case 11:
            resultado = 'Noviembre';
            break;
          case 12:
            resultado = 'Diciembre';
            break;
          default:
            resultado = '';
        }
        break;
      case ConfigIdioma.DEUTSCH_DE:
        switch (mes) {
          case 1:
            resultado = 'Januar';
            break;
          case 2:
            resultado = 'Februar';
            break;
          case 3:
            resultado = 'März';
            break;
          case 4:
            resultado = 'April';
            break;
          case 5:
            resultado = 'Mai';
            break;
          case 6:
            resultado = 'Juni';
            break;
          case 7:
            resultado = 'Juli';
            break;
          case 8:
            resultado = 'August';
            break;
          case 9:
            resultado = 'September';
            break;
          case 10:
            resultado = 'Oktober';
            break;
          case 11:
            resultado = 'November';
            break;
          case 12:
            resultado = 'Dezember';
            break;
          default:
            resultado = '';
        }
        break;
      default:
    }
    return resultado;
  }
}
