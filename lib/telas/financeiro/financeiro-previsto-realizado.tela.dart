import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/financeiro/financeiro-previsto-realizado.modelo.dart';
import 'package:erp/rotas/financeiro.rotas.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class FinanceiroPrevistoRealizadoTela extends StatefulWidget {
  @override
  FinanceiroPrevistoRealizadoTelaState createState() => FinanceiroPrevistoRealizadoTelaState();
}

class FinanceiroPrevistoRealizadoTelaState extends State<FinanceiroPrevistoRealizadoTela> {
  FinanceiroPrevistoRealizadoModelo _previstoRealizado = new FinanceiroPrevistoRealizadoModelo();
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamPrevistoRealizado;

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamPrevistoRealizado = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestPrevistoRealizado = await FinanceiroService().obterPrevistoRealizado();
    _previstoRealizado = FinanceiroPrevistoRealizadoModelo.fromJson(requestPrevistoRealizado);
    return _previstoRealizado;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.Previsto] + '-' + _locate.locale[TraducaoStringsConstante.Realizado]),
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      _streamPrevistoRealizado = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locate.locale['FiltrarData'],
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: DateFilterBarComponente(
                  key: _dateFilterState,
                  onPressed: () {
                    _streamPrevistoRealizado = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            // bottomSheet: Container(
            //   color: (_lucroLiquido.isNegative || _lucroLiquido == 0)
            //   ? Color.fromRGBO(255, 0, 0, 0.5)
            //   : Color.fromRGBO(0, 255, 0, 0.5),
            //   height: 48,
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: <Widget>[
            //         Text(
            //           _locate.locale[TraducaoStringsConstante.LUCRO_LIQUIDO_EXERCICIO],
            //           style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         Text(
            //           Helper().dinheiroFormatter(_lucroLiquido),
            //           style: TextStyle(
            //             color: (_lucroLiquido.isNegative || _lucroLiquido == 0)
            //             ? Colors.red[900]
            //             : Colors.green[700],
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            body: CustomOfflineWidget(
              child: StreamBuilder(
                stream: _streamPrevistoRealizado,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    default:
                    if (snapshot.hasError) {
                      return Container();
                    }
                    else if (_previstoRealizado == null && snapshot.connectionState != ConnectionState.waiting) {
                      return SemInformacao();
                    }
                    else if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: Carregando());
                    }
                    else {
                      return ListView(
                        children: <Widget>[
                          _cardReceitas(),
                          _cardDespesas(),
                          _totalPrevisto(),
                          _totalRealizado(),
                        ],
                      );
                    }
                  }
                }
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _cardReceitas() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          RotasFinanceiro.vaParaContasReceber(context, titulo: _locate.locale[TraducaoStringsConstante.Receitas], receita: true);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.Receitas],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              // PieChart(
              //   PieChartData(
              //     startDegreeOffset: 270,
              //     sections: _receitasValoresPieChart(),
              //     centerSpaceRadius: 50,
              //     borderData: FlBorderData(
              //       show: false
              //     )
              //   )
              // ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularPercentIndicator(
                  lineWidth: 10,
                  radius: 120,
                  animation: true,
                  percent: (_previstoRealizado.percentualRealizadoReceita) * 0.01,
                  center: Text(
                    _previstoRealizado.percentualRealizadoReceita.toStringAsFixed(2) + '%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  reverse: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.green,
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Previsto],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Realizado],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Falta],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.totalPrevistoReceita),
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.receitaBruta),
                              style: TextStyle(
                                color: Helper().positivoNegativoDinheiroCor(_previstoRealizado.receitaBruta),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.totalFaltaReceita),
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardDespesas() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          RotasFinanceiro.vaParaDespesas(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.Despesas],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularPercentIndicator(
                  lineWidth: 10,
                  radius: 120,
                  animation: true,
                  percent: (_previstoRealizado.percentualRealizadoDespesa) * 0.01,
                  center: Text(
                    _previstoRealizado.percentualRealizadoDespesa.toStringAsFixed(2) + '%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  reverse: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: Colors.red,
                ),
              ),
              Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Previsto],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Realizado],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              _locate.locale[TraducaoStringsConstante.Falta],
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.totalPrevistoDespesa),
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.totalRealizadoDespesa),
                              style: TextStyle(
                                color: Helper().positivoNegativoDinheiroCor(_previstoRealizado.totalRealizadoDespesa),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              Helper().dinheiroFormatter(_previstoRealizado.totalFaltaDespesa),
                              style: TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // List<PieChartSectionData> _receitasValoresPieChart() {
  //   return [
  //     PieChartSectionData(
  //       value: _previstoRealizado.percentualRealizadoReceita,
  //       radius: 15,
  //       showTitle: false,
  //     ),
  //     PieChartSectionData(
  //       value: 100 - (_previstoRealizado.percentualRealizadoReceita),
  //       radius: 15,
  //       showTitle: false
  //     ),
  //   ];
  // }

  Widget _totalPrevisto() {
    return Container(
      height: 48,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _locate.locale[TraducaoStringsConstante.TotalPrevisto] + ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Helper().dinheiroFormatter(_previstoRealizado.totalGeralPrevisto),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Helper().positivoNegativoDinheiroCor(_previstoRealizado.totalGeralPrevisto),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRealizado() {
    return Container(
      height: 48,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _locate.locale[TraducaoStringsConstante.TotalRealizado] + ':',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Helper().dinheiroFormatter(_previstoRealizado.totalGeralRealizado),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Helper().positivoNegativoDinheiroCor(_previstoRealizado.totalGeralRealizado),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
