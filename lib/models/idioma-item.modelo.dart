import 'package:flutter/widgets.dart';

class IdiomaItemModelo {
  bool isSelected = false;
  Color corSplash;
  String imagemCaminho;
  String tooltip;
  String idioma;
  int indiceGeral;

  IdiomaItemModelo({this.isSelected, this.corSplash, this.imagemCaminho, this.tooltip, this.idioma, this.indiceGeral});
}
