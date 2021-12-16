import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/venda/comparativo-venda.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/venda/venda.servicos.dart';
import 'package:erp/utils/date.util.dart';
import 'package:provider/provider.dart';

class ComparativoVendaTela extends StatefulWidget {
  @override
  _ComparativoVendaTelaState createState() => _ComparativoVendaTelaState();
}

class _ComparativoVendaTelaState extends State<ComparativoVendaTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  List<ComparativoVendaModelo> _comparativoVendaList = new List<ComparativoVendaModelo>();
  Stream<dynamic> _streamComparativoVenda;
  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();
  List<String> _mesesComparativo = new List<String>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamComparativoVenda = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {
    dynamic request = await VendaService().obterComparativoVendas();
    request.forEach((data) {
      _comparativoVendaList.add(ComparativoVendaModelo.fromJson(data));
    });
    _atribuiMesesStrings();
    return _comparativoVendaList;
  }

  _atribuiMesesStrings() {
    _comparativoVendaList.forEach((data) async {
      String mes = '';
      mes = await DateUtil().retornaMes(data.mes);
      _mesesComparativo.add(mes + '/' + data.ano.toString());
    });
  }



  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.Historico]),
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      setState(() {
                        _comparativoVendaList.clear();
                      });
                      _streamComparativoVenda = Stream.fromFuture(_fazRequest());
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
                    setState(() {
                      _comparativoVendaList.clear();
                    });
                    _streamComparativoVenda = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: CustomOfflineWidget(
              child: ListView(
                children: <Widget>[
                  _historicoReceitasDepesasGrafico(),
                ],
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  double _configuraIntervalosPreDefinidos() {
    double valor = 0;

    _comparativoVendaList.forEach((data) {
      if(data.total > valor) {
        valor = data.total;
      }
    });
    
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
      stream: _streamComparativoVenda,
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return Container();
        }
        else if(snapshot.connectionState != ConnectionState.waiting && _comparativoVendaList == null) {
          return SemInformacao();
        }
        else if (snapshot.connectionState == ConnectionState.waiting) {
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
                        _locate.locale[TraducaoStringsConstante.ComparativoVenda],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    // child: _graficoBarras(),
                    child: Carregando(),
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
                        _locate.locale[TraducaoStringsConstante.ComparativoVenda],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18
                        ),
                      )
                    )
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _comparativoVendaList.length <= 3
                      ? _graficoBarras()
                      : _graficoLinha(),
                  ),
                ],
              ),
            ),
          );
        }
      }
    );
  }

  BarChart _graficoBarras() {
    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          enabled: true,
        ),
        groupsSpace: 70,
        alignment: BarChartAlignment.center,
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
            showTitles: true,
            getTitles: (double value) {
              int valor;
              valor = value.toInt();
              return _mesesComparativo[valor];
            }
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: _configuraIntervalosPreDefinidos(),
          ),
        ),
        barGroups: _buildBars(),
      ),
      swapAnimationDuration: Duration(milliseconds: 500),
    );
  }

  List<BarChartGroupData> _buildBars() {
    List<BarChartGroupData> _lista = new List<BarChartGroupData>();
    for (int i = 0; i < _comparativoVendaList.length; i++) {
      _lista.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              y: _comparativoVendaList[i].total ?? 0,
              color: Colors.green,
              borderRadius: const BorderRadius.all(Radius.zero),
              width: 30
            ),
          ]
        )
      );
    }
    return _lista;
  }

  LineChart _graficoLinha() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: _configuraIntervalosPreDefinidos() / 3,
        ),
        borderData: FlBorderData(show: false),
        backgroundColor: Colors.transparent,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
            textStyle: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold
            ),
            interval: 0.99,
            margin: 60,
            rotateAngle: -80,
            showTitles: true,
            getTitles: (double value) {
              int valor;
              valor = value.toInt();
              return _mesesComparativo[valor];
            }
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: _configuraIntervalosPreDefinidos(),
            reservedSize: 40,
            textStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontSize: 10
            )
          ),
        ),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: _buildLines(),
            isCurved: false,
            colors: [
              Colors.green
            ]
          )
        ],
      ),
      swapAnimationDuration: Duration(milliseconds: 500),
    );
  }

  List<FlSpot> _buildLines() {
    List<FlSpot> _lista = new List<FlSpot>();
    for (int i = 0; i < _comparativoVendaList.length; i++) {
      _lista.add(
        FlSpot(i.toDouble(), _comparativoVendaList[i].total ?? 0)
      );
    }
    return _lista;
  }
}
