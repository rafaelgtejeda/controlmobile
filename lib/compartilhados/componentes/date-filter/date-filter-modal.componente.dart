import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateFilterModalComponente extends StatefulWidget {
  @override
  _DateFilterModalComponenteState createState() => _DateFilterModalComponenteState();
}

class _DateFilterModalComponenteState extends State<DateFilterModalComponente> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  DateTime hoje = DateTime.now();
  DateTime _dataInicial = DateTime.now();
  DateTime _dataFinal = DateTime.now();

  MediaQueryData _media = MediaQueryData();

  LocalizacaoServico _locate = new LocalizacaoServico();

  Future<Null>selecionaDataInicial(BuildContext context) async {
    final DateTime selecionadoInicial = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataInicial
    );

    if (selecionadoInicial != null && selecionadoInicial != _dataInicial) {
      setState(() {
        _dataInicial = selecionadoInicial;
      });
    }
  }

  Future<Null>selecionaDataFinal(BuildContext context) async {
    DateTime selecionadoFinal = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataFinal
    );

    if (selecionadoFinal != null && selecionadoFinal != _dataFinal) {
      setState(() {
        selecionadoFinal = new DateTime(
          selecionadoFinal.year, selecionadoFinal.month, selecionadoFinal.day,
          23, 59, 59, 999, 999
        );
        _dataFinal = selecionadoFinal;
      });
    }
  }

  _carregaDatas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataInicial = DateTime.parse(prefs.getString(SharedPreference.DATA_INICIAL));
      _dataFinal = DateTime.parse(prefs.getString(SharedPreference.DATA_FINAL));
    });
  }

  _filtrarData() async {
    if (_dataFinal.isBefore(_dataInicial)) {
      _showSnackBar(_locate.locale[TraducaoStringsConstante.PeriodoDataInvalido]);
    }
    else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(SharedPreference.DATA_INICIAL, _dataInicial.toString());
      prefs.setString(SharedPreference.DATA_FINAL, _dataFinal.toString());
      Navigator.pop(context, true);
    }
  }

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
    _carregaDatas();
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            // chama o scafold
            child: 
              Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  title: Text(
                    '${_locate.locale[TraducaoStringsConstante.SelecaoPeriodoData]}'.toUpperCase(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${_locate.locale[TraducaoStringsConstante.SelecionePeriodoAplicadoTelas]}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Divider(thickness: 2, height: 30,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              _dataIconeComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.DataInicial]}',
                                data: DateFormat.yMd().format(DateTime.parse(_dataInicial.toString())),
                                funcao: () {selecionaDataInicial(context);}
                              ),
                              _dataIconeComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.DataFinal]}',
                                data: DateFormat.yMd().format(DateTime.parse(_dataFinal.toString())),
                                funcao: () {selecionaDataFinal(context);}
                              ),
                            ],
                          ),
                          SizedBox(height: 18,),
                          Container(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Material(
                                elevation: 3,
                                borderRadius: BorderRadius.circular(40),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(40),
                                  onTap: _filtrarData,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
                                    child: Center(
                                      child: Text(
                                        '${_locate.locale[TraducaoStringsConstante.Filtrar]}'.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: FontSize.s13                          
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ),
                          ),
                          Divider(thickness: 2, height: 18,),
                          Text('${_locate.locale[TraducaoStringsConstante.PreDefinidos]}'),
                          SizedBox(height: 30,),
                          Wrap(
                            children: <Widget>[
                              _botaoComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.Hoje]}',
                                funcao: () {
                                  _dataInicial = DateTime(hoje.year, hoje.month, hoje.day);
                                  _dataFinal = DateTime(hoje.year, hoje.month, hoje.day, 23, 59, 59, 999, 999);
                                  _filtrarData();
                                }
                              ),
                              _botaoComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.EstaSemana]}',
                                funcao: () {
                                  DateTime _primeiroDiaSemana = hoje.subtract(Duration(days: hoje.weekday));
                                  DateTime _ultimoDiaSemana = hoje.add(Duration(
                                    days: DateTime.saturday - hoje.weekday
                                  ));
                                  _ultimoDiaSemana = DateTime(
                                    _ultimoDiaSemana.year, _ultimoDiaSemana.month, _ultimoDiaSemana.day,
                                    23, 59, 59, 999, 999
                                  );
                                  _dataInicial = _primeiroDiaSemana;
                                  _dataFinal = _ultimoDiaSemana;
                                  _filtrarData();
                                }
                              ),
                              _botaoComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.MesAtual]}',
                                funcao:() {
                                  DateTime _primeiroDiaMes = DateTime(hoje.year, hoje.month, 1);
                                  DateTime _ultimoDiaMes = DateTime(hoje.year, hoje.month + 1, 0, 23, 59, 59, 999, 999);
                                  _dataInicial = _primeiroDiaMes;
                                  _dataFinal = _ultimoDiaMes;
                                  _filtrarData();
                                }
                              ),
                              _botaoComponent(
                                texto: '${_locate.locale[TraducaoStringsConstante.MesPassado]}',
                                funcao: () {
                                  DateTime _primeiroDiaMesAnterior = DateTime(hoje.year, hoje.month - 1, 1);
                                  DateTime _ultimoDiaMesAnterior = DateTime(
                                    hoje.year, hoje.month, 0, 23, 59, 59, 999, 999
                                  );
                                  _dataInicial = _primeiroDiaMesAnterior;
                                  _dataFinal = _ultimoDiaMesAnterior;
                                  _filtrarData();
                                }
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            )
          );
        }
      ),
    );
  }

  Widget _dataIconeComponent({@required String texto, @required String data, @required Function funcao}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28)
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: funcao,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      
                    ),
                    SizedBox(width: 12,),
                    Text(
                      texto,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 25,),
          Container(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: funcao,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28)
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  data,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botaoComponent({@required String texto, @required Function funcao}) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: funcao,
            child: Container(
              width: _media.size.width > 350 ? 150 : 130,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              child: Center(
                child: Text(
                  texto.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: FontSize.s13             
                  ),
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}
