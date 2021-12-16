import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/tiles/button-accordion-tile.componente.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/servicos/ordem-servico/material-servico.servicos.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/buttons/edit-button.componente.dart';
import 'package:erp/compartilhados/componentes/buttons/remove-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';

class CadastroMateriaisServicosTela extends StatefulWidget {
  
  final int osId;
  const CadastroMateriaisServicosTela({Key key, this.osId}) : super(key: key);
  
  @override
  _CadastroMateriaisServicosTelaState createState() => _CadastroMateriaisServicosTelaState();

}

class _CadastroMateriaisServicosTelaState extends State<CadastroMateriaisServicosTela> {
  
  LocalizacaoServico _locale = new LocalizacaoServico();
         List<MaterialServico> msLista = [];

      Stream<dynamic> _streamMS;

        String pesquisa = '';
          Helper helper = new Helper();

                                 InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
                           ScrollController _scrollController = new ScrollController();

                  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  int osID;
  double totalCobrar = 0;
        double total = 0;
     bool isSelected = false;

  final oCcy = new NumberFormat("#,##0.00", "pt");

  _CadastroMateriaisServicosTelaState(){
     // _streamMS = Stream.fromFuture(_fazRequest());
  }

  @override
  void initState() { 
    super.initState();
     osID = widget.osId;
    _locale.iniciaLocalizacao(context);
    _streamMS = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _streamMS = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }
  
  Future<dynamic> _fazRequest() async {
    
    /// Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {

      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestMS = await MarterialServicoService().getMaterialServico(skip: _infinite.skipCount, osId: osID);

      MaterialServicoGrid msJson = MaterialServicoGrid.fromJson(requestMS);
      
      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      _infinite.novaLista = msJson.lista;

      // Adicione a novaLista á lista original
      msLista.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();

      setState(() {
        totalCobrar = msJson.sumario.totalCobrar;
        total = msJson.sumario.total;
      });
      
      return msLista;

    } else {
      return null;
    }
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      msLista.clear();
      pesquisa = '';
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamMS = Stream.fromFuture(_fazRequest());

    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: const Text('Refresh complete'),
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: () {
            _refreshIndicatorKey.currentState.show();
          }
        )
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: true,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Container(
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                title: Text(_locale.locale['Materiais'].toUpperCase()),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: _btnAddMateriaisServicos(osID)
                ),
              ),
              ),
              body: SlidingUpPanel(

                maxHeight: 212,
         
                panel: Column(
                  children: <Widget>[
                    
                    Container(
                      child: Column(
                      children: <Widget>[

                        SizedBox(height: 12.0,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 30,
                              height: 5,
                              decoration: BoxDecoration(
                              color: Colors.grey[300],
                                borderRadius: BorderRadius.all(Radius.circular(12.0))
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 0.0,),

                        Padding(
                          padding: const EdgeInsets.only(top: 15, left: 20, bottom: 0, right: 20),
                          child: Column(
                            children: <Widget>[

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  
                                  Align(alignment: Alignment.centerLeft, child: Padding(
                                    padding: const EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["TotalCobrar"]}:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                   )
                                  ),

                                  Align(alignment: Alignment.centerRight, child: Padding(
                                    padding: const EdgeInsets.only(bottom:8.0), child: Text('R\$ ${oCcy.format(totalCobrar)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                   )
                                  ),

                                ],
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  
                                  Align(alignment: Alignment.centerLeft, child: Padding(
                                    padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["Total"]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                   )
                                  ),

                                  Align(alignment: Alignment.centerRight, child: Padding(
                                    padding: const EdgeInsets.only(bottom:8.0), child: Text('R\$ ${oCcy.format(total)}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                   )
                                  ),

                                ],
                              ),

                            ],
                          ),
                        )

                      ],
                    ),
                    ),

                    FadeInUp(3, _btnContinue(_locale.locale)),

                  ],
                ),
                body: Container(child: _getMateriaisServicos()) 
                  ,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _btnAddMateriaisServicos(osId){
    return ButtonAccordionTiles(
            titulo: _locale.locale['SelecionarMateriaisServicos'],
            funcao: () { 
              OrdemServicoRotas.vaParaSelecionMateriaisServicos(context);
            }
          );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (msLista.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (msLista.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        controller: new ScrollController(),
        separatorBuilder: (context,index)=>Divider(),
        itemBuilder: (context, index) {
          if (index == msLista.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _listaMS(context, index, msLista, _locale.locale);
        },
        itemCount: msLista.length + 1,
      );
    }
  }

  Widget _getMateriaisServicos(){

    return StreamBuilder(
      stream: _streamMS,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: ListView(
            controller: _scrollController,
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }

  Widget _listaMS(BuildContext context, index, List<MaterialServico> msLista, locale) {

    if (index >= msLista.length) {
      return null;
    }
    
    return GestureDetector(
        onLongPress: toggleSelection,
        child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom:0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FadeInUp(index, 
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10.0, bottom: 8),
                        child: Align(
                               alignment: Alignment.centerLeft,
                                                  child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(text:'${msLista[index].descricao ?? ''}',
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
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                                    
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        
                                        Align(alignment: Alignment.centerLeft, child: Padding(
                                            padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["Quantidade"]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                          )
                                        ),

                                        Align(alignment: Alignment.centerRight, child: Padding(
                                            padding: const EdgeInsets.only(bottom:8.0), child: Text(' ${msLista[index].quantidade ?? ''}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                          )
                                        ),

                                      ],
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        
                                        Align(alignment: Alignment.centerLeft, child: Padding(
                                            padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["Total"]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                          )
                                        ),

                                        Align(alignment: Alignment.centerRight, child: Padding(
                                            padding: const EdgeInsets.only(bottom:8.0), child: Text('R\$ ${oCcy.format(total)}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                          )
                                        ),

                                      ],
                                    ),

                                    
                          ],
                        ),
                                
                                
                      ),
                    )
                    ),

                  ],
                ),
              )),
            
          ],
        ),
        
      ),
    );
  }

  Widget _btnContinue(locale){
    return ButtonComponente(
            texto: '${locale['AdicionarLista']}', 
            imagemCaminho: AssetsIconApp.ArrowLeftWhite, 
            backgroundColor: Colors.green, 
            textColor: Colors.white,
            somenteTexto: true,
            somenteIcone: false,
            ladoIcone: 'Direito',
            funcao: () {}
          );
  }

  void toggleSelection() {

    setState(() {

      if (isSelected) {
        isSelected = true;
      } else {
        isSelected = false;
      }

    });
  }

}
