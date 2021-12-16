import 'package:flutter/widgets.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:flutter/material.dart';

class SemInformacao extends StatefulWidget {
  @override
  _SemInformacaoState createState() => _SemInformacaoState();
}

class _SemInformacaoState extends State<SemInformacao> {
  LocalizacaoServico _locale = new LocalizacaoServico();

  @override
  void initState() { 
    super.initState();
    _locale.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(69.0),
                    child: Image.asset(AssetsImagens.VAZIO),
                  ),
                  Center(
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(child: Text(_locale.locale['NenhumaInformacaoEncontrada'], 
                        style: TextStyle(
                              fontSize: FontSize.s18,                                         
                            )
                          )
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
