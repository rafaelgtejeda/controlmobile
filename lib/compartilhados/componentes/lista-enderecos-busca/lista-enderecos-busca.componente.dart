import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:provider/provider.dart';
import 'package:search_cep/search_cep.dart';

class ListaEnderecosBuscaComponente extends StatefulWidget {
  final List<CepInfo> listaCepsOriginal;
  ListaEnderecosBuscaComponente({@required this.listaCepsOriginal});

  @override
  _ListaEnderecosBuscaComponenteState createState() => _ListaEnderecosBuscaComponenteState();
}

class _ListaEnderecosBuscaComponenteState extends State<ListaEnderecosBuscaComponente> {
  List<CepInfo> listaCeps = [];

  LocalizacaoServico _locale = new LocalizacaoServico();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    listaCeps.addAll(widget.listaCepsOriginal);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['SelecioneEndereco']),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locale.locale[TraducaoStringsConstante.BuscarEnderecos],
                  funcao: () {
                    _realizaBusca(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
                  },
                ),
              ),
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                return _itemCEP(context, index, listaCeps);
              },
              itemCount: listaCeps.length
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  _realizaBusca({String pesquisa}) {
    List<CepInfo> novaLista = new List<CepInfo>();
    if (pesquisa.isNotEmpty) {
      widget.listaCepsOriginal.forEach((cep) {
        if (
          cep.ibge.toLowerCase().contains(pesquisa)
          || cep.localidade.toLowerCase().contains(pesquisa)
          || cep.logradouro.toLowerCase().contains(pesquisa)
          || cep.uf.toLowerCase().contains(pesquisa)
          || cep.complemento.toLowerCase().contains(pesquisa)
          || cep.bairro.toLowerCase().contains(pesquisa)
          || cep.cep.toLowerCase().contains(pesquisa)
        ) {
          novaLista.add(cep);
        }
      });
      setState(() {
        listaCeps.clear();
        listaCeps.addAll(novaLista);
      });
    }
    else {
      setState(() {
        listaCeps.clear();
        listaCeps.addAll(widget.listaCepsOriginal);
      });
    }
  }

  Widget _itemCEP(BuildContext context, int index, List<CepInfo> lista) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, lista[index]);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 8),
                    child: Icon(
                      Icons.home,
                      size: 50,
                      color: Colors.grey[700],
                    ),
                  )
                ],
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['CEP']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].cep ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['Endereco']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].logradouro ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['Complemento']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].complemento ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['Bairro']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].bairro ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['Cidade']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].localidade ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['Estado']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].uf ?? ''}"),
                        ]
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan> [
                          TextSpan(text: "${_locale.locale['IBGE']}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(text: "${lista[index].ibge ?? ''}"),
                        ]
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
