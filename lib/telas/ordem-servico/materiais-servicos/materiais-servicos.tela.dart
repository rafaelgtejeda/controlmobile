import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/telas/ordem-servico/materiais-servicos/seleciona-materiais.tela.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/servicos/produto/produto.servicos.dart';
// import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/servicos/ordem-servico/material-servico.servicos.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/buttons/remove-button.componente.dart';
import 'package:erp/compartilhados/componentes/buttons/edit-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MateriaisServicosTela extends StatefulWidget {
  
  final int osId;
  final int empresaIdOS;
  const MateriaisServicosTela({Key key, this.osId, this.empresaIdOS}) : super(key: key);

  @override
  _MateriaisServicosTelaState createState() => _MateriaisServicosTelaState();
}

class _MateriaisServicosTelaState extends State<MateriaisServicosTela> {
  
  LocalizacaoServico _locale = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();
   List<MaterialServico> _produtosList = new List<MaterialServico>();
   List<int> materiaisServicosSelecionados = new List<int>();
   Sumario _sumario = new Sumario();
                 var retorno = new MaterialServico();
     
             String pesquisa = '';
              Stream<dynamic> _streamMS;
                        Timer _debounce;

          Helper helper = new Helper();

                                 InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
                           ScrollController _scrollController = new ScrollController();
                                        FocusNode _focusBusca = new FocusNode();
                  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  int osID;
  double totalCobrar = 0;
        double total = 0;
     bool isSelected = false;

  final oCcy = new NumberFormat("#,##0.00", "pt");

  _MateriaisServicosTelaState(){
      // _streamMS = Stream.fromFuture(_fazRequest());
  }

  @override
  void initState() { 
    super.initState();
     osID = widget.osId;
    _locale.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _streamMS = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamMS = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }
  
