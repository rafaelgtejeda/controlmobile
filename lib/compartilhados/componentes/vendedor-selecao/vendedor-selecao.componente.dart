import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class VendedorSelecaoComponente extends StatefulWidget {
  VendedorSelecaoComponente({Key key}) : super(key: key);
  _VendedorSelecaoComponenteState createState() => _VendedorSelecaoComponenteState();
}

class _VendedorSelecaoComponenteState extends State<VendedorSelecaoComponente> {
  List<VendedoresLookUp> _vendedoresList = new List<VendedoresLookUp>();

  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamVendedores;

  Helper helper = new Helper();

  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  @override
  void initState() {
    super.initState();
    _vendedoresList.clear();
    _locale.iniciaLocalizacao(context);
    _streamVendedores = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState.pesquisa ?? '');
        _streamVendedores = Stream.fromFuture(_fazRequest());
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
      _vendedoresList.clear();
    });
    _infinite.restart();
    _streamVendedores = Stream.fromFuture(_fazRequest());
  }
  
  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale[TraducaoStringsConstante.SelecioneVendedor], style: TextStyle(fontSize: 16)),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locale.locale[TraducaoStringsConstante.BuscarVendedores],
                  funcao: () {
                    if (_buscaKey.currentState.alterouBusca()) {
                      _infinite.verificaPesquisaAlterada();
                    }
                    else {
                      _infinite.pesquisaAlterada = false;
                    }
                    _atualizarLista();
                  },
                ),
              ),
            ),
            body: _listagemVendedores(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<dynamic> _fazRequest() async {
    
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestVendedores;
      requestVendedores = await VendedoresService().listaVendedores(
        skip: _infinite.skipCount, search: _buscaKey.currentState?.pesquisa ?? ''
      );
      List<VendedoresLookUp> listaVendedores = new List<VendedoresLookUp>();
      requestVendedores.forEach((data) {
        listaVendedores.add(VendedoresLookUp.fromJson(data));
      });
      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      _infinite.novaLista = listaVendedores;
      // Adicione a novaLista á lista original
      _vendedoresList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return _vendedoresList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (_vendedoresList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (_vendedoresList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == _vendedoresList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _vendedorItem(context, index, _vendedoresList);
        },
        itemCount: _vendedoresList.length + 1,
      );
    }
  }

  Widget _listagemVendedores() {
    return StreamBuilder(
      stream: _streamVendedores,
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

  Widget _vendedorItem(BuildContext context, int index, List<VendedoresLookUp> lista) {

    if (index >= lista.length) {
      return null;
    }
    
    return InkWell(
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lista[index].nome ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "${_locale.locale['Email']}: " + (lista[index].email ?? ""),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _selecionarVendedor(vendedor: lista[index]);
      },
    );
  }

  _selecionarVendedor({VendedoresLookUp vendedor}) async {
    Navigator.pop(context, vendedor);
  }
}
