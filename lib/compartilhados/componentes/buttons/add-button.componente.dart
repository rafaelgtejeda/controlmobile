import 'package:flutter/material.dart';

class AddButtomComponente extends StatelessWidget {
  
  final Function funcao;
  final String tooltip;

  const AddButtomComponente({Key key, this.funcao, this.tooltip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Image.asset('images/app/add.png', width: 22),
      iconSize: 35,
      onPressed: funcao,
      tooltip: tooltip,
    );
  }
}