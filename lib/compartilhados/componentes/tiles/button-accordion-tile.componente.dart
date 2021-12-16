import 'package:flutter/material.dart';

class ButtonAccordionTiles extends StatelessWidget {
  
  final String titulo;
  final Function funcao;

  const ButtonAccordionTiles({Key key, this.titulo, this.funcao}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: funcao,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: Icon(
                Icons.chevron_right,
              ),
            )
          ],
        ),
      ),
    );
  }
}