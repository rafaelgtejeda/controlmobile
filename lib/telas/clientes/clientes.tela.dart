import 'dart:async';
import 'package:dio/dio.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter/material.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/models/cliente/cliente-editar.modelo.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/models/cliente/cliente-grid.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:provider/provider.dart';
import 'package:erp/utils/helper.dart';

class ClientesTela extends StatefulWidget {
  ClientesTela({Key key}) : super(key: key);
  _ClientesTelaState createState() => _ClientesTelaState();
}

class _ClientesTelaState extends State<ClientesTela> {
  List<Cliente> clientesList = new List<Cliente>();
  List<int> clientesSelecionados = new List<int>();
  int contagemRegistros = 0;

  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamClientes;
  Helper helper = new Helper();

  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  @override
  void initState() {
    super.initState();
    clientesList.clear();
    _locale.iniciaLocalizacao(context);
    _streamClientes = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamClientes = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    _atualizarLista();

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
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                // Visibility(
                //   visible: clientesSelecionados.isNotEmpty,
                //   child: IconButton(
                //     icon: Icon(Icons.delete,),
                //     iconSize: 35,
                //     onPressed: _confirmarDeletarSelecao,
                //     tooltip: clientesSelecionados.length == 1
                //       ? _locale.locale['DeletarClienteSelecionadoToolTip']
                //       : _locale.locale['DeletarClientesSelecionadosToolTip'],
                //   )
                // ),

                // AddButtonComponente(
                //   funcao: () async {
                //     final resultado = await RotasClientes.vaParaCadastroCliente(context);

                //     if (resultado != null && resultado == true) {
                //       setState(() {
                //         clientesList.clear();
                //         pesquisa = '';
                //         _busca.clear();
                //       });
                //       _infinite.skipCount = 0;
                //       _infinite.infiniteScrollCompleto = false;
                //       _streamClientes = Stream.fromFuture(_fazRequest());
                //     }
                //   },
                //   tooltip: _locale.locale["AdicionarCliente"],
                // ),

                // PopupMenuButton<String>(
                //   onSelected: _escolheOpcao,
                //   itemBuilder: (BuildContext context) {
                //     return ConstantesOpcoesPopUpMenu.ESCOLHA_SELECIONAR_TODOS.map((String escolha) {
                //       return PopupMenuItem<String>(
                //         value: escolha,
                //         child: Text(_locale.locale['$escolha']),
                //       );
                //     }).toList();
                //   },
                // ),
              ],
              title: Text(_locale.locale["Clientes"].toUpperCase(), style: TextStyle(fontSize: 16)),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locale.locale[TraducaoStringsConstante.BuscarClientes],
                  funcao: () {
                    if (_buscaKey.currentState.alterouBusca()) {
                      _infinite.verificaPesquisaAlterada();
                    }
                    else {
                      _infinite.pesquisaAlterada = false;
                    }
                    setState(() {
                      clientesList.clear();
                      clientesSelecionados.clear();
                    });
                    _infinite.restart();
                    _streamClientes = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: _listagemClientes(),
            floatingActionButton: FloatingActionButton(
              onPressed: _addCliente,
              child: Icon(Icons.add),
              tooltip: _locale.locale[TraducaoStringsConstante.AdicionarCliente],
            ),
            bottomNavigationBar: BottomAppBar(
              child: _isOnline
              ? _registrosBar()
              : Container(
                height: 80,
                child: ListView(
                  children: <Widget>[
                    _registrosBar(),
                    OfflineMessageWidget()
                  ],
                ),
              ),
              color: Theme.of(context).primaryColor,
            ),
          );
        }
      ),
    );
  }

  _addCliente() async {
    final resultado = await RotasClientes.vaParaCadastroCliente(context, clienteRapido: false);

    if (resultado != null && resultado == true) {
      _atualizarLista();
    }
  }

  Widget _registrosBar() {
    return Container(
      height: 40,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Center(
              child: Text(
                "${_locale.locale['Registros']}: $contagemRegistros",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _fazRequest() async {
    
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      int empresaId = await RequestUtil().obterIdEmpresaShared();
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      // dynamic requestCliente = await ClienteService().clientesLista(skip: _infinite.skipCount, search: pesquisa);

      // Cliente clientesJson = Cliente.fromJson(requestCliente);
      List<Cliente> clientesJson = await Cliente()
        .select().empresaId.equals(empresaId).and.startBlock
          .nome_razaosocial.contains(_buscaKey.currentState?.pesquisa ?? '')
          .or.nomeFantasia.contains(_buscaKey.currentState?.pesquisa ?? '')
          .or.cnpJCPF.contains(_buscaKey.currentState?.pesquisa ?? '')
        .endBlock
        .page((_infinite.skipCount + 1), Request.TAKE).toList();
      
      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      clientesJson = _verificaSelecionado(lista: clientesJson);
      _infinite.novaLista = clientesJson;
      // Adicione a novaLista á lista original
      clientesList.addAll(clientesJson);

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      _contadorRegistros(await Cliente().select().empresaId.equals(empresaId).and.startBlock
        .nome_razaosocial.contains(_buscaKey.currentState?.pesquisa ?? '')
        .or.nomeFantasia.contains(_buscaKey.currentState?.pesquisa ?? '')
        .or.cnpJCPF.contains(_buscaKey.currentState?.pesquisa ?? '')
        .endBlock
        .toCount());
      return clientesList;
    } else {
      return null;
    }
  }

  Widget _childStreamLista({
    AsyncSnapshot snapshot, List lista, Widget snapshotError, Widget waiting, Widget emptyNotWaiting, Widget doneSuccess
  }) {
    if (snapshot.hasError) {
      return snapshotError;
    }

    else if (lista.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return waiting;
    }

    else if (lista.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return emptyNotWaiting;
    }

    else {
      return doneSuccess;
    }

  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return SemInformacao();
    }

    // else if (clientesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }

    else if (clientesList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == clientesList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _clienteItem(context, index, clientesList);
        },
        itemCount: clientesList.length + 1,
      );
    }
  }

  Widget _listagemClientes() {
    return StreamBuilder(
      stream: _streamClientes,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
              // ChildStreamConexao(
              //   context: context, snapshot: snapshot, child: () {_clienteItem(context, index, clientesList)}, infiniteCompleto: _infinite.infiniteScrollCompleto, lista: clientesList
              // ),
            ],
          )
          // child: _childStreamLista(
          //   snapshot: snapshot,
          //   lista: clientesList,
          //   snapshotError: SemInformacao(),
          //   emptyNotWaiting: SemInformacao(),
          //   waiting: Carregando(),
          //   doneSuccess: ListView.separated(
          //     shrinkWrap: true,
          //     controller: _scrollController,
          //     separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
          //     itemBuilder: (context, index) {
          //       if (index == clientesList.length && !_infinite.infiniteScrollCompleto) {
          //         return Container(
          //           height: 100,
          //           width: 100,
          //           alignment: Alignment.center,
          //           child: Carregando(),
          //         );
          //       }
          //       return _clienteItem(context, index, clientesList);
          //     },
          //     itemCount: clientesList.length + 1,
          //   ),
          // )
        );
      },
    );
  }

  Widget _clienteItem(BuildContext context, int index, List<Cliente> lista) {

    if (index >= lista.length) {
      return null;
    }

    int _tipoDocumento;
    if (lista[index].cnpJCPF != null) {
      switch(lista[index].cnpJCPF.length) {
        // CPF
        case 11:
          _tipoDocumento = 1;
          break;
        // CNPJ
        case 14:
          _tipoDocumento = 2;
          break;
        // Documento
        default:
          _tipoDocumento = 0;
          break;
      }
    }
    
    return InkWell(
      child: Container(
        color: lista[index].isSelected ? Colors.blue : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lista[index].nome_razaosocial ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Fantasia']}: " + (lista[index].nomeFantasia ?? ""),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              // Text(
              //   "${_locale.locale['Codigo']}: " + (lista[index].codigoCliente ?? ""),
              //   style: TextStyle(
              //     fontSize: 18,
                  // color: lista[index].isSelected ? Colors.white : Colors.black
              //   ),
              // ),
              _tipoDocumento == 1
                ? Text("${_locale.locale['CPF']}: " + helper.cpfCnpjFormatter(input: lista[index].cnpJCPF ?? ""),
                  style: TextStyle(
                    fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                )
                : _tipoDocumento == 2
                  ? Text("${_locale.locale['CNPJ']}: " + helper.cpfCnpjFormatter(input: lista[index].cnpJCPF ?? ""),
                    style: TextStyle(
                      fontSize: 18,
                      color: lista[index].isSelected ? Colors.white : Colors.black
                    ),
                  )
                  : Text("${_locale.locale['Documento']}: " + helper.cpfCnpjFormatter(input: lista[index].cnpJCPF ?? ""),
                    style: TextStyle(
                      fontSize: 18,
                      color: lista[index].isSelected ? Colors.white : Colors.black
                    ),
                  ),
            ],
          ),
        ),
      ),
      onTap: () {
        _selecionarCliente(idCliente: lista[index].id, index: index);
      },
      // onLongPress: () {
      //   _multiplaSelecaoCliente(idCliente: lista[index].id, index: index);
      // },
    );
  }

  _selecionarCliente({int idCliente, int index}) async {
    // if (clientesSelecionados.length == 0) {

      // dynamic retorno = await ClienteService().getCliente(idCliente: idCliente, context: context);
      // ClienteEditar clienteRetorno = ClienteEditar.fromJson(retorno);

      Cliente cliente = await Cliente().select().id.equals(idCliente).toSingle();

      final resultado = await RotasClientes.vaParaCadastroCliente(context, cliente: cliente, clienteRapido: false);

      if (resultado != null && resultado == true) {
        _atualizarLista();
      }
    // }
    // else {
    //   _multiplaSelecaoCliente(idCliente: idCliente, index: index);
    // }
  }

  _atualizarLista() {
    setState(() {
      clientesList.clear();
      clientesSelecionados.clear();
      _buscaKey.currentState.clearBusca();
    });
    _infinite.restart();
    _streamClientes = Stream.fromFuture(_fazRequest());
  }

  _multiplaSelecaoCliente({int idCliente, int index}) {
    if (!clientesSelecionados.contains(idCliente)) {
      clientesSelecionados.add(idCliente);
      setState(() {
        clientesList[index].isSelected = true;
      });
    }
    else {
      clientesSelecionados.remove(idCliente);
      setState(() {
        clientesList[index].isSelected = false;
      });
    }
  }

  void _escolheOpcao(String escolha) {
    switch (escolha) {
      case ConstantesOpcoesPopUpMenu.SELECIONAR_TODOS:
        _selecionarTodos();
        break;
      // case ConstantesOpcoesPopUpMenu.DELETAR_TODOS:
      //   // _selecionarTodos();
      //   break;
      default:
        break;
    }
  }

  _selecionarTodos() async {
    if(clientesSelecionados.length == 0) {
      // dynamic requestSelecionarTodos = await ClienteService().selecionaTodosClientes(context: context);
      List<Cliente> requestSelecionarTodos = await Cliente().select(columnsToSelect: ['id']).toList();
      clientesSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        clientesSelecionados.add(data.id);
      });
      setState(() {
        clientesList.forEach((cliente) {
          cliente.isSelected = true;
        });
      });
    }
    else if(clientesSelecionados.length <= contagemRegistros) {
      clientesSelecionados.clear();
      setState(() {
        clientesList.forEach((cliente) {
          cliente.isSelected = false;
        });
      });
    }
  }

  List<Cliente> _verificaSelecionado({List<Cliente> lista}) {
    lista.forEach((cliente) {
      if(clientesSelecionados.contains(cliente.id)) {
        cliente.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (clientesSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarClienteConfirmacao']);
      if (deletar == true) {
        var resultado = await Cliente().select().id.equals(clientesSelecionados[0]).delete();
        _deletarClientes(resultado.success);
      }
    }
    else if (clientesSelecionados.length > 1 && clientesSelecionados.length < contagemRegistros) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarClientesSelecionadosConfirmacao']);
      if (deletar == true) {
        List<bool> resultados = new List<bool>();
        clientesSelecionados.forEach((element) async {
          var resultado = await Cliente().select().id.equals(element).delete();
          resultados.add(resultado.success);
        });
        _deletarClientes(resultados.every((element) => element = true));
      }
    }
    else if (clientesSelecionados.length == contagemRegistros) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarClientesTodosConfirmacao']);
      if (deletar == true) {
        List<bool> resultados = new List<bool>();
        clientesSelecionados.forEach((element) async {
          var resultado = await Cliente().select().id.equals(element).delete();
          resultados.add(resultado.success);
        });
        _deletarClientes(resultados.every((element) => element = true));
      }
    }
  }

  _deletarClientes(bool resultado) {
    // Tratar Deletes Offline
    if(resultado) {
      _atualizarLista();
      // setState(() {
      //   clientesList.clear();
      //   clientesSelecionados.clear();
      //   pesquisa = '';
      //   _busca.clear();
      // });
      // _infinite.skipCount = 0;
      // _infinite.infiniteScrollCompleto = false;
      // _streamClientes = Stream.fromFuture(_fazRequest());
    }
    else {}
  }

  _contadorRegistros(int registros) {
    setState(() {
      contagemRegistros = registros;
    });
  }
}
