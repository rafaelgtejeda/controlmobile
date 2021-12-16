import 'package:flutter/material.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  double getValue({double value, double max, double min}) {
    if (value < max && value > min) {
      return value;
    }
    if (value < min) {
      return min;
    } else {
      return max;
    }
  }

  String capitalize({@required String input}) {
    if (input == null) {
      throw new ArgumentError.notNull();
    }

    if (input.length == 0) {
      return input;
    }

    return input[0].toUpperCase() + input.substring(1);
  }

  String cpfCnpjFormatter({@required String input}) {
    input = input.replaceAll(".", "");
    input = input.replaceAll("-", "");
    input = input.replaceAll("/", "");
    if (input == null) {
      throw new ArgumentError.notNull();
    }

    if (input.length == 0) {
      return input;
    }

    if (input.length == 11) {
      String parte1 = input.substring(0, 3);
      String parte2 = input.substring(3, 6);
      String parte3 = input.substring(6, 9);
      String parte4 = input.substring(9, 11);

      return parte1 + "." + parte2 + "." + parte3 + "-" + parte4;
    }

    if (input.length == 14) {
      String parte1 = input.substring(0, 2);
      String parte2 = input.substring(2, 5);
      String parte3 = input.substring(5, 8);
      String parte4 = input.substring(8, 12);
      String parte5 = input.substring(12, 14);

      return parte1 + "." + parte2 + "." + parte3 + "/" + parte4 + "-" + parte5;
    } else {
      return "$input";
    }
  }

  String cepFormatter({@required String cep}) {
    cep.replaceAll("-", "");
    cep.replaceAll(".", "");

    if (cep == null) {
      throw new ArgumentError.notNull();
    }

    if (cep.length == 0) {
      return cep;
    }

    String parte1 = cep.substring(0, 5);
    String parte2 = cep.substring(5, 8);

    return "$parte1-$parte2";
  }

  Color positivoNegativoDinheiroCor(double valor) {
    if (valor != null) {
      if (valor.isNegative || valor == 0) {
        return Colors.red;
        // return Colors.red[900];
      } else {
        return Colors.green;
        // return Colors.green[700];
      }
    } else {
      return Colors.red;
    }
  }

  String dinheiroFormatter(double valor) {
    // Preparar para receber a quantidade de dígitos da API
    int _digitos = 2;
    bool isNegativo = false;

    if (valor.isNegative) {
      isNegativo = true;
      valor = valor * (-1);
    }

    String _formataInteiro({String inteiro, String separador}) {
      String inverso = '';
      String inteiroConvertido = '';
      int j = 0;
      for (int i = inteiro.length; i > 0; i--) {
        j++;
        inverso = inverso + inteiro.substring(i - 1, i);
        if (j % 3 == 0 && i != 1) {
          inverso = inverso + separador;
        }
      }

      inteiro = '';
      for (int i = inverso.length; i > 0; i--) {
        inteiroConvertido = inteiroConvertido + inverso.substring(i - 1, i);
      }
      return inteiroConvertido;
    }

    String _formataValor(
        {String separadorMilhar = ',', String separadorDecimal = '.'}) {
      String valorConvertido = '';
      String decimal = '';
      String inteiro = '';
      valorConvertido = valor.toStringAsFixed(_digitos);
      List<String> valoresSeparados = valorConvertido.split('.');
      inteiro = valoresSeparados[0];
      decimal = valoresSeparados[1];
      inteiro = _formataInteiro(inteiro: inteiro, separador: separadorMilhar);
      if (isNegativo) {
        return '-' + inteiro + separadorDecimal + decimal;
      } else {
        return inteiro + separadorDecimal + decimal;
      }
    }

    Future<String> _getIdioma() async {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      return _prefs.getString(SharedPreference.IDIOMA);
    }

    // Fazer Verificação de nulo ou diferente tipo
    String idioma = '';
    _getIdioma().then((data) {
      idioma = data;
    });
    switch (idioma) {
      case ConfigIdioma.PORTUGUES_BRASIL:
        return 'R\$ ' +
            _formataValor(separadorDecimal: ',', separadorMilhar: '.');
        break;
      case ConfigIdioma.ENGLISH_US:
        return 'U\$ ' + _formataValor();
        break;
      case ConfigIdioma.ESPANOL_ESP:
        return '€ ' +
            _formataValor(separadorDecimal: ',', separadorMilhar: ' ');
        break;
      case ConfigIdioma.DEUTSCH_DE:
        return '€ ' +
            _formataValor(separadorDecimal: ',', separadorMilhar: '.');
        break;
      default:
        return 'R\$ ' +
            _formataValor(separadorDecimal: ',', separadorMilhar: '.');
        break;
    }
  }

  Map<String, String> separadorDDDTelefone({@required String input}) {
    String ddd = "";
    String telefone = "";

    int dddCounter = 0;
    bool dddConcluido = false;

    if (input[0] != "(") {
      dddConcluido = true;
    }

    for (var i = 0; i < input.length; i++) {
      if (input[i] == "(") {
        dddCounter++;
      }
      if (input[i] != "(" || input[i] != ")") {
        if (!dddConcluido) {
          dddCounter++;
          ddd += input[i];
        } else {
          telefone += input[i];
        }
      }
      if (input[i] == ")") {
        dddConcluido = true;
      }
    }

    ddd = ddd.replaceAll("(", "");
    ddd = ddd.replaceAll(")", "");

    telefone = telefone.replaceAll("(", "");
    telefone = telefone.replaceAll(")", "");
    telefone = telefone.replaceAll("-", "");

    return {'ddd': ddd, 'telefone': telefone};
  }

  Color corStatusOrdemServico(
      {DateTime dataDia, String horaFinal, int statusOS}) {
    Color cor;
    DateTime dataAtual = DateTime.now();
    int horaFim = int.parse(horaFinal.split(':')[0]);
    int minutoFim = int.parse(horaFinal.split(':')[1]);
    dataDia = DateTime(dataDia.year, dataDia.month, dataDia.day, horaFim, minutoFim, 59, 999, 999);
    if (dataDia.isBefore(dataAtual)) {
      cor = Colors.redAccent[700];
    } else {
      switch (statusOS) {
        case StatusOrdemDeServico.Agendado:
          cor = Colors.greenAccent[700];
          break;
        case StatusOrdemDeServico.ACaminho:
          cor = Colors.black;
          break;
        case StatusOrdemDeServico.Atendendo:
          cor = Colors.orangeAccent[700];
          break;
        case StatusOrdemDeServico.FinalizacaoTecnico:
          cor = Colors.lightBlueAccent;
          break;
        case StatusOrdemDeServico.CancelamentoFinalizacaoTecnico:
          cor = Colors.redAccent[700];
          break;
        default:
          cor = Colors.redAccent[700];
          break;
      }
    }
    return cor;
  }
}
