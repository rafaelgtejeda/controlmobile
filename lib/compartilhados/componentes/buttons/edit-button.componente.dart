import 'package:flutter/material.dart';
import 'package:erp/utils/constantes/assets.constante.dart';

class EditButtomComponente extends StatelessWidget {
  
  final Function funcao;
  final String tooltip;

  const EditButtomComponente({Key key, this.funcao, this.tooltip}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(AssetsIconApp.Edit, width: 22),
      iconSize: 35,
      onPressed: funcao,
      tooltip: tooltip,
    );
  }
}