import 'package:flutter/material.dart';

class Accordion extends StatefulWidget {

  final List<Widget> titulo;
  final List<Widget> itens;
  final bool aberto;

  Accordion({Key key,this.titulo, this.itens = const [], this.aberto = false}) : super(key: key);

  @override
  _AccordionState createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      initiallyExpanded: widget.aberto,
      title: Column(  
        children: widget.titulo,
      ),
      children: widget.itens,
    );
  }
}
