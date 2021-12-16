import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'dart:convert';

import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:provider/provider.dart';

class ListaPaisesTela extends StatefulWidget {
  @override
  _ListaPaisesTelaState createState() => _ListaPaisesTelaState();
}

class _ListaPaisesTelaState extends State<ListaPaisesTela> {
  Stream<dynamic> _streamPaises;
  LocalizacaoServico _locate = new LocalizacaoServico();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  List listaPaisesOriginal = [];
  List listaPaisesBusca = [];

  @override
  void initState() {
    super.initState();
    _streamPaises = Stream.fromFuture(_iniciaPaises());
    _locate.iniciaLocalizacao(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _iniciaPaises() async {
    String requisicao = await DefaultAssetBundle.of(context).loadString('data/paises.json');
    listaPaisesOriginal = json.decode(requisicao);
    listaPaisesBusca.addAll(listaPaisesOriginal);
    return listaPaisesBusca;
  }
  
  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale['TituloSelecionaPais']),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locate.locale[TraducaoStringsConstante.BuscarPaises],
                  funcao: () {
                    _realizaBusca(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
                  },
                ),
              ),
            ),
            body: StreamBuilder(
              stream: _streamPaises,
              builder: (BuildContext context, AsyncSnapshot snapshot) {

                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: Carregando(),
                    );
                  default:
                    if (!snapshot.hasData) {
                      return Center(
                        child: Carregando(),
                      );
                    }
                    else {
                      return ListView.builder(
                        itemCount: listaPaisesBusca == null ? 0 : listaPaisesBusca.length,
                        itemBuilder: (BuildContext context, int index){
                          return _paisItem(context, index);
                        }
                      );
                    }
                }
              },
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        },
      ),
    );
  }

  _paisItem(BuildContext context, int index) {
    return FadeInUp(
      1,
      Card(
        child: InkWell(
          onTap: () async{
            Navigator.pop(context, listaPaisesBusca[index]["ddi"]);
          },
          child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    // fit: FlexFit.tight,
                    // child: ClipRRect(
                    //   borderRadius: BorderRadius.circular(50.0),
                    //   child: Image.asset(
                    //   'images/flags/${listaPaisesBusca[index]["country"].toString().toLowerCase()}.png',
                    //   width: 50.0,
                    //   height: 50.0,
                    //   )
                    // ),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        // shape: BoxShape.circle,
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage('images/flags/${listaPaisesBusca[index]["country"].toString().toLowerCase()}.png'),
                          fit: BoxFit.fitHeight
                        )
                      ),
                    ),
                  ),

                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Text(listaPaisesBusca[index]["pais"], textAlign: TextAlign.center),
                  ),

                  Flexible(                          
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Text('+${listaPaisesBusca[index]["ddi"]}', textAlign: TextAlign.center,),
                  )
                ],
              ),
            ],
          ),
        ),
        ),
      )
    );
  }

  _realizaBusca({String pesquisa}) {
    List novaLista = new List();
    if (pesquisa.isNotEmpty) {
      listaPaisesOriginal.forEach((pais) {
        if (
          pais['pais'].toLowerCase().contains(pesquisa)
          || pais['ddi'].toLowerCase().contains(pesquisa)
        ) {
          novaLista.add(pais);
        }
      });
      setState(() {
        listaPaisesBusca.clear();
        listaPaisesBusca.addAll(novaLista);
      });
    }
    else {
      setState(() {
        listaPaisesBusca.clear();
        listaPaisesBusca.addAll(listaPaisesOriginal);
      });
    }
  }
}
