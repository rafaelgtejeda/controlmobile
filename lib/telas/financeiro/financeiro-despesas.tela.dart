import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/financeiro/financeiro-dre.modelo.dart';
import 'package:erp/rotas/financeiro.rotas.dart';
import 'package:erp/servicos/financeiro/financeiro.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:provider/provider.dart';

class FinanceiroDespesasTela extends StatefulWidget {
  @override
  FinanceiroDespesasTelaState createState() => FinanceiroDespesasTelaState();
}

class FinanceiroDespesasTelaState extends State<FinanceiroDespesasTela> with SingleTickerProviderStateMixin {
  FinanceiroDREModelo _despesasModelo = new FinanceiroDREModelo();
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamDespesas;
  double _totalDespesas = 0;

  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamDespesas = Stream.fromFuture(_fazRequest());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestDespesas = await FinanceiroService().obterDRE(tipo: 0);
    _despesasModelo = FinanceiroDREModelo.fromJson(requestDespesas);
    double total = 0;
    total += _despesasModelo.despesasFixas;
    total += _despesasModelo.despesasVariaveis;
    total += _despesasModelo.pessoas;
    total += _despesasModelo.impostos;
    setState(() {
      _totalDespesas = total;
    });
    return _despesasModelo;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.Despesas]),
              actions: <Widget>[
                DateFilterButtonComponente(
                  funcao: () async{
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      _dateFilterState.currentState.obtemDatas();
                      _streamDespesas = Stream.fromFuture(_fazRequest());
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
                    _streamDespesas = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder(
                      stream: _streamDespesas,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          default:
                          if (snapshot.hasError) {
                            return Container();
                          }
                          else if (_despesasModelo == null && snapshot.connectionState != ConnectionState.waiting) {
                            return SemInformacao();
                          }
                          else if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: Carregando());
                          }
                          else {
                            return _tabBar();
                          }
                        }
                      }
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _tabBar() {
    return ListView(
      children: <Widget>[

        InkWell(
          onTap: () {
            RotasFinanceiro.vaParaDespesasDetalhes(
              context,
              categoria: CategoriaFinanceiroConstante.DESPESAS_FIXAS,
              titulo: _locate.locale[TraducaoStringsConstante.DespesasFixas]
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.DespesasFixas],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helper().dinheiroFormatter(_despesasModelo.despesasFixas),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        InkWell(
          onTap: () {
            RotasFinanceiro.vaParaDespesasDetalhes(
              context,
              categoria: CategoriaFinanceiroConstante.DESPESAS_VARIAVEIS,
              titulo: _locate.locale[TraducaoStringsConstante.DespesasVariaveis]
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.DespesasVariaveis],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helper().dinheiroFormatter(_despesasModelo.despesasVariaveis),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        InkWell(
          onTap: () {
            RotasFinanceiro.vaParaDespesasDetalhes(
              context,
              categoria: CategoriaFinanceiroConstante.IMPOSTOS,
              titulo: _locate.locale[TraducaoStringsConstante.Impostos]
            );
          },
          child: Padding(
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
                  Helper().dinheiroFormatter(_despesasModelo.impostos),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        InkWell(
          onTap: () {
            RotasFinanceiro.vaParaDespesasDetalhes(
              context,
              categoria: CategoriaFinanceiroConstante.PESSOAS,
              titulo: _locate.locale[TraducaoStringsConstante.Pessoas]
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.Pessoas],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helper().dinheiroFormatter(_despesasModelo.pessoas),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        InkWell(
          onTap: () {
            RotasFinanceiro.vaParaDespesasDetalhes(
              context,
              categoria: CategoriaFinanceiroConstante.MENOS2,
              titulo: _locate.locale[TraducaoStringsConstante.Despesas]
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  _locate.locale[TraducaoStringsConstante.TotalDespesas],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Helper().dinheiroFormatter(_totalDespesas),
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
