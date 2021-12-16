import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/datefilter.listener.dart';
import 'package:erp/models/financeiro/financeiro-dashboard.modelo.dart';
import 'package:erp/rotas/financeiro.rotas.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/helperFontSize.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:responsive_widgets/responsive_widgets.dart';

class FinanceiroTela extends StatefulWidget {
  FinanceiroTela({Key key}) : super(key: key);
  _FinanceiroTelaState createState() => _FinanceiroTelaState();
}

class _FinanceiroTelaState extends State<FinanceiroTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  FinanceiroDashboard _financeiroDashboard = new FinanceiroDashboard();
  Stream<dynamic> _streamDashboard;

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  _FinanceiroTelaState() {
   
  }

  @override
  void initState() { 
    super.initState();
    _locale.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _streamDashboard = Stream.fromFuture(_fazRequest());
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });
    _streamDashboard = Stream.fromFuture(_fazRequest());

    return completer.future.then<void>((_) {
      // _scaffoldKey.currentState?.showSnackBar(SnackBar(
      //   content: const Text('Refresh complete'),
      //   action: SnackBarAction(
      //     label: 'RETRY',
      //     onPressed: () {
      //       _refreshIndicatorKey.currentState.show();
      //     }
      //   )
      // ));
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(_locale.locale["Financeiro"].toUpperCase(), style: TextStyle(fontSize: 16)),
              centerTitle: false,
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      _streamDashboard = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale['FiltrarData'],
                ),
                PopupMenuButton<String>(
                  onSelected: _escolheOpcao,
                  itemBuilder: (BuildContext context) {
                    return ConstantesOpcoesPopUpMenu.ESCOLHAS_FINANCEIRO.map((String escolha) {
                      return PopupMenuItem<String>(
                        value: escolha,
                        child: Text(_locale.locale['$escolha']),
                      );
                    }).toList();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: DateFilterBarComponente(
                  key: _dateFilterState,
                  onPressed: () {
                    _streamDashboard = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            
            body: CustomOfflineWidget(child: _dashboard()),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _dashboard() {
    return StreamBuilder<Object>(
      stream: _streamDashboard,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          default:
            if (snapshot.hasError) {
              return Container();
            }
            else if (_financeiroDashboard == null && snapshot.connectionState != ConnectionState.waiting) {
              return SemInformacao();
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: Carregando());
            }

            else {
              return LiquidPullToRefresh(
                key: _refreshIndicatorKey,
                onRefresh: _handleRefresh,
                child: ListView(
                  children: <Widget>[
                    Visibility(
                      visible: _diretivas.diretivasDisponiveis.financeiro.possuiTodasAsContas,
                      child: FadeInUp(2, _saldoTotal())
                    ),
                    Visibility(
                      visible: _diretivas.diretivasDisponiveis.financeiro.possuiContasFinanceiras,
                      child: FadeInUp(3, _cardContasFinanceira())
                    ),
                    Visibility(
                      visible: (_diretivas.diretivasDisponiveis.financeiro.possuiContasAReceber
                        || _diretivas.diretivasDisponiveis.financeiro.possuiContasAPagar
                      ),
                      child: FadeInUp(4, _cardPagarReceber())
                    ),
                    Visibility(
                      visible: (_diretivas.diretivasDisponiveis.financeiro.possuiDRE
                        || _diretivas.diretivasDisponiveis.financeiro.possuiHistorico
                      ),
                      child: FadeInUp(3, _cardDREComparar())
                    ),
                    SizedBox( height: 40,),
                  ],
                ),
              );
            }
        }
      }
    );
  }

  void _escolheOpcao(String escolha) async {
    switch (escolha) {
      case ConstantesOpcoesPopUpMenu.SELECIONAR_CONTAS:
        final bool resultado = await Rotas.vaParaSelecaoContas(context);
        if (resultado == true) {
          _streamDashboard = Stream.fromFuture(_fazRequest());
        }
        // _selecionarTodos();
        break;
      default:
        break;
    }
  }

  Future<dynamic> _fazRequest() async {
    setState(() {
      _financeiroDashboard.clear();
    });
    dynamic requestDashboard = await FinanceiroService().obterDashboard();
    _financeiroDashboard = FinanceiroDashboard.fromJson(requestDashboard);
    return _financeiroDashboard;
  }

  Widget _saldoTotal() {
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    ResponsiveWidgets().init(context,
        referenceHeight: 1920,
        referenceWidth: 1080,
        referenceShortestSide: 360);

    return Stack(
      children: <Widget>[
        SizedBox(
          height: helper.adjustSize(
              value: helper.size.width * 0.03, min: 90, max: 115),
          width: double.infinity,
          child: Container(
            color: Theme.of(context).primaryColor,
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Card(
                        elevation: 7,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TextResponsive(
                                  _locale.locale['SaldoContasSeleciondas'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: helper.adjustSize(
                                      value: helper.size.width * 0.03,
                                      min: 18,
                                      max: 24
                                    )
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),                                  
                                TextResponsive(
                                  Helper().dinheiroFormatter(_financeiroDashboard.saldoTotalContas),
                                  // "R\$ 10.204.235,00",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: helper.adjustSize(
                                      value: helper.size.width * 0.03,
                                      min: 33,
                                      max: 50)),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            final bool resultado = await Rotas.vaParaSelecaoContas(context);
                            if (resultado == true) {
                              _streamDashboard = Stream.fromFuture(_fazRequest());
                            }
                          },
                        )
                      ),
                    ),
                  ],
                )))
      ],
    );
  }

  Widget _cardContasFinanceira() {

    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 15, left: 14, right: 14, bottom: 35),
            child: Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      child: Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                    SizedBox(
                                      width: double.infinity,
                                      height: helper.adjustSize(
                                          value: helper.size.width * 0.03, 
                                          min: 30, 
                                          max: 115),
                                      
                                      child: Container(
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                    Text(
                                    _locale.locale['ContasFinanceiras'],
                                    textAlign: TextAlign.center,
                                    
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: helper.adjustSize(
                                            value: helper.size.width * 0.03,
                                            min: 18,
                                            max: 24)),
                                  ),
                                    ],
                                  ),                                  
                                  SizedBox(
                                    height: 10,
                                  ),
                                  _tabelaContasFinanceira()
                                ],
                              ),
                            ),
                            onTap: () {
                              RotasFinanceiro.vaParaPrevistoRealizado(context);
                            },
                          )),
                    ),
                  ],
                )))
      ],
    );
  }

  Widget _tabelaContasFinanceira() {
    return Table(
      defaultColumnWidth: FlexColumnWidth(1.0),
      border: TableBorder(
        horizontalInside: BorderSide(
          color: Colors.white,
          style: BorderStyle.solid,
          width: 1.0,
        ),
        verticalInside: BorderSide(
          color: Colors.white,
          style: BorderStyle.solid,
          width: 1.0,
        ),
      ),
      children: [
        TableRow(children: [
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "",
                style: TextStyle(fontSize: FontSize.s15,),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _locale.locale['Previsto'],
                style: TextStyle(fontSize: FontSize.s13, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                _locale.locale['Realizado'],
                style: TextStyle(fontSize: FontSize.s13, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.all(9.0),
            )

          )

        ]),

        TableRow(children: [
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _locale.locale['Receber'],
                style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.totalPrevistoReceita),
                style: TextStyle(fontSize: FontSize.s10, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.receitaBruta),
                
                style: TextStyle(fontSize: FontSize.s10, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              padding: EdgeInsets.all(9.0),
            )
            
          )

        ]),

        TableRow(children: [
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _locale.locale['Pagar'],
                style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.totalPrevistoDespesa),
                style: TextStyle(fontSize: FontSize.s10, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.totalRealizadoDespesa),
                style: TextStyle(fontSize: FontSize.s10, fontWeight: FontWeight.bold, color: Colors.red),
              ),
              padding: EdgeInsets.all(9.0),
            )
            
          )

        ]),
       
        TableRow(children: [
          
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Text(
                _locale.locale['Total'],
                style: TextStyle(fontSize: FontSize.s12, fontWeight: FontWeight.bold),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),

          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.totalGeralPrevisto),
                style: TextStyle(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.bold,
                  color: Helper().positivoNegativoDinheiroCor(_financeiroDashboard.totalGeralPrevisto),
                ),
              ),
              padding: EdgeInsets.all(9.0),
            )
          ),
          TableCell(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                Helper().dinheiroFormatter(_financeiroDashboard.totalGeralRealizado),
                style: TextStyle(
                  fontSize: FontSize.s10,
                  fontWeight: FontWeight.bold,
                  color: Helper().positivoNegativoDinheiroCor(_financeiroDashboard.totalGeralRealizado),
                ),
              ),
              padding: EdgeInsets.all(9.0),
            )
            
          )

        ]),

      ],
    );
  } 

  Widget _cardPagarReceber() {
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return Stack(
      children: <Widget>[
        SizedBox(
          height: helper.adjustSize(
              value: helper.size.width * 0.03, min: 90, max: 115),
          width: double.infinity,
          child: Container(
            color: Colors.grey[600],
          ),
        ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: Container(
                width: double.infinity,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Visibility(
                        visible: _diretivas.diretivasDisponiveis.financeiro.possuiContasAReceber,
                        child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _locale.locale['ContasReceber'],
                                  style: TextStyle(
                                      color: Colors.greenAccent[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: helper.adjustSize(
                                          value: helper.size.width * 0.03,
                                          min: 12,
                                          max: 14)),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  Helper().dinheiroFormatter(_financeiroDashboard.contasAReceber),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: helper.adjustSize(
                                          value: helper.size.width * 0.03,
                                          min: 14,
                                          max: 21)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Image.asset(
                                  AssetsImagens.CONTAS_RECEBER,
                                  width: 30,
                                  height: 30,
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            RotasFinanceiro.vaParaContasReceber(context, titulo: _locale.locale[TraducaoStringsConstante.ContasReceber]);
                          },
                        ),
                      ),
                      Container(
                        height: 90,
                        child: VerticalDivider(
                          thickness: 2,
                          width: 1,
                        ),
                      ),
                      Visibility(
                        visible: _diretivas.diretivasDisponiveis.financeiro.possuiContasAPagar,
                        child: InkWell(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _locale.locale['ContasPagar'],
                                  style: TextStyle(
                                      color: Colors.redAccent[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: helper.adjustSize(
                                          value: helper.size.width * 0.03,
                                          min: 12,
                                          max: 14)),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  Helper().dinheiroFormatter(_financeiroDashboard.contasAPagar),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: helper.adjustSize(
                                          value: helper.size.width * 0.03,
                                          min: 14,
                                          max: 21)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Image.asset(
                                  AssetsImagens.CONTAS_PAGAR,
                                  width: 30,
                                  height: 30,
                                )
                              ],
                            ),
                          ),
                          onTap: () {
                            RotasFinanceiro.vaParaContasPagar(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ))),
      ],
    );
  }

  Widget _cardDREComparar() {
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(children: <Widget>[
            Visibility(
              visible: _diretivas.diretivasDisponiveis.financeiro.possuiDRE,
              child: Flexible(fit: FlexFit.tight, flex: 2, child: FadeInUp(5, _btnDRE()))
            ),
            Visibility(
              visible: _diretivas.diretivasDisponiveis.financeiro.possuiHistorico,
              child: Flexible(
                fit: FlexFit.tight, flex: 2, child: FadeInUp(6, _btnComparar()),
              ),
            )
          ])
        ],
      ),
    );
  }

  Widget _btnDRE() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 14, bottom: 0, right: 6),
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            child: InkWell(
              onTap: () {
                RotasFinanceiro.vaParaDRE(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _locale.locale['DRE'],
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/app/percentage.png',
                        width: 50,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnComparar() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 6, bottom: 0, right: 14),
      child: Container(
        width: double.infinity,
        child: Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
            child: InkWell(
              onTap: () {
                RotasFinanceiro.vaParaComparativo(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _locale.locale['Historico'],
                      // _locale.locale['Comparar'],
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/app/analytics.png',
                        width: 50,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void onDateFilterStateChanged(DateFilterState state) {
    // TODO: implement onDateFilterStateChanged
  }

}
