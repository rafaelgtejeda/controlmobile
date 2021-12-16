import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/venda/detalhes-venda.modelo.dart';
import 'package:erp/models/venda/pedido-venda.modelo.dart';
import 'package:erp/rotas/vendas.rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/venda/venda.servicos.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class PedidoVendaTela extends StatefulWidget {
  @override
  _PedidoVendaTelaState createState() => _PedidoVendaTelaState();
}

class _PedidoVendaTelaState extends State<PedidoVendaTela> with SingleTickerProviderStateMixin {

  List<PedidoVendaGrid> _pedidoVendaList = new List<PedidoVendaGrid>();
  LocalizacaoServico _locate = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  Stream<dynamic> _streamVendaPedido;
  TabController _tabController;
  double _total = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPendente = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyConcluido = GlobalKey<RefreshIndicatorState>();

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  ScrollController _scrollControllerPendente = new ScrollController();
  ScrollController _scrollControllerConcluido = new ScrollController();

  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _tabController = new TabController(length: 2, vsync: this, initialIndex: 0);
    _streamVendaPedido = Stream.fromFuture(_fazRequest());
    _scrollControllerPendente.addListener(() {
      if (_scrollControllerPendente.position.pixels == _scrollControllerPendente.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa);
        _streamVendaPedido = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
    _scrollControllerConcluido.addListener(() {
      if (_scrollControllerConcluido.position.pixels == _scrollControllerConcluido.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa);
        _streamVendaPedido = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  @override
  void dispose() { 
    _tabController.dispose();
    _scrollControllerPendente.dispose();
    _scrollControllerConcluido.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    if (!_infinite.infiniteScrollCompleto) {
      dynamic requestPedidoVenda = await VendaService().vendas(
        skip: _infinite.skipCount,
        search: _buscaKey.currentState?.pesquisa,
        status: _tabController.index
      );
      List<PedidoVendaGrid> listaPedidoVenda = new List<PedidoVendaGrid>();
      requestPedidoVenda.forEach((data) {
        listaPedidoVenda.add(PedidoVendaGrid.fromJson(data));
      });
      _infinite.novaLista = listaPedidoVenda;
      _pedidoVendaList.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      setState(() {
        _total = _calcularTotal();
      });
      return _pedidoVendaList;
    }
    else {
      return null;
    }
  }

  double _calcularTotal() {
    double total = 0;
    _pedidoVendaList.forEach((data) {
      total += data.valor;
    });
    return total;
  }

  Future<void> _handleRefresh({@required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) {
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
            refreshIndicatorKey.currentState.show();
          }
        )
      ));
    });
  }

  _atualizarLista() {
    setState(() {
      _pedidoVendaList.clear();
    });
    _buscaKey.currentState?.clearBusca();
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamVendaPedido = Stream.fromFuture(_fazRequest());
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: Text(_locate.locale[TraducaoStringsConstante.PedidoVenda]),
                actions: <Widget>[
                  DateFilterButtonComponente(
                    funcao: () async{
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                      );
                      if(result == true){
                        _dateFilterState.currentState.obtemDatas();
                        _atualizarLista();
                      }
                    },
                    tooltip: _locate.locale['FiltrarData'],
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(132),
                  child: Column(
                    children: <Widget>[
                      DateFilterBarComponente(
                        key: _dateFilterState,
                        onPressed: () {
                          _atualizarLista();
                        },
                      ),
                      BuscaComponente(
                        key: _buscaKey,
                        placeholder: _locate.locale[TraducaoStringsConstante.NumeroOrcamentoOuNomeCliente],
                        funcao: () {
                          if (_buscaKey.currentState.alterouBusca()) {
                            _infinite.verificaPesquisaAlterada();
                          }
                          else {
                            _infinite.pesquisaAlterada = false;
                          }
                          setState(() {
                            _pedidoVendaList.clear();
                          });
                          _streamVendaPedido = Stream.fromFuture(_fazRequest());
                        },
                      ),
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).primaryColor,
                        indicatorWeight: 3,
                        tabs: <Widget> [
                          Tab(child: Text(
                            _locate.locale[TraducaoStringsConstante.Pendente],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),),
                          Tab(child: Text(
                            _locate.locale[TraducaoStringsConstante.Concluido],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),),
                        ],
                        onTap: _changeTab,
                      )
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: _diretivas.diretivasDisponiveis.venda.possuiLiberacaoTotalVendasLabel
              ? BottomAppBar(
                child: _isOnline
                  ? _totalBar()
                  : Container(
                    height: 80,
                    child: ListView(
                      children: <Widget>[
                        _totalBar(),
                        OfflineMessageWidget()
                      ],
                    ),
                  ),
              )
              : null,
              body: CustomOfflineWidget(child: _listagem()),
            ),
          );
        }
      ),
    );
  }

  _changeTab(int index) {
    _atualizarLista();
  }

  Widget _listagem() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder(
        stream: _streamVendaPedido,
        builder: (context, snapshot) {
          return TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              _tabBar(snapshot: snapshot, key: _refreshIndicatorKeyPendente, scroll: _scrollControllerPendente),
              _tabBar(snapshot: snapshot, key: _refreshIndicatorKeyConcluido, scroll: _scrollControllerConcluido),
            ]
          );
        }
      ),
    );
  }

  Widget _totalBar() {
    return Container(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _tabController.index == 0
              ? _locate.locale[TraducaoStringsConstante.TotalPendente]
              : _locate.locale[TraducaoStringsConstante.TotalConcluido],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Helper().dinheiroFormatter(_total),
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _childStreamConexao({
    @required BuildContext context, @required AsyncSnapshot snapshot
  }) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_pedidoVendaList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_pedidoVendaList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        controller: new ScrollController(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
        itemCount: _pedidoVendaList.length + 1,
        itemBuilder: (context, index) {
          if (index == _pedidoVendaList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _pedidoVendaItem(context: context, index: index, lista: _pedidoVendaList);
          // if (_pedidoVendaList.length == 0) {
          //   return SemInformacao();
          // }
          // else {
          //   return _pedidoVendaItem(index, _pedidoVendaList);
          // }
        },
      );
    }
  }

  Widget _tabBar({@required AsyncSnapshot snapshot, GlobalKey<RefreshIndicatorState> key, ScrollController scroll}) {
    return LiquidPullToRefresh(
      key: key,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: key);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        // controller: _scrollControllerPendente,
        controller: scroll,
        physics: AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _childStreamConexao(context: context, snapshot: snapshot),
        ],
      ),
    );
  }

  // Widget _tabBarPendente({@required AsyncSnapshot snapshot}) {
    // return LiquidPullToRefresh(
    //   key: _refreshIndicatorKey,
    //   onRefresh: _handleRefresh,
    //   showChildOpacityTransition: false,
    //   springAnimationDurationInMilliseconds: 81,
    //   child: ListView.separated(
    //     separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
    //     itemCount: _pedidoVendaList.length,
    //     itemBuilder: (context, index) {
    //       if (_pedidoVendaList.length == 0) {
    //         return SemInformacao();
    //       }
    //       else {
    //         return _pedidoVendaItem(index, _pedidoVendaList);
    //       }
    //     },
    //   ),
    // );

    // return ListView.separated(
    //   controller: _scrollController,
    //   separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
    //   itemCount: _pedidoVendaList.length + 1,
    //   itemBuilder: (context, index) {
    //     if (index == _pedidoVendaList.length && !_infinite.infiniteScrollCompleto) {
    //       return Container(
    //         height: 100,
    //         width: 100,
    //         alignment: Alignment.center,
    //         child: Carregando(),
    //       );
    //     }
    //     return _pedidoVendaItem(index, _pedidoVendaList);
    //     // if (_pedidoVendaList.length == 0) {
    //     //   return SemInformacao();
    //     // }
    //     // else {
    //     //   return _pedidoVendaItem(index, _pedidoVendaList);
    //     // }
    //   },
    // );
  // }

  Widget _pedidoVendaItem({BuildContext context, int index, List<PedidoVendaGrid> lista}) {
    if (index >= lista.length) {
      return null;
    }
    PedidoVendaGrid item = lista[index];
    DateTime data = DateTime.parse(item.dataOrcamento);
    String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
    return InkWell(
      onTap: () async {
        dynamic retorno = await VendaService().obterVendaDetalhes(context: context, id: item.id);
        DetalhesVendaModelo detalhesVendaRetorno = DetalhesVendaModelo.fromJson(retorno);
        RotasVendas.vaParaPedidoVendaDetalhes(context, detalhesVenda: detalhesVendaRetorno, numeroVenda: item.numero);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan> [
                        TextSpan(
                          text: "${_locate.locale[TraducaoStringsConstante.Numero]}: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        TextSpan(
                          text: item.numero.toString(),
                          style: TextStyle(
                            fontSize: 18,
                          )
                        ),
                      ]
                    )
                  ),

                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan> [
                        TextSpan(
                          text: "${_locate.locale[TraducaoStringsConstante.Data]}: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        TextSpan(
                          text: dataFormatada,
                          style: TextStyle(
                            fontSize: 18,
                          )
                        ),
                      ]
                    )
                  ),

                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan> [
                        TextSpan(
                          text: "${_locate.locale[TraducaoStringsConstante.Vendedor]}: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        TextSpan(
                          text: item.vendedor,
                          style: TextStyle(
                            fontSize: 18,
                          )
                        ),
                      ]
                    )
                  ),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan> [
                        TextSpan(
                          text: _locate.locale[TraducaoStringsConstante.Cliente] + ': ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        TextSpan(
                          text: item.cliente,
                          style: TextStyle(
                            fontSize: 18,
                          )
                        ),
                      ]
                    )
                  ),

                  // Text(
                  //   _locate.locale[TraducaoStringsConstante.VENDEDOR] + ':' + lista[index].vendedor,
                  // ),
                  // Text(
                  //   _locate.locale[TraducaoStringsConstante.CLIENTE] + ':' + lista[index].cliente,
                  // )
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Helper().dinheiroFormatter(item.valor),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
