import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/lookup/ramoAtividadeLookUp.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:provider/provider.dart';

class RamoAtividadeModal extends StatefulWidget {

  RamoAtividadeModal({Key key}) : super (key: key);

  @override
  _RamoAtividadeModalState createState() => _RamoAtividadeModalState();
}

class _RamoAtividadeModalState extends State<RamoAtividadeModal> {

  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream _streamLista;
  TextEditingController _busca = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  List<RamoAtividadeLookUp> _lista = new List<RamoAtividadeLookUp>();
  String _pesquisa = '';
  Timer _debounce;
  FocusNode _focusBusca = new FocusNode();


  @override
  void initState() {
    _locate.iniciaLocalizacao(context);
    _streamLista = Stream.fromFuture(_fazRequest());
    super.initState();
    _busca.addListener(_buscaDebounce);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _pesquisa);
        _streamLista = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  void dispose() {
    _scrollController.dispose();
    _busca.removeListener(_buscaDebounce);
    _busca.dispose();
    _focusBusca.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestLista = await ClienteService().ramoAtividade.listaRamoAtividade(
        skip: _infinite.skipCount,
        search: _pesquisa
      );
      List<RamoAtividadeLookUp> listaRequest = new List<RamoAtividadeLookUp>();
      requestLista.forEach((data) {
        listaRequest.add(RamoAtividadeLookUp.fromJson(data));
      });

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      _infinite.novaLista = listaRequest;
      // Adicione a novaLista á lista original
      _lista.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return _lista;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.SelecaoRamoAtividade]),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      focusNode: _focusBusca,
                      textInputAction: TextInputAction.none,
                      onSubmitted: (_) {
                        _focusBusca.unfocus();
                      },
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                      controller: _busca,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _locate.locale[TraducaoStringsConstante.BuscarRamoAtividade],
                        hintStyle: TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                          icon: (_pesquisa == '')
                            ? Icon(Icons.search, color: Colors.white)
                            : Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            if (_pesquisa.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) => _busca.clear());
                            }
                          }
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: _listaItens(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  _realizaBusca() {
    if (_busca.text != _pesquisa) {
      _infinite.verificaPesquisaAlterada();
    }
    else {
      _infinite.pesquisaAlterada = false;
    }

    _pesquisa = _busca.text;
    setState(() {
      _lista = [];
    });
    _streamLista = Stream.fromFuture(_fazRequest());
  }

  _buscaDebounce() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_busca.text != _pesquisa) {
        _realizaBusca();
      }
    });
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return SemInformacao();
    }

    // else if (clientesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }

    else if (_lista.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: _scrollController,
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == _lista.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          if (index == _lista.length && _infinite.infiniteScrollCompleto) {
            return Container();
          }
          return _item(context, index, _lista[index]);
        },
        itemCount: _lista.length + 1,
      );
    }
  }

  _listaItens() {
    return StreamBuilder(
      stream: _streamLista,
      builder: (context, snapshot) {
        return _childStreamConexao(context: context, snapshot: snapshot);
      },
    );
  }

  Widget _item(BuildContext context, int index, RamoAtividadeLookUp ramoAtividade) {
    if (index >= _lista.length) {
      return null;
    }
    return InkWell(
      onTap: () {
        Navigator.pop(context, ramoAtividade);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan> [
                  TextSpan(
                    text: _locate.locale[TraducaoStringsConstante.Descricao] + ': ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ramoAtividade.descricao,
                  ),
                ]
              )
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <InlineSpan> [
                  TextSpan(
                    text: _locate.locale[TraducaoStringsConstante.Codigo] + ': ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${ramoAtividade.codigo}',
                  ),
                ]
              )
            ),
          ]
          // children: _preencheItem(elementos, index, lista)
        ),
      ),
    );
  }
}
