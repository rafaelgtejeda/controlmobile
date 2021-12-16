import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:erp/telas/ordem-servico/andamento-ordem-servico/andamento-ordem-servico.tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/compartilhados/componentes/tiles/principal_tile.dart';
import 'package:erp/menu/menu_principal.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/helperFontSize.dart';
import 'package:erp/utils/request.util.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

class PrincipalTela extends StatefulWidget {
  PrincipalTela({Key key}) : super(key: key);

  @override
  _PrincipalTelaState createState() => _PrincipalTelaState();
}

class _PrincipalTelaState extends State<PrincipalTela> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LocalizacaoServico _locate = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  bool _prontoParaSair = false;
  String nomeFantasia = '';
  int empresaID = 0;
  DateTime _tempoSaida = DateTime.now();

  var uuid = Uuid();

  bool usuarioStatus = false;
  bool bloqueioStatus = false;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    
    _locate.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _inicializaDatas();
    //configOneSignal(context);
    chamaOneSignal(context);

  }

  _inicializaDatas() async {
    DateTime agora = DateTime.now();
    DateTime dataInicial = DateTime(agora.year, agora.month, 1);
    DateTime dataFinal =
        DateTime(agora.year, agora.month + 1, 0, 23, 59, 59, 999, 999);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreference.DATA_INICIAL, dataInicial.toString());
    prefs.setString(SharedPreference.DATA_FINAL, dataFinal.toString());
  }

  pegaValorSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nomeFantasia = prefs.getString(SharedPreference.EMPRESA_NOME_FANTASIA);
      empresaID = prefs.getInt(SharedPreference.EMPRESA_ID);
    });
  }

  Future<bool> _verificaUsuarioAutenticado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuario = prefs.getString(SharedPreference.USUARIO_AUTENTICADO);
    if (usuario == 'false' || usuario == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _verificaAplictivoBloqueado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bloqueio = prefs.getString(SharedPreference.BLOQUEAR_APLICATIVO);
    if (bloqueio == 'false' || bloqueio == null) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;
    pegaValorSF();
    return WillPopScope(
      onWillPop: () {
        DateTime now = DateTime.now();
        if (now.isBefore(_tempoSaida) && _prontoParaSair) {
          return SystemNavigator.pop();
        }
        if (!_prontoParaSair) {
          _tempoSaida = DateTime.now().add(Duration(seconds: 2));
          _prontoParaSair = true;
          _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: new Text(_locate.locale[TraducaoStringsConstante.PressioneParaSair]),
            duration: Duration(seconds: 2),
          ));
        }
        Timer(Duration(seconds: 2), () async {
          _prontoParaSair = false;
        });
        return null;
      },
      child: LocalizacaoWidget(
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  elevation: 0,
                  title: Text('$nomeFantasia',
                      style: TextStyle(
                          fontSize:
                              16 * MediaQuery.of(context).textScaleFactor)),
                  centerTitle: false,
                  leading: new IconButton(
                    icon:
                        new Icon(Icons.menu, size: 34), //replace with your icon
                    alignment: Alignment.centerLeft,
                    tooltip: 'Menu',
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    },
                  ),
                ),
                drawer: new MenuPrincipal(
                  atualizaIdioma: () async {
                    await _locate.iniciaLocalizacao(context);
                    setState(() {});
                  },
                ),
                body: SingleChildScrollView(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: helper.adjustSize(
                                  value: helper.size.width * 0.03,
                                  min: 90,
                                  max: 115),
                              width: double.infinity,
                              child: Container(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 20),
                          child: Align(
                              alignment: Alignment.center,
                              child: Column(
                                children: <Widget>[
                                  FadeInUp(1, _cardTodosChamados()),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Wrap(
                                    runSpacing: helper.adjustSize(
                                        value: helper.size.width * 0.0,
                                        min: 0,
                                        max: 10),
                                    spacing: helper.adjustSize(
                                        value: helper.size.width * 0.0,
                                        min: 0,
                                        max: 10),
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    alignment: WrapAlignment.center,
                                    children: _constroiTiles(),
                                    // children: widget.tiles,
                                  ),
                                  SizedBox(
                                    height: 25,
                                  ),
                                ],
                              ))),
                    ],
                  ),
                ),
                bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _constroiTiles() {
    int indexCounter = 0;
    List<Widget> _listaTiles = new List<Widget>();

    if (_diretivas.diretivasDisponiveis.ordemServico.possuiOrdemDeServico) {
      int indice = indexCounter;
      _listaTiles.add(
        FadeInUp(
            2 + indice,
            PrincipalTile(
              img: AssetsImagens.ORDEM_SERVICO,
              texto: _locate.locale[TraducaoStringsConstante.OrdemDeServico],
              funcao: () {
                Rotas.vaParaTabs(context, indice);
              },
            )),
      );
      indexCounter++;
    }

    if (_diretivas.diretivasDisponiveis.cliente.possuiClientes) {
      int indice = indexCounter;
      _listaTiles.add(
        FadeInUp(
            2 + indice,
            PrincipalTile(
              img: AssetsImagens.CLIENTES,
              texto: _locate.locale[TraducaoStringsConstante.Clientes],
              funcao: () {
                Rotas.vaParaTabs(context, indice);
              },
            )),
      );
      indexCounter++;
    }

    if (_diretivas.diretivasDisponiveis.venda.possuiVendas) {
      int indice = indexCounter;
      _listaTiles.add(
        FadeInUp(
            2 + indice,
            PrincipalTile(
              img: AssetsImagens.VENDAS,
              texto: _locate.locale[TraducaoStringsConstante.Vendas],
              funcao: () {
                Rotas.vaParaTabs(context, indice);
              },
            )),
      );
      indexCounter++;
    }

    // FadeInUp(
    //     5,
    //     PrincipalTile(
    //       img: AssetsImagens.ORCAMENTO,
    //       texto: _locate.locate[TraducaoStringsConstante.Orcamento],
    //       funcao: () {},
    //     )),
    // FadeInUp(
    //     6,
    //     PrincipalTile(
    //       img: AssetsImagens.AGENDA,
    //       texto: _locate.locate[TraducaoStringsConstante.Agenda],
    //       funcao: () {},
    //     )),

    if (_diretivas.diretivasDisponiveis.financeiro.possuiFinanceiro) {
      int indice = indexCounter;
      _listaTiles.add(
        FadeInUp(
            2 + indice,
            PrincipalTile(
              desabilitarEmOffline: true,
              img: AssetsImagens.FINANCEIRO,
              texto: _locate.locale[TraducaoStringsConstante.Financeiro],
              funcao: () async {
                List<String> contasIds = new List<String>();
                contasIds = await RequestUtil().obterIdsContasSharedPreferences();
                if (contasIds.isNotEmpty) {
                  Rotas.vaParaTabs(context, indice);
                } else {
                  final bool resultado = await Rotas.vaParaSelecaoContas(context, args: indice);
                  if (resultado == true) {
                    Rotas.vaParaTabs(context, indice);
                  }
                }
              },
            )),
      );
      indexCounter++;
    }

    return _listaTiles;
  }

  Widget _cardTodosChamados() {
    HelperFontSize helper = new HelperFontSize();
    helper.context = context;
    helper.size = MediaQuery.of(context).size;

    return Visibility(
      visible: false,
      child: Container(
        width: double.infinity,
        child: Card(
            elevation: 7,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: InkWell(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    Text(
                      "$empresaID",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: helper.adjustSize(
                              value: helper.size.width * 0.03,
                              min: 35,
                              max: 50)),
                    ),

                    Text(
                      _locate.locale[TraducaoStringsConstante.ChamadosEmAberto],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: helper.adjustSize(
                            value: helper.size.width * 0.03,
                            min: 18,
                            max: 24)),
                    ),

                  ],

                ),

              ),
              onTap: () {},
            )),
      ),
    );
  }

  void configOneSignal(BuildContext context) async {
    
    // Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) async{
      
       var additionalData = result.notification.payload.additionalData;
       // var detalheOS = OSnotificationOS.fromJson(additionalData);

      _verificaUsuarioAutenticado().then((resultado) {
        usuarioStatus = resultado;
      });

      _verificaAplictivoBloqueado().then((resultado) {
        bloqueioStatus = resultado;
      });

      List<String> listaContasEsvaziada = new List<String>();
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setStringList(SharedPreference.CONTAS_SELECIONADAS, listaContasEsvaziada);
        if (usuarioStatus == true) {

          _prefs.setString(SharedPreference.TOKEN, '');

          if (bloqueioStatus == true) {

            final resultado = await Rotas.vaParaConfigurarBloqueio(context, desbloquearApp: true);

            if (resultado == true) {
              
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => AndamentoOrdemServico(idOS: additionalData['entidade']['IdOSXTec'], exibeAssistenteNavegacao: false,))
              );

            }
          } else {

            Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => AndamentoOrdemServico(idOS: additionalData['entidade']['IdOSXTec'], exibeAssistenteNavegacao: false,))
              );

          }
        } else {

          AutenticacaoRotas.vaParaAutenticacaoSplash(context);

        }
      
    });

    OneSignal.shared
             .setInFocusDisplayType(OSNotificationDisplayType.notification);

  }

  void chamaOneSignal(BuildContext context) async {
    
    // Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    
    var additionalData;
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      
      additionalData = result.notification.payload.additionalData;

    });

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      
      // will be called whenever a notification is received
      var data = notification.payload.additionalData;
      print('data principal: $data');
    
    });

    OneSignal.shared
             .setInFocusDisplayType(OSNotificationDisplayType.notification);

    print('notif: $additionalData');

    // return additionalData;

    

  }
  
}
