import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/produto/produto.servicos.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ListaProdutosModalComponente extends StatefulWidget {
  final List<int> tipos;
  final int empresaIdOverride;
  ListaProdutosModalComponente({Key key, this.tipos, this.empresaIdOverride}) : super(key: key);
  @override
  _ListaProdutosModalComponenteState createState() => _ListaProdutosModalComponenteState();
}

class _ListaProdutosModalComponenteState extends State<ListaProdutosModalComponente> {

  List<Produto> _produtosList = new List<Produto>();
  List<int> _tipos = new List<int>();
  Stream<dynamic> _streamProdutos;

  ScrollController _scrollController = new ScrollController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  LocalizacaoServico _locale = new LocalizacaoServico();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  _ListaProdutosModalComponenteState(){
    _streamProdutos = Stream.fromFuture(_fazRequest());
  }

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    if(widget.tipos != null) {
      _tipos = widget.tipos;
    }
    _streamProdutos = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamProdutos = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    _atualizarLista();

    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: const Text('Refresh complete'),
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: () {
            _refreshIndicatorKey.currentState.show();
          }
        )
      ));
    });
  }

  _atualizarLista() {
    setState(() {
      _produtosList.clear();
      _buscaKey.currentState.clearBusca();
    });
    _infinite.restart();
    _streamProdutos = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {

    if (!_infinite.infiniteScrollCompleto) {
      dynamic requestProdutos;

      if (widget.empresaIdOverride != null) {
        requestProdutos = await ProdutoService().listaProdutos(
          skip: _infinite.skipCount,
          search: _buscaKey.currentState?.pesquisa ?? '',
          tipos: widget.tipos,
          empresaIdOverride: widget.empresaIdOverride
        );
      }
      else {
        requestProdutos = await ProdutoService().listaProdutos(
          skip: _infinite.skipCount,
          search: _buscaKey.currentState?.pesquisa ?? '',
          tipos: widget.tipos
        );
      }

      ProdutoLookUp resultado = ProdutoLookUp.fromJson(requestProdutos);
      _infinite.novaLista = resultado.lista;
      _produtosList.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      
      return _produtosList;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(_locale.locale['SelecioneProduto']),
              actions: <Widget>[
                Tooltip(
                  message: _locale.locale['LimparProduto'],
                  child: FlatButton(
                    color: Theme.of(context).primaryColorDark,
                    child: Text(_locale.locale['Limpar']),
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locale.locale[TraducaoStringsConstante.BuscarProdutos],
                  funcao: () {
                    if (_buscaKey.currentState.alterouBusca()) {
                      _infinite.verificaPesquisaAlterada();
                    }
                    else {
                      _infinite.pesquisaAlterada = false;
                    }
                    setState(() {
                      _produtosList.clear();
                    });
                    _infinite.restart();
                    _streamProdutos = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: _listagemProdutos(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        },
      ),
    );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_produtosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_produtosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 1,),
        itemBuilder: (context, index) {
          if (index == _produtosList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _produtoItem(context, index, _produtosList);
        },
        itemCount: _produtosList.length + 1,
      );
    }
  }

  Widget _listagemProdutos() {
    return StreamBuilder(
      stream: _streamProdutos,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }

  Widget _produtoItem(BuildContext context, int index, List<Produto> lista) {
    if (index >= lista.length) {
      return null;
    }

    return InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "${_locale.locale['Codigo']}: " + (lista[index].codigo ?? ""),
              style: TextStyle(fontSize: 18,),
            ),
            Text(
              "${_locale.locale['DescricaoResumida']}: " + (lista[index].descricaoResumida ?? ""),
              style: TextStyle(fontSize: 18,),
            ),
            Text(
              "${_locale.locale['Descricao']}: " + (lista[index].descricao ?? ""),
              style: TextStyle(fontSize: 18,),
            ),
            Text(
              "${_locale.locale['MarcaProduto']}: " + (lista[index].marca ?? ""),
              style: TextStyle(fontSize: 18,),
            ),
            Text(
              "${_locale.locale['Estoque']}: " + (lista[index].saldoEstoque.toString() ?? ""),
              style: TextStyle(fontSize: 18,),
            ),
          ],
        ),
      ),
      onTap: () {
        // _selecionarProduto(idCliente: lista[index].id, index: index);
        Navigator.pop(context, lista[index]);
      }
    );
  }
}
