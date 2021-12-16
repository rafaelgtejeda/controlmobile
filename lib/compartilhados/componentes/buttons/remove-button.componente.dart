import 'package:flutter/material.dart';
import 'package:erp/utils/constantes/assets.constante.dart';

class RemoveButtomComponente extends StatelessWidget {
  
  final Function funcao;
  final String tooltip;

  const RemoveButtomComponente({Key key, this.funcao, this.tooltip}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset(AssetsIconApp.Delete, width: 28),
      iconSize: 35,
      onPressed: funcao,
      tooltip: tooltip,
    );
  }
}