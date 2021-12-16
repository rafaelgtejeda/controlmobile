import 'dart:async';
import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/tiles/button-accordion-tile.componente.dart';
import 'package:erp/models/os/atualiza-status-os.modelo.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/accordion.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/models/os/detalhe-os-agendada.modelo.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:intl/intl.dart';
import 'package:latlong/latlong.dart';
import 'package:map_launcher/map_launcher.dart' as map_l;
import 'package:provider/provider.dart';

class AndamentoOrdemServico extends StatefulWidget {

  final int idOS;
  final bool exibeAssistenteNavegacao;

  AndamentoOrdemServico({Key key, this.idOS, this.exibeAssistenteNavegacao}) : super(key: key);
  @override
  _AndamentoOrdemServicoState createState() => _AndamentoOrdemServicoState();
  
}

class _AndamentoOrdemServicoState extends State<AndamentoOrdemServico> {

  Stream<dynamic> _streamOS;

  RequestUtil _requestUtil = new RequestUtil();
  Helper helper = new Helper();

  DateTime dataInicial;
  DateTime dataFinal;
  
  DateTime _dataFinal = DateTime.now();

  String dtInicio, dtFim;

  bool _isLoading = false;
  bool _enabled = true;

  bool _exibeBotaoAssistenteNavegacao = false;

  int _tecnicoId;

  DetalheOSAgendada detalheOSAgendada = new DetalheOSAgendada();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  LocalizacaoServico _locale = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();

  @override
  void initState() {
    super.initState();
    if(widget.exibeAssistenteNavegacao != null && widget.exibeAssistenteNavegacao) {
      _exibeBotaoAssistenteNavegacao = true;
    }
    _streamOS = Stream.fromFuture(_fazRequest());
    _locale.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _adquireTecnicoId();
  }

