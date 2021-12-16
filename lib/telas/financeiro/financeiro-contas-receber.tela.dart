import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/financeiro/financeiro-lancamentos-previstos.modelo.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class FinanceiroContasReceberTela extends StatefulWidget {
  final String titulo;
  final bool receita;
  FinanceiroContasReceberTela({Key key, this.titulo, this.receita}) : super(key: key);
  @override
  FinanceiroContasReceberTelaState createState() => FinanceiroContasReceberTelaState();
}

class FinanceiroContasReceberTelaState extends State<FinanceiroContasReceberTela> with SingleTickerProviderStateMixin {
  LancamentosPrevistosModelo _contasReceber = new LancamentosPrevistosModelo();

  List<Lancamento> _contasReceberAVencer = new List<Lancamento>();
  List<Lancamento> _contasReceberVencido = new List<Lancamento>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyAVencer = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKeyVencido = GlobalKey<RefreshIndicatorState>();

  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamContasPagarReceber;
  TabController _tabController;
  int _currentIndex = 0;
  double _totalAVencer = 0;
  double _totalVencido = 0;

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamContasPagarReceber = Stream.fromFuture(_fazRequest());
    _tabController = new TabController(length: 2, vsync: this, initialIndex: _currentIndex);
  }

  @override
  void dispose() { 
    _tabController.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestPagar;
    if(widget.receita == null) {
      requestPagar = await FinanceiroService().obterContasAReceber();
      _contasReceber = LancamentosPrevistosModelo.fromJson(requestPagar);
    }
    else {
      requestPagar = await FinanceiroService().obterLancamentosPrevistoRealizadoReceita();
      _contasReceber = LancamentosPrevistosModelo.fromJsonReceita(requestPagar);
    }
    List<Lancamento> novaListaAVencer = _contasReceber.lancamentoAVencer;
    List<Lancamento> novaListaVencido = _contasReceber.lancamentoVencidos;
    if (novaListaAVencer != _contasReceberAVencer) {
      setState(() {
        _contasReceberAVencer.clear();
      });
      if(novaListaAVencer != null) {
        _contasReceberAVencer.addAll(novaListaAVencer);
      }
    }

    if (novaListaVencido != _contasReceberVencido) {
      setState(() {
        _contasReceberVencido.clear();
      });
      if(novaListaVencido != null) {
        _contasReceberVencido.addAll(novaListaVencido);
      }
    }
    setState(() {
      _totalAVencer = _calcularTotalAReceber(_contasReceberAVencer);
      _totalVencido = _calcularTotalRecebido(_contasReceberVencido);
    });
    return _contasReceber;
  }

  Future<void> _handleRefresh({@required GlobalKey<RefreshIndicatorState> refreshIndicatorKey}) {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });
    _streamContasPagarReceber = Stream.fromFuture(_fazRequest());

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

  double _calcularTotalAReceber(List<Lancamento> valoresAReceber) {
    double total = 0;
    valoresAReceber.forEach((valor) {
      total += valor.valorFinal;
    });
    return total;
  }

  double _calcularTotalRecebido(List<Lancamento> valoresPagos) {
    double total = 0;
    valoresPagos.forEach((valor) {
      total += valor.valorFinal;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.titulo),
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      _streamContasPagarReceber = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locate.locale['FiltrarData'],
                  desativarEmOffline: false,
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: DateFilterBarComponente(
                  key: _dateFilterState,
                  onPressed: () {
                    _streamContasPagarReceber = Stream.fromFuture(_fazRequest());
                  },
                  desativarEmOffline: false,
                ),
              ),
            ),
            bottomNavigationBar: _isOnline
              ? _totalBar()
              : Container(
                height: 88,
                child: ListView(
                  children: <Widget>[
                    _totalBar(),
                    OfflineMessageWidget()
                  ],
                ),
              ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        FlatButton(
                          // color: _currentIndex == 0 ? Theme.of(context).primaryColor : Colors.white,
                          textColor: _currentIndex == 0 ? Colors.white : Colors.black,
                          onPressed: () {
                            _tabController.animateTo(0);
                            setState(() {
                              _currentIndex = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentIndex == 0 ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _locate.locale[TraducaoStringsConstante.AVencer],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ),
                        FlatButton(
                          // color: _currentIndex == 1 ? Theme.of(context).primaryColor : Colors.white,
                          textColor: _currentIndex == 1 ? Colors.white : Colors.black,
                          onPressed: () {
                            _tabController.animateTo(1);
                            setState(() {
                              _currentIndex = 1;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _currentIndex == 1 ? Colors.green : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                width: 2,
                              )
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _locate.locale[TraducaoStringsConstante.Vencido],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder(
                      stream: _streamContasPagarReceber,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          default:
                          if (snapshot.hasError) {
                            return Container();
                          }
                          else if (_contasReceber == null && snapshot.connectionState != ConnectionState.waiting) {
                            return SemInformacao();
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: Carregando());
                          }
                          else {
                            return TabBarView(
                              controller: _tabController,
                              physics: NeverScrollableScrollPhysics(),
                              children: [
                                _aVencerTabBar(snapshot: snapshot),
                                _vencidoTabBar(snapshot: snapshot),
                              ]
                            );
                          }
                        }
                      }
                    ),
                  )
                ],
              ),
            ),
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
              _currentIndex == 0
              ? _locate.locale[TraducaoStringsConstante.TotalAVencer]
              : _locate.locale[TraducaoStringsConstante.TotalVencido],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _currentIndex == 0
              ? Helper().dinheiroFormatter(_totalAVencer)
              : Helper().dinheiroFormatter(_totalVencido),
              style: TextStyle(
                color: (_totalAVencer.isNegative || _totalAVencer == 0)
                ? Colors.red[900]
                : Colors.green[700],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _childStreamConexaoAVencer({@required BuildContext context, @required AsyncSnapshot snapshot,}) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_contasReceberAVencer.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_contasReceberAVencer.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        controller: new ScrollController(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
        itemCount: _contasReceberAVencer.length,
        itemBuilder: (context, index) {
            return _contaAVencerItem(index, _contasReceberAVencer);
        },
      );
    }
  }

  Widget _aVencerTabBar({@required AsyncSnapshot snapshot}) {
    return LiquidPullToRefresh(
      key: _refreshIndicatorKeyAVencer,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyAVencer);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        children: <Widget>[
          _childStreamConexaoAVencer(context: context, snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _contaAVencerItem(int index, List<Lancamento> lista) {
    DateTime data = DateTime.parse(lista[index].vencimento);
    String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.Vencimento] + ': ' + dataFormatada,
                ),
                Text(
                  _locate.locale[TraducaoStringsConstante.Descricao] + ':' + lista[index].descricao,
                ),
                Text(
                  _locate.locale[TraducaoStringsConstante.Cliente] + ':' + lista[index].parceiroNome,
                )
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  Helper().dinheiroFormatter(lista[index].valorFinal),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _childStreamConexaoVencido({@required BuildContext context, @required AsyncSnapshot snapshot,}) {
    if (snapshot.hasError) {
      return Container();
    }
    else if (_contasReceberVencido.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }
    else if (_contasReceberVencido.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        controller: new ScrollController(),
        shrinkWrap: true,
        separatorBuilder: (context, index) => Divider(thickness: 2, height: 0,),
        itemCount: _contasReceberVencido.length,
        itemBuilder: (context, index) {
            return _contaVencidoItem(index, _contasReceberVencido);
        },
      );
    }
  }

  Widget _vencidoTabBar({@required AsyncSnapshot snapshot}) {
    return LiquidPullToRefresh(
      key: _refreshIndicatorKeyVencido,
      onRefresh: () {
        return _handleRefresh(refreshIndicatorKey: _refreshIndicatorKeyVencido);
      },
      showChildOpacityTransition: false,
      springAnimationDurationInMilliseconds: 81,
      child: ListView(
        children: <Widget>[
          _childStreamConexaoVencido(context: context, snapshot: snapshot),
        ],
      ),
    );
  }

  Widget _contaVencidoItem(int index, List<Lancamento> lista) {
    DateTime data = DateTime.parse(lista[index].vencimento);
    String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.Vencimento] + ': ' + dataFormatada,
                ),
                Text(
                  _locate.locale[TraducaoStringsConstante.Descricao] + ':' + lista[index].descricao,
                ),
                Text(
                  _locate.locale[TraducaoStringsConstante.Cliente] + ':' + lista[index].parceiroNome,
                )
              ],
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  Helper().dinheiroFormatter(lista[index].valorFinal),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
