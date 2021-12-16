import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/cliente-selecao/cliente-prospect-cadastro.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ClienteSelecaoComponente extends StatefulWidget {
  ClienteSelecaoComponente({Key key}) : super(key: key);
  _ClienteSelecaoComponenteState createState() => _ClienteSelecaoComponenteState();
}

class _ClienteSelecaoComponenteState extends State<ClienteSelecaoComponente> {
  // List<ClienteLookup> clientesList = new List<ClienteLookup>();
  List<Cliente> clientesList = new List<Cliente>();

  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamClientes;

  Helper helper = new Helper();
  FocusNode _focusBusca = new FocusNode();

  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  _ClienteSelecaoComponenteState() {
  }

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
    _focusBusca.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      clientesList.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamClientes = Stream.fromFuture(_fazRequest());

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
              title: Text(_locale.locale[TraducaoStringsConstante.SelecioneCliente], style: TextStyle(fontSize: 16)),
              bottom: PreferredSize(
                // preferredSize: Size.fromHeight(48),
                preferredSize: Size.fromHeight(84),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Column(
                    children: <Widget>[
                      BuscaComponente(
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
                          });
                          _infinite.restart();
                          _streamClientes = Stream.fromFuture(_fazRequest());
                        },
                      ),
                      _botaoAdicionarItem(
                        // texto: _locale.locale[TraducaoStringsConstante.AdicionarClienteProspect],
                        texto: _locale.locale[TraducaoStringsConstante.AdicionarCliente],
                        funcao: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ClienteProspectCadastroComponente(
                              clienteRapido: true,
                            ))
                          );
                        }
                      )
                    ],
                  ),
                ),
              ),
            ),
            body: _listagemClientes(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<dynamic> _fazRequest() async {
    
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      int empresaId = await RequestUtil().obterIdEmpresaShared();
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      // dynamic requestCliente = await ClienteService().clienteLookupLista(skip: _infinite.skipCount, search: pesquisa);
      // List<Cliente> listaClientes = await Cliente().select().page(_infinite.skipCount, Request.TAKE).toList();

      List<Cliente> listaClientes = await Cliente()
        .select().empresaId.equals(empresaId).and.startBlock
          .nome_razaosocial.contains(_buscaKey.currentState?.pesquisa ?? '')
          .or.nomeFantasia.contains(_buscaKey.currentState?.pesquisa ?? '')
        .endBlock
        .page((_infinite.skipCount + 1), Request.TAKE).toList();

      // List<Cliente> listaClientes = new List<Cliente>();

      // requestCliente.forEach((data) {
      //   listaClientes.add(Cliente.fromJson(data));
      // });

      // ClienteLookup clientesJson = ClienteLookup.fromJson(requestCliente);
      
      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      // _infinite.novaLista = clientesJson.lista;
      _infinite.novaLista = listaClientes;
      // Adicione a novaLista á lista original
      // clientesList.addAll(_infinite.novaLista.cast());
      clientesList.addAll(listaClientes);

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return clientesList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
          return Container();
        }
        
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
            controller: _scrollController,
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }

  Widget _clienteItem(BuildContext context, int index, List<Cliente> lista) {

    if (index >= lista.length) {
      return null;
    }
    
    return InkWell(
      child: Container(
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
                ),
              ),
              Text(
                "${_locale.locale['Fantasia']}: " + (lista[index].nomeFantasia ?? ""),
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _selecionarCliente(cliente: lista[index]);
      },
    );
  }

  _selecionarCliente({Cliente cliente}) async {
    Navigator.pop(context, cliente);
  }

  Widget _botaoAdicionarItem({@required String texto, Function funcao}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 32,
        child: SizedBox.expand(
          child: FlatButton(
            onPressed: funcao,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Texto(
              texto,
              color: Colors.white,
              bold: true,
              fontSize: 18
            )
          ),
        ),
      ),
    );
  }
}
