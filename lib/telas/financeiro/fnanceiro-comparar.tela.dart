import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/financeiro/financeiro-comparativo.modelo.dart';
import 'package:erp/models/financeiro/financeiro-historico-lancamentos.modelo.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/date.util.dart';
import 'package:erp/utils/helper.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinanceiroCompararTela extends StatefulWidget {
  @override
  _FinanceiroCompararTelaState createState() => _FinanceiroCompararTelaState();
}

class _FinanceiroCompararTelaState extends State<FinanceiroCompararTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  FinanceiroHistoricoLancamentosModelo _financeiroHistorico = new FinanceiroHistoricoLancamentosModelo();
  FinanceiroComparativoModelo _financeiroComparativo = new FinanceiroComparativoModelo();
  Stream<dynamic> _streamHistorico;
  Stream<dynamic> _streamComparativo;

  String _mes1Historico = '';
  String _mes2Historico = '';
  String _mes3Historico = '';
  String _mes4Historico = '';

  DateTime agora = DateTime.now();
  DateTime _dataInicial;
  DateTime _dataFinal;

  String _mesAtual;
  String _mesPassado;

  @override
  void initState() { 
    super.initState();
    _inicializaDatas();
    _locate.iniciaLocalizacao(context);
    _streamHistorico = Stream.fromFuture(_fazRequestHistorico());
    _streamComparativo = Stream.fromFuture(_fazRequestComparativo());
  }

  _inicializaDatas() async {
    DateTime agora = DateTime.now();
    _dataInicial = DateTime(agora.year, agora.month, 1);
    _dataFinal = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59, 999, 999);

    int mesAtual = agora.month;
    int mesPassado = DateTime(agora.year, agora.month - 1).month;

    _mesAtual = await DateUtil().retornaMes(mesAtual);
    _mesPassado = await DateUtil().retornaMes(mesPassado);
  }

  @override
  void dispose() { 
    _financeiroHistorico.totalReceitasMes1 = 0;
    _financeiroHistorico.totalReceitasMes2 = 0;
    _financeiroHistorico.totalReceitasMes3 = 0;
    _financeiroHistorico.totalReceitasMes4 = 0;
    _financeiroHistorico.totalDespesasMes1 = 0;
    _financeiroHistorico.totalDespesasMes2 = 0;
    _financeiroHistorico.totalDespesasMes3 = 0;
    _financeiroHistorico.totalDespesasMes4 = 0;
    super.dispose();
  }

  Future<dynamic> _fazRequestHistorico() async {
    dynamic request = await FinanceiroService().obterHistoricoLancamentos(dataInicial: _dataInicial.toString());
    _financeiroHistorico = FinanceiroHistoricoLancamentosModelo.fromJson(request);
    _mes1Historico = await DateUtil().retornaMes(_financeiroHistorico.mes1);
    _mes2Historico = await DateUtil().retornaMes(_financeiroHistorico.mes2);
    _mes3Historico = await DateUtil().retornaMes(_financeiroHistorico.mes3);
    _mes4Historico = await DateUtil().retornaMes(_financeiroHistorico.mes4);
    return _financeiroHistorico;
  }

  Future<dynamic> _fazRequestComparativo() async {
    dynamic request = await FinanceiroService().obterComparativo(
      dataInicial: _dataInicial.toString(), dataFinal: _dataFinal.toString()
    );
    _financeiroComparativo = FinanceiroComparativoModelo.fromJson(request);

    return _financeiroComparativo;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.Historico]),
              actions: [
                DateFilterButtonComponente(
                  funcao: () async {
                    SharedPreferences _prefs = await SharedPreferences.getInstance();
                    String idioma = _prefs.getString(SharedPreference.IDIOMA);
                    showMonthPicker(
                      context: context,
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100),
                      initialDate: _dataFinal,
                      locale: Locale(idioma),
                    ).then((date) {
                      if (date != null) {
                        setState(() {
                          debugPrint(date.toString());
                          _dataInicial = DateTime(date.year, date.month - 1, 1, 23, 59, 59, 999, 999);
                          _dataFinal = date;
                          _atualizaDatas(date);
                          _streamComparativo = Stream.fromFuture(_fazRequestComparativo());                          
                        });
                      }
                    });
                  }
                ),
              ],
            ),
            body: ListView(
              children: <Widget>[
                _historicoReceitasDepesasGrafico(),
                _comparativoMesAnterior(),
              ],
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  _atualizaDatas(DateTime data) async {
    int mesAtual = data.month;
    int mesPassado = DateTime(data.year, data.month - 1).month;

    String mesAtualAtualizado = await DateUtil().retornaMes(mesAtual);
    String mesPassadoAtualizado = await DateUtil().retornaMes(mesPassado);

    setState(() {
      _mesAtual = mesAtualAtualizado;
      _mesPassado = mesPassadoAtualizado;
    });
  }

  double _configuraIntervalosPreDefinidos() {
    double valor = 0;

    if((_financeiroHistorico.totalReceitasMes1 ?? 0) > valor) {
      valor = _financeiroHistorico.totalReceitasMes1;
    }
    if ((_financeiroHistorico.totalReceitasMes2 ?? 0) > valor) {
      valor = _financeiroHistorico.totalReceitasMes2;
    }
    if ((_financeiroHistorico.totalReceitasMes3 ?? 0) > valor) {
      valor = _financeiroHistorico.totalReceitasMes3;
    }
    if ((_financeiroHistorico.totalReceitasMes4 ?? 0) > valor) {
      valor = _financeiroHistorico.totalReceitasMes4;
    }
    if ((_financeiroHistorico.totalDespesasMes1 ?? 0) > valor) {
      valor = _financeiroHistorico.totalDespesasMes1;
    }
    if ((_financeiroHistorico.totalDespesasMes2 ?? 0) > valor) {
      valor = _financeiroHistorico.totalDespesasMes2;
    }
    if ((_financeiroHistorico.totalDespesasMes3 ?? 0) > valor) {
      valor = _financeiroHistorico.totalDespesasMes3;
    }
    if ((_financeiroHistorico.totalDespesasMes4 ?? 0) > valor) {
      valor = _financeiroHistorico.totalDespesasMes4;
    }
    
    if (valor <= 10) {
      return 1;
    }
    else if (valor <= 100) {
      return 10;
    }
    else if (valor <= 500) {
      return 50;
    }
    else if (valor <= 1000) {
      return 100;
    }
    else if (valor <= 5000) {
      return 500;
    }
    else if (valor <= 10000) {
      return 1000;
    }
    else if (valor <= 50000) {
      return 5000;
    }
    else if (valor <= 100000) {
      return 10000;
    }
    else if (valor <= 500000) {
      return 50000;
    }
    else if (valor <= 1000000) {
      return 100000;
    }
    else {
      double divisor = valor / 5;
      return divisor;
    }
  }

  Widget _historicoReceitasDepesasGrafico() {
    return StreamBuilder(
      stream: _streamHistorico,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return Container();
        }
        else if(snapshot.connectionState != ConnectionState.waiting && _financeiroHistorico == null) {
          return SemInformacao();
        }
        else if(snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text(
                        _locate.locale[TraducaoStringsConstante.HistoricoReceitasDespesas],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Carregando(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                _locate.locale[TraducaoStringsConstante.Receitas]
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                _locate.locale[TraducaoStringsConstante.Despesas]
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text(
                        _locate.locale[TraducaoStringsConstante.HistoricoReceitasDespesas],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: BarChart(
                      BarChartData(
                        barTouchData: BarTouchData(
                          enabled: true,
                        ),
                        // gridData: FlGridData(
                        //   show: true,
                        // ),
                        alignment: BarChartAlignment.center,
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            getTitles: (double value) {
                              switch (value.toInt()) {
                                case 0:
                                  return _mes1Historico;
                                case 1:
                                  return _mes2Historico;
                                case 2:
                                  return _mes3Historico;
                                case 3:
                                  return _mes4Historico;
                                  break;
                                default:
                                  return '';
                              }
                            }
                          ),
                          leftTitles: SideTitles(
                            showTitles: true,
                            interval: _configuraIntervalosPreDefinidos(),
                            reservedSize: 40
                          ),
                        ),
                        barGroups: [
                          BarChartGroupData(
                            x: 0,
                            barRods: [
                              BarChartRodData(
                                y: _financeiroHistorico.totalDespesasMes1 ?? 0,
                                color: Colors.red,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              ),
                              BarChartRodData(
                                y: _financeiroHistorico.totalReceitasMes1 ?? 0,
                                color: Colors.green,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              ),
                            ]
                          ),
                          BarChartGroupData(
                            x: 1,
                            barRods: [
                              BarChartRodData(
                                y: _financeiroHistorico.totalDespesasMes2 ?? 0,
                                color: Colors.red,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              ),
                              BarChartRodData(
                                y: _financeiroHistorico.totalReceitasMes2 ?? 0,
                                color: Colors.green,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              )
                            ]
                          ),
                          BarChartGroupData(
                            x: 2,
                            barRods: [
                              BarChartRodData(
                                y: _financeiroHistorico.totalDespesasMes3 ?? 0,
                                color: Colors.red,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              ),
                              BarChartRodData(
                                y: _financeiroHistorico.totalReceitasMes3 ?? 0,
                                color: Colors.green,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              )
                            ]
                          ),
                          BarChartGroupData(
                            x: 3,
                            barRods: [
                              BarChartRodData(
                                y: _financeiroHistorico.totalDespesasMes4 ?? 0,
                                color: Colors.red,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              ),
                              BarChartRodData(
                                y: _financeiroHistorico.totalReceitasMes4 ?? 0,
                                color: Colors.green,
                                borderRadius: const BorderRadius.all(Radius.zero),
                                width: 30
                              )
                            ]
                          ),
                        ],
                      ),
                      swapAnimationDuration: Duration(milliseconds: 500),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.green,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                _locate.locale[TraducaoStringsConstante.Receitas]
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                _locate.locale[TraducaoStringsConstante.Despesas]
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  Widget _comparativoMesAnterior() {
    return StreamBuilder(
      stream: _streamComparativo,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return Container();
        }
        else if(snapshot.connectionState != ConnectionState.waiting && _financeiroHistorico == null) {
          return SemInformacao();
        }
        else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Column(
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text(
                        _locate.locale[TraducaoStringsConstante.ComparativoMesAnterior],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Table(
                      columnWidths: {
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.Tipo],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _mesAtual,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _mesPassado,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Receitas
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.Receitas],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalReceitaMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalReceitaMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Despesas Fixas
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.DespesasFixas],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesasFixasMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesasFixasMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Despesas Variáveis
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.DespesasVariaveis],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesasVariaveisMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesasVariaveisMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Pessoas
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.Pessoas],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalPessoasMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalPessoasMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Impostos
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.Impostos],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalImpostosMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalImpostosMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Total de Despesas
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.TotalDespesas],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesaMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalDespesaMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Total Geral
                        TableRow(
                          children: [
                            TableCell(
                              child: Container(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  _locate.locale[TraducaoStringsConstante.TotalGeral],
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalGeralMesAtual ?? 0),
                                  style: TextStyle(
                                    color: Helper().positivoNegativoDinheiroCor(_financeiroComparativo.totalGeralMesAtual),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                            TableCell(
                              child: Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  Helper().dinheiroFormatter(_financeiroComparativo.totalGeralMesPassado ?? 0),
                                  style: TextStyle(
                                    color: Helper().positivoNegativoDinheiroCor(_financeiroComparativo.totalGeralMesPassado),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    );
  }
}
