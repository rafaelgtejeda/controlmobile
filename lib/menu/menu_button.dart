import 'package:flutter/material.dart';

class MenuBotao extends StatelessWidget {

  final IconData icone;
  final String texto;
  final Function funcao;

  MenuBotao(this.icone, this.texto, this.funcao);

  @override
  Widget build(BuildContext context) {
    return icone != null
    
    ? OutlineButton.icon(
      padding: EdgeInsets.symmetric(vertical: 15),
      icon: Icon(icone,),
      label: Text(
        texto.toUpperCase(),
        style: TextStyle(
          
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      onPressed: funcao,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      borderSide: BorderSide(
        color: Colors.grey[500],
        width: 3
      ),
      highlightedBorderColor: Colors.grey[400],
    )

    : OutlineButton(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Text(
        texto.toUpperCase(),
        style: TextStyle(
          
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      onPressed: funcao,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      borderSide: BorderSide(
        color: Colors.grey[500],
        width: 3
      ),
      highlightedBorderColor: Colors.grey[400],
    );
  }
}