  Future<dynamic> _fazRequest() async {
    dynamic resultado = await OrdemServicoService().osAgendadaDetalhes(idOS: widget.idOS);
    detalheOSAgendada = DetalheOSAgendada.fromJson(resultado);

    if (detalheOSAgendada.statusTecnico == StatusOrdemDeServico.ACaminho) {
      setState(() {
        _exibeBotaoAssistenteNavegacao = true;
      });
    }

    return detalheOSAgendada;

  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    MediaQueryData _mq = MediaQuery.of(context);

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return new Future(() => true);
      },
      child: LocalizacaoWidget(
        exibirOffline: true,
        child: StreamBuilder(
          builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text(_locale.locale[TraducaoStringsConstante.EmAndamento], style: TextStyle(fontSize: 16)),
                actions: <Widget>[],
              ),
              body: SingleChildScrollView(
                child: StreamBuilder(
                  stream: _streamOS,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Center(child: Carregando()),
                          ],
                        );
                        break;
                      default:
                        if (snapshot.hasError )
                          return Center(
                            child: Container(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Algo deu Errado. ${snapshot.requireData}'),
                            )),
                          );
                        else
                          return Column(
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                height: _mq.size.height * 0.35,
                                child: mapa(context, detalheOSAgendada.latitude, detalheOSAgendada.longitude),
                              ),
                              Container(child: Center(child: _btnAtenderChamado(context, detalheOSAgendada))),
                              Visibility(
                                visible: _exibeBotaoAssistenteNavegacao,
                                child: Container(child: Center(child: _btnAssitenteDeNavegacao(context)))
                              ),
                              Container(child: Center(child: accordionDetalheOS(context, detalheOSAgendada))),
                              Container(child: Center(child: accordionContratoOS(context, detalheOSAgendada))),
                              Container(child: Center(child: accordionEquipamentosOS(context, detalheOSAgendada))),
                              Visibility(
                                visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarMaterialServico,
                                child: Container(child: Center(child: ButtonAccordionTiles(
                                  titulo: _locale.locale[TraducaoStringsConstante.MateriaisServicos],
                                  funcao: () {
                                    _vaParaMateriaisServicos(detalheOSAgendada.osId);
                                  }
                                ))),
                              ),
                            ],
                          );
                    }
                  },
                ),
              ),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            );
          }
        ),
      ),
    );

  }

  Widget _btnAtenderChamado(BuildContext context, DetalheOSAgendada osItem) {
    MediaQueryData _mq = MediaQuery.of(context);
    return Container(
      child: Center(
        child: Padding(
            padding: EdgeInsets.symmetric(),
            child: Material(
              elevation: 4,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () async {
                  bool resultado = false;
                  if(osItem.statusOS == StatusOrdemDeServico.EmExecucao) {
                    switch(osItem.statusTecnico) {
                      case StatusOrdemDeServico.Agendado:
                        AtualizaStatusOSModelo statusOS = new AtualizaStatusOSModelo();
                        String statusOSJson;

                        statusOS.osId = osItem.osId;
                        statusOS.osxTecId = osItem.id;
                        statusOS.tecnicoId = _tecnicoId;
                        statusOS.status = StatusOrdemDeServico.ACaminho;

                        statusOSJson = json.encode(statusOS.toJson());
                        if(!await _requestUtil.verificaOnline()) {
                          bool retorno = await OrdemServicoService().atualizarStatusOS(context: context, osStatus: statusOSJson);
                          if (retorno == true) {
                            setState(() {
                              osItem.statusTecnico = StatusOrdemDeServico.ACaminho;
                              _exibeBotaoAssistenteNavegacao = true;
                            });
                          }
                        }
                        else {
                          Response retorno = await OrdemServicoService().atualizarStatusOS(context: context, osStatus: statusOSJson);
                          if (retorno.statusCode == 200) {
                            setState(() {
                              osItem.statusTecnico = StatusOrdemDeServico.ACaminho;
                              _exibeBotaoAssistenteNavegacao = true;
                            });

                            final abrirAssistente = await AlertaComponente().showAlertaConfirmacao(
                              context: context,
                              mensagem: _locale.locale[TraducaoStringsConstante.DesejaAbrirAssistenteNavegacao]
                            );

                            if (abrirAssistente) {
                              _abreAssistenteNavegacao(osItem);
                            }
                          }
                        }


                        break;
                      case StatusOrdemDeServico.ACaminho:
                        AtualizaStatusOSModelo statusOS = new AtualizaStatusOSModelo();
                        String statusOSJson;

                        statusOS.osId = osItem.osId;
                        statusOS.osxTecId = osItem.id;
                        statusOS.tecnicoId = _tecnicoId;
                        statusOS.status = StatusOrdemDeServico.Atendendo;

                        statusOSJson = json.encode(statusOS.toJson());
                        if(!await _requestUtil.verificaOnline()) {
                          bool retorno = await OrdemServicoService().atualizarStatusOS(context: context, osStatus: statusOSJson);

                          if (retorno == true) {
                            setState(() {
                              osItem.statusTecnico = StatusOrdemDeServico.Atendendo;
                            });
                            resultado = true;
                          }
                        }
                        else {
                          Response retorno = await OrdemServicoService().atualizarStatusOS(context: context, osStatus: statusOSJson);

                          if (retorno.statusCode == 200) {
                            setState(() {
                              osItem.statusTecnico = StatusOrdemDeServico.Atendendo;
                            });
                            resultado = true;
                          }
                        }
                        break;
                      case StatusOrdemDeServico.Atendendo:
                        resultado = true;
                        break;
                    }
                  }
                  if (resultado == true) {
                    OrdemServicoRotas.vaParaChecklistsOS(context, detalheOSAgendada.osId, osXTecId: widget.idOS);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  width: _mq.size.width * 0.8,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: _isLoading
                      ? SpinKitWave(
                          color: Colors.white,
                          size: FontSize.s13
                        )
                      : Text(
                          _textoStatus(osItem.statusTecnico).toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: FontSize.s13,
                            fontWeight: FontWeight.bold,                     
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _btnAssitenteDeNavegacao(BuildContext context) {
    MediaQueryData _mq = MediaQuery.of(context);
    return Container(
      child: Center(
        child: Padding(
            padding: EdgeInsets.all(16),
            child: Material(
              elevation: 4,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () async {
                   _abreAssistenteNavegacao(detalheOSAgendada);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  width: _mq.size.width * 0.8,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    _locale.locale[TraducaoStringsConstante.AssistenteNavegacao].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )),
      ),
    );
  }

  _abreAssistenteNavegacao(DetalheOSAgendada osItem) async {
    String endereco = '${osItem.endereco}, ${osItem.numero}, ${osItem.cidade}, ${osItem.estado}';

    OrdemServicoRotas.vaParaAndamentoMapaOrdemServico(context, osItem.latitude, osItem.longitude, endereco);
  }

  Future<void> _adquireTecnicoId() async {
    int tecnico;
    tecnico = await _requestUtil.obterIdUsuarioSharedPreferences();
    _tecnicoId = tecnico;
  }

  String _textoStatus(int status) {
    switch(status) {
      case StatusOrdemDeServico.Agendado:
        return _locale.locale[TraducaoStringsConstante.Encaminhar];
        break;
      case StatusOrdemDeServico.ACaminho:
        return _locale.locale[TraducaoStringsConstante.Executar];
        break;
      case StatusOrdemDeServico.Atendendo:
        return _locale.locale[TraducaoStringsConstante.Executar];
        break;
      default:
        return _locale.locale[TraducaoStringsConstante.Encaminhar];
        break;
    }
  }

  Widget mapa(BuildContext context, latitude, longitude) {
    return new FlutterMap(
      options: new MapOptions(
        center: new LatLng(latitude, longitude),
        zoom: 13.0,
         plugins: [
          MarkerClusterPlugin(),
        ],
      ),
      layers: [
        new TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c']
        ),
        new MarkerLayerOptions(
          markers: [
            new Marker(
              width: 61.0,
              height: 61.0,
              point: new LatLng(latitude, longitude),
              builder: (ctx) =>
              new Container(
                child: Image.asset('images/app/pin.png', width: 61.0, height: 61.0,),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget _btnTracarRota(BuildContext context, locale, latitude, longitude, detalheOSAgendada) {

  //   String endereco = '${detalheOSAgendada.endereco}, ${detalheOSAgendada.numero}, ${detalheOSAgendada.cidade}, ${detalheOSAgendada.estado}';
    
  //   return Container(
      
  //     child: Positioned(
  //       left: 30,
  //       bottom: 8,
  //       right: 30,
  //       child: ButtonComponente(texto: '${_locale.locale[TraducaoStringsConstante.TracarMelhorRota]}', 
  //                               imagemCaminho: AssetsIconApp.ArrowLeftWhite, 
  //                               backgroundColor: Colors.white, 
  //                               textColor: Colors.black45,
  //                               somenteTexto: true,
  //                               somenteIcone: false,
  //                               ladoIcone: 'Direito',
  //                               funcao: () {

  //                                 String endereco = '${detalheOSAgendada.endereco}, ${detalheOSAgendada.numero}, ${detalheOSAgendada.cidade}, ${detalheOSAgendada.estado}';

  //                                 OrdemServicoRotas.vaParaAndamentoMapaOrdemServico(context, 
  //                                                                                   detalheOSAgendada.latitude, 
  //                                                                                   detalheOSAgendada.longitude, 
  //                                                                                   endereco);
  //                               })
  //     ),
  //     );
  // }

  Accordion accordionDetalheOS(BuildContext context, detalheOSAgendada){
    return Accordion(
      titulo: <Widget>[
        Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: 
            Text(_locale.locale[TraducaoStringsConstante.DetalhesOrdemServico]),
          ),
        )
      ],
      itens: <Widget>[
      _osDetalhes(context, detalheOSAgendada)
      ],
    );
  }

  Widget _osDetalhes(context, detalheOSAgendada){
    return Column(
       children: <Widget>[

         FadeInUp(1, 
         Container(
           child: Padding(
             padding: const EdgeInsets.only(top:18.0, bottom: 27.0),
             child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[

                                  TextSpan(text:'${detalheOSAgendada.descricaoStatus}.',
                                           style: TextStyle(
                                           fontSize: FontSize.s16,
                                           fontWeight: FontWeight.bold,
                                    )

                                  ),
                                ]
                              )
                            ),
           )
         )
         ),
         
         FadeInUp(2, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Tipo]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16 ,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:'${detalheOSAgendada.descricaoTipo}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(3, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.NumeroOS]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:'${detalheOSAgendada.numeroOS}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(4, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.NomeFantasia]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:'${detalheOSAgendada.nomeFantasiaCliente}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(5, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Cliente]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.nomeCliente}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(6, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Endereco]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:'${detalheOSAgendada.endereco}, ${detalheOSAgendada.numero}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(7, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${detalheOSAgendada.cidade}, ${detalheOSAgendada.estado}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(8, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.CEP]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:helper.cepFormatter(cep: detalheOSAgendada.cep ?? ''),
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(9, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Complemento]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.complemento ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(10, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24, left: 18, bottom: 32),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Descricao]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.descricaoDetalhada ?? 'Sem informação.'}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
         FadeInUp(11, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 14),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.NomeAtendente]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                      ),

                                    TextSpan(text:'${detalheOSAgendada.nomeAtendente}'?? '',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(12, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.DataAtendimento]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                              fontWeight: FontWeight.bold,
                                        )
                                     
                                    ),

                                    TextSpan(text: DateFormat.yMd()
                                                             .add_jm()
                                                             .format(DateTime.parse(detalheOSAgendada.dataAtendimento)).toString() ?? '',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
        //  FadeInUp(13, 
        //  Container(
        //    child: Align(
        //           alignment: Alignment.centerLeft,
        //                 child: Padding(
        //                   padding: const EdgeInsets.only(top: 24.0, left: 18.0, bottom: 10),
        //                   child: RichText(
        //                         text: TextSpan(
        //                           style: DefaultTextStyle.of(context).style,
        //                           children: <TextSpan>[

        //                             TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Cliente]}: ', 
        //                                       style: TextStyle(
        //                                       fontSize: FontSize.s16,
        //                                      fontWeight: FontWeight.bold,
        //                                 )

        //                             ),

        //                             TextSpan(text:'${detalheOSAgendada.codigoCliente ?? ''}',
        //                                      style: TextStyle(
        //                                      fontSize: FontSize.s16,
        //                               )

        //                             ),
        //                           ]
        //                         )
        //                       ),
        //                 ),
        //    )
        //  )
        //  ),

         FadeInUp(13, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Cliente]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.nomeCliente ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(14, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.CodigoCliente]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.codigoCliente ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(15, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Telefone]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.telefoneCliente ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(16, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Celular]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.celularCliente ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(17, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Email]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.emailCliente ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(18, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24.0, left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Contato]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.nomeContato ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(19, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Telefone]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.telefoneContato ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(20, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Celular]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.celularContato ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

         FadeInUp(21, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 30),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Email]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${detalheOSAgendada.emailContato ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),

       ],
    );
  }

  Accordion accordionContratoOS(BuildContext context, detalheOSAgendada){
    return Accordion(
      titulo: <Widget>[
        Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: 
            Text('Contratos'),
          ),
        )
      ],
      itens: <Widget>[
        
        getAccordionOSContrato()

      ],
    );
  }

  Widget getAccordionOSContrato(){
     if(detalheOSAgendada.servicosContrato.length == 0)
     return SemInformacao();
     else
     return ListView.builder(
      shrinkWrap: true,
      itemCount: detalheOSAgendada.servicosContrato.length ?? 0,
      itemBuilder: (BuildContext context, int index) => accordionOSContrato(context, index, detalheOSAgendada)
    );
  }

  Widget accordionOSContrato(context, index, detalheOSAgendada) {

    List<ServicosContrato> servicosContrato = detalheOSAgendada.servicosContrato;

    if(servicosContrato.length == 0)
    return SemInformacao();
    else
    return Container(child: Padding(
      padding: const EdgeInsets.only(left: 20.0, bottom: 10),
      child: FadeInUp(index, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Contrato]}: ${servicosContrato[index].descricao ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
          )
        )
      ),
      
    ));
  }

  Accordion accordionEquipamentosOS(BuildContext context, detalheOSAgendada){
    return Accordion(
      titulo: <Widget>[
        Container(
          child: Align(
            alignment: Alignment.centerLeft,
            child: 
            Text(_locale.locale[TraducaoStringsConstante.Equipamentos]),
          ),
        )
      ],
      itens: <Widget>[
          getAccordionEquipamentosOS()
      ],
    );
  }
  
  Widget getAccordionEquipamentosOS(){
     if(detalheOSAgendada.equipamentos.length == 0)
     return SemInformacao();
     else
     return ListView.builder(
          shrinkWrap: true,
           itemCount: detalheOSAgendada.equipamentos.length ?? 0,
           itemBuilder: (BuildContext context, int index) => accordionOSEquipamentos(context, index, detalheOSAgendada)
        );
  }

  Widget accordionOSEquipamentos(context, index, detalheOSAgendada) {
    
    List<Equipamentos> equipamentos = detalheOSAgendada.equipamentos;
    if(equipamentos.length == 0)
    return SemInformacao();
    else
    return Container(child: Padding(
      padding: const EdgeInsets.only(left: 0.0, bottom: 10),
      child: Column(
        children: <Widget>[
         FadeInUp(index, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Produto]}: ', 
                                        style: TextStyle(
                                        fontSize: FontSize.s16,
                                        fontWeight: FontWeight.bold,
                                      )

                                    ),

                                    TextSpan(text:'${equipamentos[index].descricaoProduto ?? ''}',
                                        style: TextStyle(
                                        fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         FadeInUp(index, 
         Container(
           child: Align(
                  alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 18.0, bottom: 10),
                          child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[

                                    TextSpan(text:'${_locale.locale[TraducaoStringsConstante.Quantidade]}: ', 
                                              style: TextStyle(
                                              fontSize: FontSize.s16,
                                             fontWeight: FontWeight.bold,
                                        )

                                    ),

                                    TextSpan(text:'${equipamentos[index].quantidade ?? ''}',
                                             style: TextStyle(
                                             fontSize: FontSize.s16,
                                      )

                                    ),
                                  ]
                                )
                              ),
                        ),
           )
         )
         ),
         
        ],
      ),
    ));
  }
  
  _vaParaMateriaisServicos(id) async {
     OrdemServicoRotas.vaParaMateriaisServicos(context, osId: id, empresaIdOS: detalheOSAgendada.empresaId);
  }
}
