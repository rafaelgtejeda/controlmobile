import 'package:flutter/material.dart';

class ConteudoFiltroBodyComponente extends StatelessWidget {

  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;

  ConteudoFiltroBodyComponente({this.crossAxisAlignment, this.children});

  @override
  Widget build(BuildContext context) {
    children.insert(0, SizedBox(height: 48,));
    return new Column(
      crossAxisAlignment: crossAxisAlignment,
      children: children
    );
  }
  
}