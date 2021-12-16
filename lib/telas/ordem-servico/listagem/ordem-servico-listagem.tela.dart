
import 'dart:async';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-button.componente.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/app-bar/date-filter/date-filter-bar.componente.dart';
import 'package:erp/models/os/osProximosChamados.modelo.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class OrdemServicoListagemTela extends StatefulWidget {
  OrdemServicoListagemTela({Key key}) : super(key: key);
  @override
  _OrdemServicoListagemTelaState createState() => _OrdemServicoListagemTelaState();
}

class _OrdemServicoListagemTelaState extends State<OrdemServicoListagemTela> {

  Stream<dynamic> _streamProximosChamadosOS;
  LocalizacaoServico _locate = new LocalizacaoServico();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  List<OsProximosChamados> listaChamadosOS = new List<OsProximosChamados>();
  ScrollController _scrollController = new ScrollController();

  MediaQueryData _media = MediaQueryData();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<DateFilterBarComponenteState> _dateFilterState = GlobalKey<DateFilterBarComponenteState>();

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: '');
        _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      listaChamadosOS.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
   
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

  Future<dynamic> _fazRequest() async {

    if (!_infinite.infiniteScrollCompleto) {

      dynamic requestProximosChamadosOS = await OrdemServicoService().gridProximosChamadosListagem(
        skip: _infinite.skipCount
      );

      List<OsProximosChamados> listaGrid = new List<OsProximosChamados>();
      requestProximosChamadosOS.forEach((data) {
        listaGrid.add(OsProximosChamados.fromJson(data));
      });

      _infinite.novaLista = listaGrid;
      listaChamadosOS.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      return listaChamadosOS;
    }
    else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    _media = MediaQuery.of(context);

    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(_locate.locale['OrdemDeServico'].toUpperCase(), style: TextStyle(fontSize: 16)),
            actions: <Widget>[
              
              // AddButtonComponente(
              //   funcao: () {},
              //   tooltip: _locate.locale['AdicionarOrdemDeServico'],
              // ),

              DateFilterButtonComponente(
                funcao: () async{
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                  );
                  if(result == true){
                    _dateFilterState.currentState.obtemDatas();
                    setState(() {
                      listaChamadosOS.clear();
                    });
                    _infinite.skipCount = 0;
                    _infinite.infiniteScrollCompleto = false;
                    _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
                  }
                },
                tooltip: _locate.locale['FiltrarData'],
                desativarEmOffline: false,
              ),
              SizedBox(width: 5),

            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(88),
              child: Column(
                children: <Widget>[
                  DateFilterBarComponente(
                    key: _dateFilterState,
                    onPressed: () {
                      setState(() {
                        listaChamadosOS.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
                    },
                    desativarEmOffline: false,
                  ),

                  Container(
                    height: 46,
                    decoration: myBoxDecoration(),
                    alignment: Alignment.center,
                    child: Text(
                      "${_locate.locale['ProximosChamados']}",
                      style: TextStyle(color: Theme.of(context).primaryColorLight),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
          body: _listagemProximosChamados(),
          bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
        );
      }),
    );

  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      // return SemInformacao();
      return Center(
        child: Container(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Algo deu Errado.'),
        )),
      );
    }

    // else if (listaChamadosOS.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }

    else if (listaChamadosOS.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        key: _scaffoldKey,
        separatorBuilder: (BuildContext context, int index) => Divider( thickness: 2 ),
        itemBuilder: (context, index) {
          if (index == listaChamadosOS.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _osItem(context, index, listaChamadosOS);
        },
        itemCount: listaChamadosOS.length + 1,
      );
    }
  }

  Widget _listagemProximosChamados() {
    return StreamBuilder(
      stream: _streamProximosChamadosOS,
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
      },
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

  Widget _osItem(BuildContext context, int index, List<OsProximosChamados> lista) {

    if (index >= lista.length) {
      return null;
    }

    int count = lista.length;

    // DateFormat.yMMMMd("en_US")
    var hoje = DateFormat.yMd(SharedPreference.IDIOMA).format(new DateTime.now());

    //DateTime.parse(snapshot.data.data['entidade'][index]['data'].toString()).day;
    
    String dia = lista[index].dia;
    String mes = lista[index].mes;
    String ano = lista[index].ano;
    
    String dataOS = DateFormat.yMd(SharedPreference.IDIOMA).format(new DateTime.utc(
        int.parse(ano), 
        int.parse(mes), 
        int.parse(dia)
      )
    );

    if(count == 0 || count == "") {

      return Container(child: Padding(padding: EdgeInsets.all(10), child: Text('Sem dados.')));

    }
    else {
      return FadeInUp(index, Container(
        height: _media.size.width > 350 ? 100 : 75,
        width: double.infinity,
        child: InkWell(
          onTap: () async {
            DateTime hje = DateTime(int.parse(lista[index].ano), 
            int.parse(lista[index].mes), int.parse(lista[index].dia));
            final resultado = await OrdemServicoRotas.vaParaGridOSProximosChamados(
              context, gridOSProximosChamadosData: hje
            );
            if (resultado == true) {
              setState(() {
                listaChamadosOS.clear();
              });
              _infinite.skipCount = 0;
              _infinite.infiniteScrollCompleto = false;
              _streamProximosChamadosOS = Stream.fromFuture(_fazRequest());
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: <Widget>[
                  Container(
                    // width: 65,
                    width: _media.size.width > 350 ? 65 : 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          "${lista[index].dia}",
                          style: TextStyle(
                            // fontSize: 38,
                            fontSize: _media.size.width > 350 ? 38 : 28,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                        Text(
                          "${lista[index].diaDescricao}",
                          style: TextStyle(
                            fontSize: _media.size.width > 350 ? 12 : 10,
                            
                          ),
                        )
                      ],
                    ),
                  ),
                  // SizedBox(
                  //   width: 30,
                  // ),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "${lista[index].mesDescricao}",
                        style: TextStyle(
                          fontSize: _media.size.width > 350 ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                      Text(
                        "${lista[index].ano}",
                        style: TextStyle(
                          fontSize: _media.size.width > 350 ? 12 : 10,
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    child: Center(
                      child: Text(
                        "${lista[index].saldoDiario}",
                        style: TextStyle(fontSize: _media.size.width > 350 ? 24 : 18,
                                          color: hoje == dataOS.toString()
                                          ? Colors.white
                                          : Colors.grey[900]
                        )
                      ),
                    ),
                    height: _media.size.width > 350 ? 55 : 40,
                    width: _media.size.width > 350 ? 115 : 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: hoje == dataOS.toString()
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
  }

}