  Future<dynamic> _fazRequest() async {
    
    if (!_infinite.infiniteScrollCompleto) {
      
      dynamic requestProdutos = await MarterialServicoService().getMaterialServico(
        skip: _infinite.skipCount,
        osId: widget.osId
      );

      MaterialServicoGrid resultado = MaterialServicoGrid.fromJson(requestProdutos);
      _infinite.novaLista = resultado.lista;
      _produtosList.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      _sumario = resultado.sumario;
      setState(() {
        total = _sumario.total;
        totalCobrar = _sumario.totalCobrar;
      });
      
      return _produtosList;
    }
    else {
      return null;
    }
    
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      _produtosList.clear();
      materiaisServicosSelecionados.clear();
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
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      exibirOffline: true,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: Text(_locale.locale['Materiais'].toUpperCase()),
            bottom: PreferredSize(
              preferredSize: _diretivas.diretivasDisponiveis.ordemServico.possuiAdicionarMaterialServico
              ? Size.fromHeight(91)
              : Size.fromHeight(0),
              child: Visibility(
                visible: _diretivas.diretivasDisponiveis.ordemServico.possuiAdicionarMaterialServico,
                child: Container(
                  color: Theme.of(context).cardColor,
                  child: _btnAddMateriaisServicos(osID)
                ),
              ),
            ),
            ),
            body: _getMateriaisServicos(),
            bottomNavigationBar: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarValorMaterialServico
            ? BottomAppBar(
              child: _isOnline
                ? _totalBar()
                : Container(
                  height: 120,
                  child: ListView(
                    children: <Widget>[
                      _totalBar(),
                      OfflineMessageWidget()
                    ],
                  ),
                ),
            )
            : null,
          );
        },
      ),
    );
  }

  Widget _totalBar() {
    return Container(
      height: 80,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          
          Container(

            child: Column(
            children: <Widget>[

              SizedBox(height: 4.0,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 0,
                    height: 5,
                    decoration: BoxDecoration(
                    color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, bottom: 0, right: 20),
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
                          padding: const EdgeInsets.only(bottom:8.0),
                          child: Text(
                            helper.dinheiroFormatter(totalCobrar),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                          ),
                          )
                        ),

                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        
                        Align(alignment: Alignment.centerLeft, child: Text('${_locale.locale["Total"]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
                        ),

                        Align(alignment: Alignment.centerRight, child: Text(
                          helper.dinheiroFormatter(total),
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))
                        ),

                      ],
                      
                    ),

                  ],

                ),

              )

            ],

          ),

          ),

        ],
      ),
    );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (_produtosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (_produtosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == _produtosList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _listaMS(context, index, _produtosList);
        },
        itemCount: _produtosList.length + 1,
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

  Widget _cobrarChip(bool cobrar) {
    if (cobrar == true) {
      return Chip(
        label: Texto(_locale.locale['Cobrar'], color: Colors.white),
        backgroundColor: Colors.deepOrange[800],
      );
    }
    else{
      return Chip(
        label: Texto(_locale.locale['NaoCobrar'], color: Colors.white),
        backgroundColor: Colors.blue[600],
      );
    }
  }

  MaterialServicoSave _converteItem(MaterialServico item) {
    MaterialServicoSave materialServico = new MaterialServicoSave();
    materialServico.id = item.id;
    materialServico.cobrar = item.cobrar;
    materialServico.locacao = item.locacao;
    materialServico.unidadeMedida = item.codigoUnidade;
    materialServico.descricao = item.descricao;
    materialServico.produtoId = item.produtoId;
    materialServico.produtoTipo = item.produtoTipo;
    materialServico.quantidade = item.quantidade;
    materialServico.valor = item.valor;
    return materialServico;
  }

  Widget _listaMS(BuildContext context, index, List<MaterialServico> msLista) {

    if (index >= msLista.length) {
      return null;
    }

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: _diretivas.diretivasDisponiveis.ordemServico.possuiDeletarMaterialServico ? 0.25 : 0,
      child: InkWell(
        onTap: () async {
          if (_diretivas.diretivasDisponiveis.ordemServico.possuiEditarMaterialServico) {
            final result = await OrdemServicoRotas.vaParaSelecionMateriaisServicos(
              context, osId: osID, materialServico: _converteItem(msLista[index]), empresaIdOS: widget.empresaIdOS
            );
            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => SelecionaMateriaisServicosTela(osId: osID,))
            // );
            if (result  != null || result == true) {
              setState((){
                _produtosList.clear();
              }); 
              _infinite.skipCount = 0;
              _infinite.infiniteScrollCompleto = false;
              _streamMS = Stream.fromFuture(_fazRequest());
              // setState(() {});
            }
            // else {
            //   _streamMS = Stream.fromFuture(_fazRequest());
            //   setState(() {});
              
            // }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom:0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FadeInUp(index, 
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10.0, bottom: 8, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(child: Texto(msLista[index].descricao ?? '', fontSize: FontSize.s16)),
                            _cobrarChip(msLista[index].cobrar),
                          ],
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
                                    padding: const EdgeInsets.only(bottom:8.0), child: Text(msLista[index].quantidade.toInt().toString(), style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                  )
                                ),

                              ],
                            ),

                            Visibility(
                              visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarValorMaterialServico,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  
                                  Align(alignment: Alignment.centerLeft, child: Padding(
                                      padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["Valor"]} ${msLista[index].codigoUnidade}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                    )
                                  ),

                                  Align(alignment: Alignment.centerRight, child: Padding(
                                      padding: const EdgeInsets.only(bottom:8.0),
                                      child: Text(
                                        helper.dinheiroFormatter(msLista[index].valor),
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                                      ),
                                    )
                                  ),

                                ],
                              ),
                            ),

                            Visibility(
                              visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarValorMaterialServico,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  
                                  Align(alignment: Alignment.centerLeft, child: Padding(
                                      padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale["Total"]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                    )
                                  ),

                                  Align(alignment: Alignment.centerRight, child: Padding(
                                      padding: const EdgeInsets.only(bottom:8.0),
                                      child: Text(
                                        helper.dinheiroFormatter(msLista[index].valorTotal),
                                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                                      ),
                                    )
                                  ),

                                ],
                              ),
                            ),

                          ],

                        ),
                                
                                
                      ),
                    )

                    ),

                  ],
                ),
              )
            ),
            
          ],
        ),
      ),
        
        secondaryActions: <Widget>[
          
          _diretivas.diretivasDisponiveis.ordemServico.possuiDeletarMaterialServico
          ? IconSlideAction(
            caption: 'Remover',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () {
                _confirmarDeletarMateriaisServico(msLista[index].id);
            },
          )
          : Container(),

        ],

    );

  }

   _confirmarDeletarMateriaisServico(idMaterialServico) async {

     bool deletar = false;

     print(idMaterialServico);

      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarMateriaisServicosConfirmacao']);

      if (deletar == true) {
        // Tratar Deletes Offline

        Response resultado = await MarterialServicoService().deletaMaterialServico(idMaterialServico:  idMaterialServico, context: context);
        
        //_deletarClientes(resultado);

        if (resultado.statusCode == 200) {
          setState((){
            _produtosList.clear();
          }); 
          _infinite.skipCount = 0;
          _infinite.infiniteScrollCompleto = false;
          _streamMS = Stream.fromFuture(_fazRequest());
        }

      }
   }

  _selecionar({int idMS, int index}) {

    if (materiaisServicosSelecionados.length == 0) {
      // Código para o que fazer apenas com clique (geralmente Edição)

      // dynamic retorno = await ClienteService().getClienteTeste(idCliente: idCliente, context: context);
      // ClienteEditar clienteRetorno = ClienteEditar.fromJson(retorno);

      // final resultado = await RotasClientes.vaParaCadastroCliente(context, cliente: clienteRetorno);

      // if (resultado != null && resultado == true) {
      //   setState(() {
      //     clientesList.clear();
      //     pesquisa = '';
      //     _busca.clear();
      //   });
      //   _infinite.skipCount = 0;
      //   _infinite.infiniteScrollCompleto = false;
      //   _streamClientes = Stream.fromFuture(_fazRequest());
      // }
    }
    else {

      _multiplaSelecao(idMS: idMS, index: index);

    }

  }

  _multiplaSelecao({int index, int idMS}) {

    if (!materiaisServicosSelecionados.contains(idMS)) {
      materiaisServicosSelecionados.add(idMS);
      setState(() {
        _produtosList[index].isSelected = true;
      });
    }
    else {
      materiaisServicosSelecionados.remove(idMS);
      setState(() {
        _produtosList[index].isSelected = false;
      });
    }

  }

  Widget _btnAddMateriaisServicos(osId){
    return  ButtonComponente(
      texto: '${_locale.locale['AdicionarMateriaisServicos']}', 
      imagemCaminho: AssetsIconApp.ArrowLeftWhite, 
      backgroundColor: Colors.green, 
      textColor: Colors.white,
      somenteTexto: true,
      somenteIcone: false,
      ladoIcone: 'Direito',
      funcao: () async {
        final result = await OrdemServicoRotas.vaParaSelecionMateriaisServicos(
          context, osId: osID, empresaIdOS: widget.empresaIdOS
        );
        // final result = await Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => SelecionaMateriaisServicosTela(osId: osID,))
        // );
        if (result  != null || result == true) {
          setState((){
            _produtosList.clear();
          }); 
          _infinite.skipCount = 0;
          _infinite.infiniteScrollCompleto = false;
          _streamMS = Stream.fromFuture(_fazRequest());
          // setState(() {});
        }
        // else {
        //   _streamMS = Stream.fromFuture(_fazRequest());
        //   setState(() {});
          
        // }
      }
    );
  }

}
