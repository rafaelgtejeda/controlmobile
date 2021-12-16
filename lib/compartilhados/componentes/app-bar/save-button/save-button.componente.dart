import 'package:flutter/material.dart';

class SaveButtonComponente extends StatelessWidget {
  final Function funcao;
  final String tooltip;

  SaveButtonComponente({@required this.funcao, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.save,),
      iconSize: 35,
      onPressed: funcao,
      tooltip: tooltip,
    );
  }
}
