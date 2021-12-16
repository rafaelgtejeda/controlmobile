import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Carregando extends StatefulWidget {
  final double size;
  Carregando({this.size = 25});
  @override
  _CarregandoState createState() => _CarregandoState();
}

class _CarregandoState extends State<Carregando> {
  @override
  Widget build(BuildContext context) {
    return SpinKitWave(
      color: Theme.of(context).indicatorColor,
      size: widget.size,
    );
  }
}

class CarregandoStateLess extends StatefulWidget {

  final double size;

  CarregandoStateLess({Key key, this.size = 25}) : super(key: key);

  @override
  CarregandoStateLessState createState() => CarregandoStateLessState();
}

class CarregandoStateLessState extends State<CarregandoStateLess> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData _media = MediaQuery.of(context);
    return AlertDialog(
      content: Builder(
        builder: (context) {
          return Container(
            height: _media.size.height * 0.15,
            width: _media.size.height * 0.3,
            child: SpinKitWave(
              color: Theme.of(context).indicatorColor,
              size: (_media.size.height * 0.05),
            ),
          );
        }
      ),
    );
  }

  dismissCarregar() {
    Navigator.of(context).pop();
  }
}
