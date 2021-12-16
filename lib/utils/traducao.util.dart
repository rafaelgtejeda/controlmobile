import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';

class Traducao extends StatefulWidget {
  @override
  _TraducaoState createState() => _TraducaoState();
}

class _TraducaoState extends State<Traducao> {
  LocalizacaoServico _locale = new LocalizacaoServico();
  
  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: true,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Container(
            // chama o scafold
            child: Scaffold(
              appBar: AppBar(
                title: Text(_locale.locale['OrdemDeServico'].toUpperCase()),
              ),
            ),
          );
        },
      ),
    );
  }
}
