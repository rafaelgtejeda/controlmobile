import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Text Texto(
  String texto, {
    bool bold = false, Color color = Colors.black, double fontSize = 16, bool underline = false, TextAlign textAlign
  }
) {
  return Text(
    texto,
    textAlign: textAlign,
    style: TextStyle(
      decoration: underline ? TextDecoration.underline : TextDecoration.none,
      fontSize: fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: color
    ),
  );
}

Divider Divisor() {
  return Divider(
    height: 0,
    thickness: 2,
  );
}

TextFormField CampoFormularioTextoSelecao ({
  TextEditingController controller, Function funcao, void Function(String) funcaoSave,
  String label, String validacaoMensagem, bool habilitado = true
}) {
  return TextFormField(
    readOnly: true,
    controller: controller,
    enabled: habilitado,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(),
    ),
    validator: (input) {
      if (input.isEmpty) {
        return validacaoMensagem;
      }
      else {
        return null;
      }
    },
    onTap: funcao,
    onSaved: funcaoSave,
  );
}

InputDecoration CampoTextoDecoration({String label, String counterText = '', String prefixo}) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(),
    counterText: counterText,
    prefixText: prefixo
  );
}

MaterialButton BotaoPadrao({Function, funcao, Color cor, Widget child}) {
  return MaterialButton(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(40),
    ),
    color: cor,
    onPressed: () {
      funcao();
    },
    child: child,
  );
}

Widget ChildStreamConexao({
  @required BuildContext context,
  @required AsyncSnapshot snapshot,
  List lista,
  bool infiniteCompleto,
  Widget Function(BuildContext, int, List) child
}) {
    if (snapshot.hasError) {
      return SemInformacao();
    }

    // else if (clientesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }

    else if (lista.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == lista.length && !infiniteCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return child(context, index, lista);
          // return _clienteItem(context, index, lista);
        },
        itemCount: lista.length + 1,
      );
    }
  }
