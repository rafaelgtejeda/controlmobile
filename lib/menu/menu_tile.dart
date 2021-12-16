import 'package:flutter/material.dart';

class MenuTile extends StatelessWidget {

  final IconData icone;
  final String texto;
  final Function funcao;

  MenuTile(this.icone, this.texto, {@required this.funcao});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          funcao();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25),
          height: 50,
          child: Row(
            children: <Widget>[
              Icon(
                icone,
                
              ),
              SizedBox(width: 32,),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 16,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
