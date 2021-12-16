
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/os/atualiza-status-os.modelo.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:erp/utils/request.util.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:erp/utils/helper.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/accordion.componente.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:provider/provider.dart';

class GridProximosChamadosTela extends StatefulWidget {

  final DateTime gridOSProximosChamadosData;

  GridProximosChamadosTela({this.gridOSProximosChamadosData});

  @override
  _GridProximosChamadosTelaState createState() => _GridProximosChamadosTelaState();
}

class _GridProximosChamadosTelaState extends State<GridProximosChamadosTela> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  Helper helper = new Helper();
  Stream<dynamic> _streamOS;
  LocalizacaoServico _locate = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
  ScrollController _scrollController = new ScrollController();

  bool _isLoading = false;

  DateTime _dataInicial;

  List<GridOSAgendadaModelo> listaOSAgendada = new List<GridOSAgendadaModelo>();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  RequestUtil _requestUtil = new RequestUtil();
  MediaQueryData _media = MediaQueryData();
  int _tecnicoId;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _adquireTecnicoId();
    _dataInicial = widget.gridOSProximosChamadosData;
    _streamOS = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: '');
        _streamOS = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  Future<dynamic> _fazRequest() async {

    if (!_infinite.infiniteScrollCompleto) {

      dynamic requestOSAgendada = await OrdemServicoService().gridOSAgendada(
        dia: _dataInicial.toString(),
        skip: _infinite.skipCount
      );

      List<GridOSAgendadaModelo> listaGrid = new List<GridOSAgendadaModelo>();

      requestOSAgendada.forEach((data) {
        listaGrid.add(GridOSAgendadaModelo.fromJson(data));
      });

      _infinite.novaLista = listaGrid;
      listaOSAgendada.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      return listaOSAgendada;
    }
    else {

      return null;
      
    }
  }
  
  Future<DateTime>selecionaData(BuildContext context) async {
    final DateTime selecionadoData = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataInicial
    );

    // if (selecionadoData != null && selecionadoData != _dataInicial) {
    if (selecionadoData != null) {
      setState(() {
        _dataInicial = selecionadoData;
        listaOSAgendada.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamOS = Stream.fromFuture(_fazRequest());
    }

  }
  
  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      listaOSAgendada.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamOS = Stream.fromFuture(_fazRequest());
   
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }
  
  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    _media = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return new Future(() => true);
      },
      child: LocalizacaoWidget(
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot){
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text(_locate.locale['OrdemDeServico'].toUpperCase()),
                actions: <Widget>[
                  DateFilterButtonComponente(
                    funcao: () {
                      selecionaData(context);
                    },
                    tooltip: _locate.locale['FiltrarData'],
                    desativarEmOffline: false,
                  ),
                  SizedBox(width: 5),

                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48),
                  child: Column(
                    children: <Widget>[
                      
                      InkWell(
                        onTap: (){ selecionaData(context); },
                        child: Container(
                          height: 48,
                          decoration: myBoxDecoration(),
                          alignment: Alignment.center,
                          child: Text("${DateFormat.yMMMd().format(_dataInicial)} ",
                                        style: TextStyle(color: Theme.of(context).primaryColorLight),
                                        textAlign: TextAlign.center),
                        ),
                      ),
      
                    ],
                  ),
                ),
              ),
              body: _listagemOS(),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            );
          },
        ),
      ),
    );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Algo deu Errado.'),
      ));
      // return SemInformacao();
    }

    // else if (listaOSAgendada.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }

    else if (listaOSAgendada.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return ListView.builder(
        shrinkWrap: true,
        controller: new ScrollController(),
        itemBuilder: (context, index) {
          if (index == listaOSAgendada.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return accordionOSItem(context, index, listaOSAgendada);
        },
        itemCount: listaOSAgendada.length + 1,
      );
    }
  }

  Widget _listagemOS() {
    return StreamBuilder(
      stream: _streamOS,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey, // key if you want to add
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: ListView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
            ],
          ),
        );
      }
    );
  }

  BoxDecoration myBoxDecoration(){
    return BoxDecoration(
     // color: Colors.green,
     border: Border(
       top: BorderSide(
         color: Theme.of(context).dividerColor,
         width: 2,
       )
     )
    );
  }

  Accordion accordionOSItem(BuildContext context, int index, List<GridOSAgendadaModelo> lista){
    if (index >= lista.length) {
      return null;
    }

    return Accordion(
      aberto: false,
      titulo: <Widget>[
          FadeInUp(1, Row(
            children: <Widget>[
              Flexible(
                flex: 1, 
                child: Container(
                  // height: double.maxFinite,
                  height: 48,
                  width: double.maxFinite,
                  color: Helper().corStatusOrdemServico(
                    statusOS: lista[index].statusTecnico,
                    dataDia: widget.gridOSProximosChamadosData,
                    horaFinal: lista[index].horaFim
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 48,
                  width: double.maxFinite,
                )
              ),
              Flexible(
                flex: 10, 
                child: Text(lista[index].horaInicio,
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? FontSize.s21 : FontSize.s15,
                    fontWeight: FontWeight.bold,                            
                  ),
                )
              ),
              Flexible(
                flex: 40,
                child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                         Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Padding(
                                  padding: const EdgeInsets.only(top:10, left: 13,),
                                  child: Text('${lista[index].nomeFantasiaCliente ?? ''}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: FontSize.s16,
                                            fontWeight: FontWeight.bold,                            
                                          ),
                                        ),
                                ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              child: Padding(
                                  padding: const EdgeInsets.only(top:5, left: 13,),
                                  child: Text('${lista[index].endereco ?? ''}, ${lista[index].numero ?? ''}',
                                           style: TextStyle(
                                            fontSize: FontSize.s13,                            
                                          ),
                                         ),
                                ),
                            ),
                          )
                        ],
                      ),
              ),
            ],
          )
         )
        ],
      itens: <Widget>[
         FadeInUp(2, Padding(
           padding: const EdgeInsets.all(18.0),
           child: Row(
             children: <Widget>[
                Flexible(
                flex: 1, 
                child: Container(
                  height: 300,
                  // height: double.maxFinite,
                  width: double.maxFinite,
                  color: Helper().corStatusOrdemServico(
                    statusOS: lista[index].statusTecnico,
                    dataDia: widget.gridOSProximosChamadosData,
                    horaFinal: lista[index].horaFim
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(
                  // height: 48,
                  width: double.maxFinite,
                )
              ),
               Flexible(
                 flex: 30,
                 child: Column(
                   children: <Widget>[
                     _chipStatusOrdemServico(
                       statusOS: lista[index].statusTecnico,
                       dataDia: widget.gridOSProximosChamadosData,
                       horaFinal: lista[index].horaFim
                     ),
                     Row(
                       children: <Widget>[
                         Flexible(
                          flex: 2,
                          child: Align(
                             alignment: Alignment.centerLeft,
                             child: Column(
                               children: <Widget>[
                                Text(
                                  '${_locate.locale['HorarioAgendado']}',
                                  style: TextStyle(
                                    fontSize: FontSize.s14,                                              
                                  )
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('${lista[index].horaInicio} - ${lista[index].horaFim}',
                                        style: TextStyle(
                                               fontSize: _media.size.width > 350 ? FontSize.s21 : FontSize.s15,
                                               fontWeight: FontWeight.bold,                            
                                        )
                                      ),
                                ),
                               ],
                             ),
                           ),
                         ),
                         Visibility(
                           visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarReagendar,
                           child: Flexible(
                            flex: 2,
                            child: Align(
                               alignment: Alignment.centerRight,
                               child: InkWell(
                                 onTap: () async{
                                   final resultado = await OrdemServicoRotas.vaParaOrdemServicoReagendar(context, lista[index]);

                                   if(resultado == true) {
                                     setState(() {
                                       listaOSAgendada.clear();
                                     });
                                      _infinite.skipCount = 0;
                                      _infinite.infiniteScrollCompleto = false;
                                     _streamOS = Stream.fromFuture(_fazRequest());
                                   }
                                 },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                     children: <Widget>[
                                      Image.asset(
                                        'images/app/calendar_blue.png',
                                        height: 36,
                                        width: 36,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Text('${_locate.locale['Reagendar']}',
                                              style: TextStyle(
                                                fontSize: FontSize.s14,                          
                                              )
                                            ),
                                      ),
                                     ],
                                 ),
                                  ),
                               ),
                             ),
                           ),
                         ),
                       ],
                     ),

                     Divider(),

                     Column(
                       children: <Widget>[

                         Align(

                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[

                                      TextSpan(text:'${_locate.locale['NumeroOS']}: ', 
                                                style: TextStyle(
                                                fontSize: FontSize.s18,
                                               
                                          )

                                        ),

                                      TextSpan(text:'${lista[index].numeroOS ?? ''}',
                                               style: TextStyle(
                                               fontSize: FontSize.s18,
                                                fontWeight: FontWeight.bold,
                                        )

                                      ),
                                    ]
                                  )
                                ),
                               ),

                        SizedBox(height: 10),

                         Align(
                           alignment: Alignment.centerLeft,
                           child: Padding(
                             padding: const EdgeInsets.all(0.0),
                             child: Container(
                               child: RichText(
                                 text: TextSpan(
                                   style: DefaultTextStyle.of(context).style,
                                   children: <TextSpan>[
                                     TextSpan(text:'${_locate.locale['Tipo']}: ', 
                                              style: TextStyle(
                                                fontSize: FontSize.s16,
                                                fontWeight: FontWeight.bold,
                                              )
                                      ),
                                     TextSpan(text:'${lista[index].descTipo ?? ''}',
                                              style: TextStyle(fontSize: FontSize.s16)
                                    ),
                                   ]
                                 )
                               ),
                             ),
                           ),
                         ),
                         Align(
                           alignment: Alignment.center,
                           child: Column(
                             children: <Widget>[
                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[

                                      TextSpan(text:'${_locate.locale['NomeFantasia']}: ', 
                                               style: TextStyle(
                                               fontSize: FontSize.s16,
                                               fontWeight: FontWeight.bold
                                              )

                                        ),

                                      TextSpan(text:'${lista[index].nomeFantasiaCliente ?? ''}',
                                               style: TextStyle(
                                               fontSize: FontSize.s16          
                                              )

                                      ),

                                    ]
                                  )
                                ),
                               ),

                               SizedBox(height: 10),

                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(text:'${_locate.locale['Endereco']}: ', 
                                               style: TextStyle(
                                               fontSize: FontSize.s16,
                                               fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(text:'${lista[index].endereco ?? ''}, ${lista[index].numero ?? ''}',
                                               style: TextStyle(
                                               fontSize: FontSize.s16,                                            
                                        )
                                      ),
                                    ]
                                  )
                                ),
                               ),

                               SizedBox(height: 10),

                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(

                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      
                                      TextSpan(text:'${_locate.locale['Bairro']}: ', 
                                               style: TextStyle(
                                               fontSize: FontSize.s16,
                                               fontWeight: FontWeight.bold,
                                        )
                                      ),

                                      TextSpan(text:'${lista[index].bairro ?? ''}',
                                               style: TextStyle(
                                               fontSize: FontSize.s16,                                            
                                        )

                                      ),

                                    ]
                                  )
                                ),
                               ),

                               SizedBox(height: 10),

                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(text:'${_locate.locale['Complemento']}: ', 
                                                style: TextStyle(
                                                fontSize: FontSize.s16,
                                                fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(text:'${lista[index].complemento ?? 'Sem informação'}' ,
                                                style: TextStyle(
                                                fontSize: FontSize.s18          
                                        )
                                      ),
                                    ]
                                  )
                                ),
                               ),
                               
                               SizedBox(height: 10),

                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(text:'${_locate.locale['CidadeEstado'] ?? ''}: ', 
                                                style: TextStyle(
                                                fontSize: FontSize.s16,
                                                fontWeight: FontWeight.bold,
                                        )
                                      ),
                                      TextSpan(text:'${lista[index].cidade ?? ''} - ' ,
                                                style: TextStyle(
                                                fontSize: FontSize.s16          
                                        )
                                      ),
                                      TextSpan(text:'${lista[index].estado ?? ''}' ,
                                                style: TextStyle(
                                                fontSize: FontSize.s16          
                                        )
                                      ),
                                    ]
                                  )
                                ),
                               ),

                               SizedBox(height: 10),
                               
                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: RichText(
                                  text: TextSpan(
                                    style: DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(text:'${_locate.locale['CEP']}: ', 
                                                style: TextStyle(
                                                  fontSize: FontSize.s16,
                                                  fontWeight: FontWeight.bold,
                                                )
                                        ),
                                      TextSpan(text:helper.cepFormatter(cep: lista[index].cep ?? ''),
                                                style: TextStyle(
                                                  fontSize: FontSize.s16,
                                                )
                                      ),
                                    ]
                                  )
                                ),
                               ),
                               SizedBox(height: 20),
                               Align(
                                 alignment: Alignment.center,
                                 child: _visualizarOS(context, lista[index]),
                               ),
                             ],
                           ),
                         )
                       ],
                     )
                   ],
                 ),
               ),
             ],
           ),
          )
         )
        ],
    );
  }

  Chip _chipStatusOrdemServico({DateTime dataDia, String horaFinal, int statusOS}) {
    Chip chip = new Chip(label: Text(''),);
    DateTime dataAtual = DateTime.now();
    int horaFim = int.parse(horaFinal.split(':')[0]);
    int minutoFim = int.parse(horaFinal.split(':')[1]);
    dataDia = DateTime(dataDia.year, dataDia.month, dataDia.day, horaFim, minutoFim, 59, 999, 999);
    if(dataDia.isBefore(dataAtual)) {
      chip = new Chip(
        label: Container(
          width: double.maxFinite,
          child: Texto(_locate.locale[TraducaoStringsConstante.Atrasado], color: Colors.white, textAlign: TextAlign.center)
        ),
        backgroundColor: Colors.redAccent[700],
      );
    }
    else {
      switch (statusOS) {
        case StatusOrdemDeServico.Agendado:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.Agendado], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.greenAccent[700],
          );
          break;
        case StatusOrdemDeServico.ACaminho:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.ACaminho], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.black
          );
          break;
        case StatusOrdemDeServico.Atendendo:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.Atendendo], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.orangeAccent[700]
          );
          break;
        case StatusOrdemDeServico.EmExecucao:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.EmExecucao], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.redAccent[700]
          );
          break;
        case StatusOrdemDeServico.FinalizacaoTecnico:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.Finalizado], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.lightBlueAccent
          );
          break;
        case StatusOrdemDeServico.CancelamentoFinalizacaoTecnico:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto(_locate.locale[TraducaoStringsConstante.CancelamentoDaFinalizacao], color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.redAccent[700]
          );
          break;
        default:
          chip = new Chip(
            label: Container(
              width: double.maxFinite,
              child: Texto('', color: Colors.white, textAlign: TextAlign.center)
            ),
            backgroundColor: Colors.redAccent[700]
          );
          break;
      }
    }
    return chip;
  }

  Future<void> _adquireTecnicoId() async {
    int tecnico;
    tecnico = await _requestUtil.obterIdUsuarioSharedPreferences();
    _tecnicoId = tecnico;
  }

  Widget _visualizarOS(BuildContext context, GridOSAgendadaModelo osItem) {

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
                  bool exibeAssistenteNavegacao = false;
                  if (osItem.statusTecnico == StatusOrdemDeServico.Atendendo) {
                    exibeAssistenteNavegacao = true;
                  }

                  final resultado = await OrdemServicoRotas.vaParaAndamentoOrdemServico(context, osItem.id, exibeAssistenteNavegacao: exibeAssistenteNavegacao);

                  if(resultado) {
                    setState(() {
                      listaOSAgendada.clear();
                    });
                    _infinite.skipCount = 0;
                    _infinite.infiniteScrollCompleto = false;
                    _streamOS = Stream.fromFuture(_fazRequest());
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  child: Text(
                    _locate.locale[TraducaoStringsConstante.Visualizar].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: _media.size.width > 350 ? FontSize.s21 : FontSize.s15,
                      fontSize: FontSize.s13,
                      fontWeight: FontWeight.bold,                     
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
