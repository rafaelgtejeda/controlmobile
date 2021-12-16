import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/financeiro/financeiro-dre.modelo.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:provider/provider.dart';

class FinanceiroDRETela extends StatefulWidget {
  @override
  FinanceiroDRETelaState createState() => FinanceiroDRETelaState();
}

class FinanceiroDRETelaState extends State<FinanceiroDRETela> with SingleTickerProviderStateMixin {
  FinanceiroDREModelo _dreModelo = new FinanceiroDREModelo();
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamDRE;
  TabController _tabController;
  int _currentIndex = 0;
  double _lucroLiquido = 0;

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamDRE = Stream.fromFuture(_fazRequest());
    _tabController = new TabController(length: 3, vsync: this, initialIndex: _currentIndex);
  }

  @override
  void dispose() { 
    _tabController.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestDRE = await FinanceiroService().obterDRE(tipo: _currentIndex);
    _dreModelo = FinanceiroDREModelo.fromJson(requestDRE);
    setState(() {
      _lucroLiquido = _dreModelo.lucroLiquido;
    });
    return _dreModelo;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.DRE]),
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      _streamDRE = Stream.fromFuture(_fazRequest());
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
                    _streamDRE = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: CustomOfflineWidget(child: _dreBody()),
            bottomNavigationBar: _isOnline 
              ?_lucroLiquidoExercicioBar()
              : Container(
                height: 88,
                child: ListView(
                  children: <Widget>[
                    _lucroLiquidoExercicioBar(),
                    OfflineMessageWidget()
                  ],
                ),
              ),
          );
        }
      ),
    );
  }

  Widget _lucroLiquidoExercicioBar() {
    return Container(
      color: (_lucroLiquido.isNegative || _lucroLiquido == 0)
      ? Color.fromRGBO(255, 0, 0, 0.5)
      : Color.fromRGBO(0, 255, 0, 0.5),
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              _locate.locale[TraducaoStringsConstante.LucroLiquidoExercicio],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              Helper().dinheiroFormatter(_lucroLiquido),
              style: TextStyle(
                color: (_lucroLiquido.isNegative || _lucroLiquido == 0)
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

  Widget _dreBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  color: _currentIndex == 2 ? Theme.of(context).primaryColor : Colors.white,
                  textColor: _currentIndex == 2 ? Colors.white : Colors.black,
                  onPressed: () {
                    _tabController.animateTo(2);
                    setState(() {
                      _currentIndex = 2;
                      _streamDRE = Stream.fromFuture(_fazRequest());
                    });
                  },
                  child: Text(
                    _locate.locale[TraducaoStringsConstante.Todos].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
                FlatButton(
                  color: _currentIndex == 1 ? Theme.of(context).primaryColor : Colors.white,
                  textColor: _currentIndex == 1 ? Colors.white : Colors.black,
                  onPressed: () {
                    _tabController.animateTo(1);
                    setState(() {
                      _currentIndex = 1;
                      _streamDRE = Stream.fromFuture(_fazRequest());
                    });
                  },
                  child: Text(
                    _locate.locale[TraducaoStringsConstante.Realizado].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
                FlatButton(
                  color: _currentIndex == 0 ? Theme.of(context).primaryColor : Colors.white,
                  textColor: _currentIndex == 0 ? Colors.white : Colors.black,
                  onPressed: () {
                    _tabController.animateTo(0);
                    setState(() {
                      _currentIndex = 0;
                      _streamDRE = Stream.fromFuture(_fazRequest());
                    });
                  },
                  child: Text(
                    _locate.locale[TraducaoStringsConstante.Previsto].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _streamDRE,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  default:
                  if (snapshot.hasError) {
                    return Container();
                  }
                  else if (_dreModelo == null && snapshot.connectionState != ConnectionState.waiting) {
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
                        _tabBar(),
                        _tabBar(),
                        _tabBar(),
                      ]
                    );
                  }
                }
              }
            ),
          )
        ],
      ),
    );
  }

  Widget _tabBar() {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.ReceitaBruta],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.receitaBruta),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.receitaBruta),
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.Devolucoes],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.devolucoes),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.devolucoes),
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.Impostos],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.impostos),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.impostos),
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.LucroBruto],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.lucroBruto),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.lucroBruto),
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.TotalDespVariaveis],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.despesasVariaveis),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.despesasVariaveis),
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.LucroOperacional],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.lucroOperacional),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.lucroOperacional),
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.TotalDespFixas],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.despesasFixas),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.despesasFixas),
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                _locate.locale[TraducaoStringsConstante.GastosPessoal],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Helper().dinheiroFormatter(_dreModelo.pessoas),
                style: TextStyle(
                  // color: Helper().positivoNegativoDinheiroCor(_dreModelo.pessoas),
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
