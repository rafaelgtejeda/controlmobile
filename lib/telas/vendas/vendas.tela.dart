import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/compartilhados/componentes/tiles/principal_tile.dart';
import 'package:erp/models/venda/dashboard-venda.modelo.dart';
import 'package:erp/rotas/vendas.rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/venda/venda.servicos.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/helperFontSize.dart';
import 'package:provider/provider.dart';

class VendasTela extends StatefulWidget {
  VendasTela({Key key}) : super(key: key);
  _VendasTelaState createState() => _VendasTelaState();
}

class _VendasTelaState extends State<VendasTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  Stream<dynamic> _streamDashboard;
  DashboardVendasModelo _vendaDashboard = new DashboardVendasModelo();
  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  bool _isOnline = true;
  
  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _streamDashboard = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {
    setState(() {
      _vendaDashboard.clear();
    });
    dynamic requestDashboard = await VendaService().dashboardVendas();
    _vendaDashboard = DashboardVendasModelo.fromJson(requestDashboard);
    return _vendaDashboard;
  }

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale["Vendas"].toUpperCase(), style: TextStyle(fontSize: 16)),
              backgroundColor: Theme.of(context).primaryColor,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: DateFilterBarComponente(
                  key: _dateFilterState,
                  onPressed: () {
                    _streamDashboard = Stream.fromFuture(_fazRequest());
                  },
                  desativarEmOffline: false,
                ),
              ),
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
                  tooltip: _locate.locale['FiltrarData'],
                  desativarEmOffline: false,
                ),
              ],
            ),
            backgroundColor: Colors.grey[100],
            body: StreamBuilder<Object>(
              stream: _streamDashboard,
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: _diretivas.diretivasDisponiveis.venda.possuiVendasDiarias,
                        child: _cardVendas(
                          titulo: _locate.locale[TraducaoStringsConstante.PedidoVenda],
                          imagem: AssetsImagens.PEDIDO_VENDA,
                          funcao: () {
                            RotasVendas.vaParaPedidoVenda(context);
                          },
                          exibirValor: _diretivas.diretivasDisponiveis.venda.possuiLiberacaoTotalVendasLabel,
                          valor: _vendaDashboard.totalVendas,
                          snapshot: snapshot
                        ),
                      ),

                      Visibility(
                        visible: _diretivas.diretivasDisponiveis.venda.possuiComparativoDeVendas,
                        child: _cardVendas(
                          titulo: _locate.locale[TraducaoStringsConstante.ComparativoVenda],
                          imagem: AssetsImagens.VENDAS,
                          funcao: () {
                            RotasVendas.vaParaComparativoVenda(context);
                          },
                        ),
                      ),
                      
                      Visibility(
                        visible: _diretivas.diretivasDisponiveis.venda.possuiOrcamentosFinalizados,
                        child: _cardVendas(
                          titulo: _locate.locale[TraducaoStringsConstante.Orcamento],
                          imagem: AssetsImagens.ORCAMENTO,
                          funcao: () {
                            RotasVendas.vaParaOrcamentos(context);
                          },
                          exibirValor: _diretivas.diretivasDisponiveis.venda.possuiLiberacaoTotalVendasLabel,
                          valor: _vendaDashboard.totalOrcamento,
                          snapshot: snapshot,
                          desabilitarEmOffline: false
                        ),
                      ),
                      // PrincipalTile(
                      //   img: AssetsImagens.MONEY,
                      //   texto: 'Pedido / Venda',
                      //   funcao: () {}
                      // )
                    ],
                  ),
                );
              }
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _cardVendas({
    String titulo, Function funcao, String imagem, double valor, AsyncSnapshot snapshot,
    bool exibirValor = false, bool desabilitarEmOffline = true
  }) {
    return Container(
      height: 175,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              child: desabilitarEmOffline
              ? CustomOfflineWidget(
                borderRadius: 10,
                disabledIconOnly: true,
                child: _card(
                  titulo: titulo, imagem: imagem, valor: valor, snapshot: snapshot, exibirValor: exibirValor
                ),
              )
              : _card(
                titulo: titulo, imagem: imagem, valor: valor, snapshot: snapshot, exibirValor: exibirValor
              ),
            ),
            onTap: desabilitarEmOffline && !_isOnline ? () {} : funcao,
          )
        ),
      ),
    );
  }

  Widget _card({
    String titulo,String imagem, double valor, AsyncSnapshot snapshot,
    bool exibirValor = false
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              imagem,
              height: 75,
              width: 75,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                fontWeight: FontWeight.w600
              ),
            ),
            exibirValor == true
            ? (valor != null)
              ? (snapshot.connectionState != ConnectionState.waiting)
                ? Text(
                  Helper().dinheiroFormatter(valor),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Helper().positivoNegativoDinheiroCor(valor)
                  ),
                )
                : Carregando()
              : (snapshot != null)
                ? Carregando()
                : Container()
            : Container()
          ],
        ),
      ),
    );
  }
}
