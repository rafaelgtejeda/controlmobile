import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/orcamento/ocamento-save.modelo.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/models/orcamento/orcamento-grid.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/rotas/orcamentos.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/orcamento/orcamento.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:erp/utils/request.util.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class OrcamentoListaTela extends StatefulWidget {
  @override
  _OrcamentoListaTelaState createState() => _OrcamentoListaTelaState();
}

class _OrcamentoListaTelaState extends State<OrcamentoListaTela> with SingleTickerProviderStateMixin {
  List<OrcamentoGrid> _orcamentoList = new List<OrcamentoGrid>();
  List<int> _orcamentosSelecionados = new List<int>();
  LocalizacaoServico _locate = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  Stream<dynamic> _streamOrcamentos;
  TabController _tabController;
  double _total = 0;

  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyPendente = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyAssinado = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyConcluido = GlobalKey<RefreshIndicatorState>();

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  ScrollController _scrollControllerPendente = new ScrollController();
  ScrollController _scrollControllerAssinado = new ScrollController();
  ScrollController _scrollControllerConcluido = new ScrollController();

  MediaQueryData _media = MediaQueryData();

  _OrcamentoListaTelaState() {
    // 
  }

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    _streamOrcamentos = Stream.fromFuture(_fazRequest());
    _scrollControllerPendente.addListener(() {
      if (_scrollControllerPendente.position.pixels == _scrollControllerPendente.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamOrcamentos = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
    _scrollControllerAssinado.addListener(() {
      if (_scrollControllerAssinado.position.pixels == _scrollControllerAssinado.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamOrcamentos = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
    _scrollControllerConcluido.addListener(() {
      if (_scrollControllerConcluido.position.pixels == _scrollControllerConcluido.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamOrcamentos = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  @override
  void dispose() { 
    _tabController.dispose();
    _scrollControllerPendente.dispose();
    _scrollControllerAssinado.dispose();
    _scrollControllerConcluido.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    List<OrcamentoGrid> listaOffline = new List<OrcamentoGrid>();
    if (!_infinite.infiniteScrollCompleto) {
      int status = -1;
      switch (_tabController.index) {
        case 0:
          status = ListagemOrcamentoConstante.PENDENTE;
          break;
        case 1:
          status = ListagemOrcamentoConstante.ASSINADO;
          break;
        case 2:
          status = ListagemOrcamentoConstante.CONCLUIDO;
          break;
        default:
          status = ListagemOrcamentoConstante.PENDENTE;
          break;
      }
      if(status == ListagemOrcamentoConstante.PENDENTE && !await RequestUtil().verificaOnline()) {
        listaOffline = await _adicionaOffline();
      }
      dynamic requestOrcamentos = await OrcamentoService().orcamentosLista(
        skip: _infinite.skipCount,
        search: _buscaKey.currentState?.pesquisa ?? '',
        status: status
      );
      List<OrcamentoGrid> listaOrcamentos = new List<OrcamentoGrid>();
      if (listaOffline.isNotEmpty) {
        listaOrcamentos.addAll(listaOffline);
      }
      requestOrcamentos.forEach((data) {
        listaOrcamentos.add(OrcamentoGrid.fromJson(data));
      });
      _infinite.novaLista = listaOrcamentos;
      _orcamentoList.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      setState(() {
        _total = _calcularTotal();
      });
      return _orcamentoList;
    }
    else {
      return null;
    }
  }

  Future<List<OrcamentoGrid>> _adicionaOffline() async {
    dynamic orcamentosOffline = await DBProvider.db.getOfflineExibicao(Endpoints.ORCAMENTO_INCLUIR);

    List<OrcamentoGrid> listaOrcamentos = new List<OrcamentoGrid>();
    orcamentosOffline.forEach((data) {
      OrcamentoGrid orcamento = new OrcamentoGrid.fromJsonOffline(data);
      
      listaOrcamentos.add(orcamento);
    });

    return listaOrcamentos;
  }

  double _calcularTotal() {
    double total = 0;
    _orcamentoList.forEach((data) {
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
      _orcamentoList.clear();
      _orcamentosSelecionados.clear();
      _total = 0;
    });
    _buscaKey.currentState?.clearBusca();
    _infinite.restart();
    _streamOrcamentos = Stream.fromFuture(_fazRequest());
  }

  Future _alertaModalTipoOrcamento() async {
    return await AlertaComponente().showAlerta(
      context: context,
      barrierDismissible: true,
      titulo: _locate.locale[TraducaoStringsConstante.TipoOrcamento],
      mensagem: _locate.locale[TraducaoStringsConstante.SelecioneTipoOrcamento],
      conteudo: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              height: 32,
              child: SizedBox.expand(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, TiposOrcamentos.VENDA);
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Texto(
                    _locate.locale[TraducaoStringsConstante.Venda],
                    color: Colors.white,
                    bold: true,
                    fontSize: 16
                  )
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              height: 32,
              child: SizedBox.expand(
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context, TiposOrcamentos.SERVICO);
                  },
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  child: Texto(
                    _locate.locale[TraducaoStringsConstante.ProdutoServico],
                    color: Colors.white,
                    bold: true,
                    fontSize: 16
                  )
                ),
              ),
            ),
          ),
        ],
      ),
      acoes: [
        FlatButton(
          child: Text(_locate.locale['Cancelar']),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Text(_locate.locale[TraducaoStringsConstante.Orcamentos]),
                actions: <Widget>[
                  AddButtonComponente(
                    funcao: () async{
                      final tipo = await _alertaModalTipoOrcamento();

                      if (tipo is int) {
                        final resultado = await RotasOrcamentos.vaParaCadastroOrcamento(context, tipoOrcamento: tipo);
                        if(resultado == true){
                          _dateFilterState.currentState.obtemDatas();
                          _atualizarLista();
                        }
                      }
                    },
                    tooltip: _locate.locale[TraducaoStringsConstante.CadastrarOrcamento],
                    desativarEmOffline: false,
                  ),
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
                    desativarEmOffline: false,
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
                        desativarEmOffline: false,
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
                            _orcamentoList.clear();
                          });
                          _streamOrcamentos = Stream.fromFuture(_fazRequest());
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
                            _locate.locale[TraducaoStringsConstante.Assinado],
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
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder(
                  stream: _streamOrcamentos,
                  builder: (context, snapshot) {
                    return TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _tabBar(
                          snapshot: snapshot, key: _refreshIndicatorKeyPendente, scroll: _scrollControllerPendente
                        ),
                        _tabBar(
                          snapshot: snapshot, key: _refreshIndicatorKeyAssinado, scroll: _scrollControllerAssinado
                        ),
                        _tabBar(
                          snapshot: snapshot, key: _refreshIndicatorKeyConcluido, scroll: _scrollControllerConcluido
                        ),
                      ]
                    );
                  }
                ),
              ),
              bottomNavigationBar: _diretivas.diretivasDisponiveis.venda.possuiLiberacaoTotalVendasLabel
              ? BottomAppBar(
                child: _isOnline
                  ? _totalBar()
                  : Container(
                    height: _media.size.height > 350 ? (42 + 40.toDouble()) : (32 + 40.toDouble()),
                    child: ListView(
                      children: <Widget>[
                        _totalBar(),
                        OfflineMessageWidget()
                      ],
                    ),
                  ),
              )
              : null,
              // bottomNavigationBar: _diretivas.diretivasDisponiveis.venda.possuiLiberacaoTotalVendasLabel
              // ? _totalBar()
              // : null,
            ),
          );
        }
      ),
    );
  }

  _changeTab(int index) {
    _atualizarLista();
  }

  Widget _totalBar() {
    return Container(
      height: _media.size.height > 350 ? 42 : 32 ,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _tabController.index == 0
              ? _locate.locale[TraducaoStringsConstante.TotalPendente]
              : _tabController.index == 1
                ? _locate.locale[TraducaoStringsConstante.TotalAssinado]
                : _locate.locale[TraducaoStringsConstante.TotalConcluido],
              style: TextStyle(
                fontSize: _media.size.height > 350 ? 12 * _media.textScaleFactor : 9 * _media.textScaleFactor,
                // fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Helper().dinheiroFormatter(_total),
              style: TextStyle(
                color: Colors.green,
                // fontSize: 18,
                fontSize: _media.size.height > 350 ? 12 * _media.textScaleFactor : 9 * _media.textScaleFactor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _childStreamConexao({@required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_orcamentoList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_orcamentoList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
        itemCount: _orcamentoList.length + 1,
        itemBuilder: (context, index) {
          if (index == _orcamentoList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _tabController.index != 2
            ? _orcamentoItem(context: context, index: index, lista: _orcamentoList)
            : _orcamentoItemConcluido(context: context, index: index, lista: _orcamentoList);
        },
      );
    }
  }

  Widget _tabBar({@required AsyncSnapshot snapshot, GlobalKey<RefreshIndicatorState> key, ScrollController scroll}) {
    return LiquidPullToRefresh(
      key: key,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyConcluido);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        controller: scroll,
        physics: AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          _childStreamConexao(snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _tabBarPendente({@required AsyncSnapshot snapshot}) {
    return LiquidPullToRefresh(
      key: _refreshIndicatorKeyPendente,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyPendente);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        controller: _scrollControllerPendente,
        children: <Widget>[
          _childStreamConexao(snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _tabBarAssinado({@required AsyncSnapshot snapshot}) {
    return LiquidPullToRefresh(
      key: _refreshIndicatorKeyAssinado,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyAssinado);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        controller: _scrollControllerAssinado,
        children: <Widget>[
          _childStreamConexao(snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _tabBarConcluido({@required AsyncSnapshot snapshot, GlobalKey<RefreshIndicatorState> key}) {
    return LiquidPullToRefresh(
      key: key,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyConcluido);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        controller: _scrollControllerConcluido,
        children: <Widget>[
          _childStreamConexao(snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _orcamentoItem({BuildContext context, int index, List<OrcamentoGrid> lista}) {
    if (index >= lista.length) {
      return null;
    }
    String dataFormatada = '';
    if (lista[index].data != null) {
      DateTime data = DateTime.parse(lista[index].data);
      dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Text(
                        //   dataFormatada,
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold
                        //   ),
                        // ),

                        // Text(
                        //   lista[index].numero.toString(),
                        //   style: TextStyle(
                        //     fontSize: 18,
                        //     fontWeight: FontWeight.bold
                        //   ),
                        // ),

                        RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan> [
                              TextSpan(
                                text: "${_locate.locale[TraducaoStringsConstante.DataOrcamento]}: ",
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
                                text: "${_locate.locale[TraducaoStringsConstante.NumeroDoOrcamento]}: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )
                              ),
                              TextSpan(
                                text: '${lista[index].numero ?? _locate.locale[TraducaoStringsConstante.Pendente]}',
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
                                text: lista[index].vendedor,
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
                                text: lista[index].cliente,
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
                        Visibility(
                          visible: lista[index].offline,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Icon(
                              Icons.sync,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          Helper().dinheiroFormatter(lista[index].valor),
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

              Visibility(
                visible: lista[index].offline,
                child: Chip(
                  label: Container(
                    width: double.maxFinite,
                    child: Center(
                      child: Text(
                        _locate.locale[TraducaoStringsConstante.AguardandoSincronizacao],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.red,
                ),
              )
            ],
          ),
        ),
        onTap: () {
          _selecionarOrcamento(idOrcamento: lista[index].id, index: index);
        },
        // onTap: () async {
        //   dynamic retorno = await OrcamentoService().obterOrcamentoDetalhes(context: context, id: lista[index].id);
        //   DetalhesOrcamentoModelo detalhesOrcamentoRetorno = DetalhesOrcamentoModelo.fromJson(retorno);
        //   RotasOrcamentos.vaParaOrcamentoDetalhes(context, detalhesOrcamento: detalhesOrcamentoRetorno);
        // },
        // onLongPress: () {
        //   _multiplaSelecaoOrcamento(idOrcamento: lista[index].id, index: index);
        // },
      ),
      secondaryActions: <Widget>[
          
        IconSlideAction(
          caption: _locate.locale['Remover'],
          color: Colors.red,
          icon: Icons.delete,
          onTap: () {
            _deletar(idOrcamento: lista[index].id);
              // _confirmarDeletarMateriaisServico(msLista[index].id);
          },
        ),
          
        IconSlideAction(
          caption: _locate.locale['Visualizar'],
          color: Colors.orange,
          icon: Icons.assignment,
          onTap: () {
            _visualizarDetalhesEAssinar(idOrcamento: lista[index].id, numeroOrcamento: lista[index].numero);
          },
        ),

      ],
    );
  }

  Widget _orcamentoItemConcluido({BuildContext context, int index, List<OrcamentoGrid> lista}) {
    if (index >= lista.length) {
      return null;
    }
    String dataFormatada = '';
    if (lista[index].data != null) {
      DateTime data = DateTime.parse(lista[index].data);
      dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
    }
    return InkWell(
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
                          text: "${_locate.locale[TraducaoStringsConstante.DataOrcamento]}: ",
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
                          text: "${_locate.locale[TraducaoStringsConstante.NumeroDoOrcamento]}: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )
                        ),
                        TextSpan(
                          text: lista[index].numero.toString(),
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
                          text: lista[index].vendedor,
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
                          text: lista[index].cliente,
                          style: TextStyle(
                            fontSize: 18,
                          )
                        ),
                      ]
                    )
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    Helper().dinheiroFormatter(lista[index].valor),
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
      onTap: () {
        _visualizarDetalhesEAssinar(idOrcamento: lista[index].id, numeroOrcamento: lista[index].numero);
      },
    );
  }

  _selecionarOrcamento({int idOrcamento, int index}) async {
    dynamic retorno = await OrcamentoService().getOrcamento(id: idOrcamento, context: context);
    OrcamentoModeloGet orcamentoRetorno = OrcamentoModeloGet.fromJson(retorno);

    final resultado = await RotasOrcamentos.vaParaCadastroOrcamento(
      context,
      orcamento: orcamentoRetorno,
    );

    if (resultado != null && resultado == true) {
      _atualizarLista();
    }
  }

  _visualizarDetalhesEAssinar({@required int idOrcamento, int numeroOrcamento}) async {
    // ClienteLookup clienteSelecionado = new ClienteLookup();
    // VendedoresLookUp vendedorSelecionado = new VendedoresLookUp();

    dynamic retorno = await OrcamentoService().getOrcamento(id: idOrcamento, context: context);
    OrcamentoModeloGet orcamento = OrcamentoModeloGet.fromJson(retorno);

    // dynamic _requestCliente = await ClienteService().getClienteLookup(id: orcamento.contatoId);
    // clienteSelecionado = ClienteLookup.fromJson(_requestCliente[0]);

    // dynamic _requestVendedor = await VendedoresService().getVendedores(orcamento.vendedores[0].id);
    // vendedorSelecionado = VendedoresLookUp.fromJson(_requestVendedor[0]);

    final resultado = await RotasOrcamentos.vaParaVisualizacaoDetalhesAssinaturaOrcamento(
      context,
      orcamento: orcamento,
      // cliente: clienteSelecionado,
      // vendedor: vendedorSelecionado,
      numeroOrcamento: numeroOrcamento
    );

    if (resultado != null && resultado == true) {
      _atualizarLista();
    }
  }

  _multiplaSelecaoOrcamento({int idOrcamento, int index}) {
    if (!_orcamentosSelecionados.contains(idOrcamento)) {
      _orcamentosSelecionados.add(idOrcamento);
      setState(() {
        _orcamentoList[index].isSelected = true;
      });
    }
    else {
      _orcamentosSelecionados.remove(idOrcamento);
      setState(() {
        _orcamentoList[index].isSelected = false;
      });
    }
  }

  // void _escolheOpcao(String escolha) {
  //   switch (escolha) {
  //     case ConstantesOpcoesPopUpMenu.SELECIONAR_TODOS:
  //       _selecionarTodos();
  //       break;
  //     case ConstantesOpcoesPopUpMenu.DELETAR_TODOS:
  //       // _selecionarTodos();
  //       break;
  //     default:
  //       break;
  //   }
  // }

  // _selecionarTodos() async {
  //   if(_orcamentosSelecionados.length == 0) {
  //     dynamic requestSelecionarTodos = await ClienteService().parque.selecionaTodosParques(context: context, parceiroId: widget.parceiroId);
  //     _orcamentosSelecionados.clear();

  //     requestSelecionarTodos.forEach((data) {
  //       _orcamentosSelecionados.add(data);
  //     });
  //     setState(() {
  //       parquesList.forEach((parque) {
  //         parque.isSelected = true;
  //       });
  //     });
  //   }
  //   else if(_orcamentosSelecionados.length <= parquesList.length) {
  //     _orcamentosSelecionados.clear();
  //     setState(() {
  //       parquesList.forEach((parque) {
  //         parque.isSelected = false;
  //       });
  //     });
  //   }
  // }

  List<OrcamentoGrid> _verificaSelecionado({List<OrcamentoGrid> lista}) {
    lista.forEach((orcamento) {
      if(_orcamentosSelecionados.contains(orcamento.id)) {
        orcamento.isSelected = true;
      }
    });
    return lista;
  }

  // _confirmarDeletarSelecao() async {
  //   bool deletar = false;
  //   if (_orcamentosSelecionados.length == 1) {
  //     deletar = await AlertaComponente()
  //       .showAlertaConfirmacao(context: context, mensagem: _locate.locale['DeletarParqueConfirmacao']);
  //     if (deletar == true) {
  //       Response resultado = await ClienteService().parque.deletaParque(idParque: _orcamentosSelecionados[0], context: context);
  //       _deletarOrcamentos(resultado);
  //     }
  //   }
  //   else if (_orcamentosSelecionados.length > 1 && _orcamentosSelecionados.length < _orcamentoList.length) {
  //     deletar = await AlertaComponente()
  //       .showAlertaConfirmacao(context: context, mensagem: _locate.locale['DeletarOrcamentosSelecionadosConfirmacao']);
  //     if (deletar == true) {
  //       Response resultado = await ClienteService().parque.deletaParquesLote(idParques: _orcamentosSelecionados, context: context);
  //       _deletarOrcamentos(resultado);
  //     }
  //   }
  //   else if (_orcamentosSelecionados.length == _orcamentoList.length) {
  //     deletar = await AlertaComponente()
  //       .showAlertaConfirmacao(context: context, mensagem: _locate.locale['DeletarParquesTodosConfirmacao']);
  //     if (deletar == true) {
  //       // Response resultado = await ClienteService().parque.deletaParquesLote(idParque: _orcamentosSelecionados, context: context);
  //       // _deletarParques(resultado);
  //     }
  //   }
  // }

  _deletar({int idOrcamento}) async {
    bool deletar = false;
    // if (_orcamentosSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locate.locale['DeletarOrcamentoConfirmacao']);
      if (deletar == true) {
        Response resultado = await OrcamentoService().deletaOrcamento(idOrcamento: idOrcamento, context: context);
        _deletarOrcamentos(resultado);
      }
    // }
  }

  _deletarOrcamentos(Response resultado) {
    // Tratar Deletes Offline
    if (resultado.statusCode == 200) {
      _atualizarLista();
    }
  }
}
