import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/limite-credito/limite-credito-editar.modelo.dart';
import 'package:erp/models/cliente/limite-credito/limite-credito-grid.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class LimiteCreditoListaTela extends StatefulWidget {
  final int parceiroId;
  LimiteCreditoListaTela({Key key, this.parceiroId}) : super(key: key);
  @override
  _LimiteCreditoListaTelaState createState() => _LimiteCreditoListaTelaState();
}

class _LimiteCreditoListaTelaState extends State<LimiteCreditoListaTela> {
  List<Lista> limitesList = new List<Lista>();
  List<int> limitesSelecionados = new List<int>();
  double contagemLimiteProprio = 0;
  double contagemLimiteTerceiro = 0;
  double contagemLimiteConsumido = 0;
  double contagemLimiteRestante = 0;
  ScrollController _scrollController = new ScrollController();
  TextEditingController _busca = new TextEditingController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  FocusNode _focusBusca = new FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Helper helper = new Helper();
  String pesquisa = '';
  Timer _debounce;
  int parceiro;
  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamLimites;

  MediaQueryData _media = MediaQueryData();

  _LimiteCreditoListaTelaState() {
  }

  @override
  void initState() {
    super.initState();
    limitesList = [];
    parceiro = widget.parceiroId;
    _busca.addListener(_buscaDebounce);
    _locale.iniciaLocalizacao(context);
    _streamLimites = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamLimites = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _busca.removeListener(_buscaDebounce);
    _busca.dispose();
    _focusBusca.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      limitesList.clear();
      limitesSelecionados.clear();
      pesquisa = '';
      _busca.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamLimites = Stream.fromFuture(_fazRequest());

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
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['LimiteCredito']),
              actions: <Widget>[
                limitesSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: limitesSelecionados.length == 1
                  ? _locale.locale['DeletarLimiteSelecionadoToolTip']
                  : _locale.locale['DeletarLimitesSelecionadosToolTip'],
                )
                : Container(),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroLimiteCredito(
                      context,
                      parceiroId: parceiro
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        limitesList.clear();
                        pesquisa = '';
                        _busca.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamLimites = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale["AdicionarLimite"],
                ),
                PopupMenuButton<String>(
                  onSelected: _escolheOpcao,
                  itemBuilder: (BuildContext context) {
                    return ConstantesOpcoesPopUpMenu.ESCOLHA_SELECIONAR_TODOS.map((String escolha) {
                      return PopupMenuItem<String>(
                        value: escolha,
                        child: Text(_locale.locale['$escolha']),
                      );
                    }).toList();
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      focusNode: _focusBusca,
                      textInputAction: TextInputAction.none,
                      onSubmitted: (_) {
                        _focusBusca.unfocus();
                      },
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.text,
                      controller: _busca,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _locale.locale["BuscarLimites"],
                        hintStyle: TextStyle(color: Colors.white),
                        suffixIcon: IconButton(
                          icon: (pesquisa == '')
                            ? Icon(Icons.search, color: Colors.white)
                            : Icon(Icons.clear, color: Colors.white),
                          onPressed: () {
                            if (pesquisa.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) => _busca.clear());
                            }
                          }
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: CustomOfflineWidget(child: _listagemLimites()),
            bottomNavigationBar: _isOnline
              ? _limitesBar()
              : Container(
                height: 100,
                child: ListView(
                  children: <Widget>[
                    _limitesBar(),
                    OfflineMessageWidget()
                  ],
                ),
              ),
          );
        }
      ),
    );
  }

  Widget _limitesBar() {
    return BottomAppBar(
      child: Container(
        height: 60,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${_locale.locale['LimiteProprio']}: ${Helper().dinheiroFormatter(contagemLimiteProprio)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _media.size.width > 350 ? 13 * _media.textScaleFactor : 9 * _media.textScaleFactor
                    ),
                  ),
                  Text(
                    "${_locale.locale['LimiteConsumido']}: ${Helper().dinheiroFormatter(contagemLimiteConsumido)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _media.size.width > 350 ? 13 * _media.textScaleFactor : 9 * _media.textScaleFactor
                    ),
                  ),
                ],
              ),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${_locale.locale['LimiteTerceiro']}: ${Helper().dinheiroFormatter(contagemLimiteTerceiro)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _media.size.width > 350 ? 13 * _media.textScaleFactor : 9 * _media.textScaleFactor
                      // fontSize: 16
                    ),
                  ),
                  Text(
                    "${_locale.locale['LimiteRestante']}: ${Helper().dinheiroFormatter(contagemLimiteRestante)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _media.size.width > 350 ? 13 * _media.textScaleFactor : 9 * _media.textScaleFactor
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      color: Theme.of(context).primaryColor,
    );
  }

  Future<dynamic> _fazRequest() async {
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestLimites = await ClienteService().limiteCredito.limitesCreditoLista(
        skip: _infinite.skipCount,
        search: pesquisa,
        parceiroId: parceiro
      );
      LimiteCreditoGrid limitesJson = LimiteCreditoGrid.fromJson(requestLimites);
      
      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      limitesJson.lista = _verificaSelecionado(lista: limitesJson.lista);
      _infinite.novaLista = limitesJson.lista;
      // Adicione a novaLista á lista original
      limitesList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      _contadorRegistros(
        limiteProprio: limitesJson.sumario.totalLimiteProprio,
        limiteTerceiro: limitesJson.sumario.totalLimiteTerceiro,
        limiteConsumido: limitesJson.sumario.totalLimiteConsumido,
        limiteRestante: limitesJson.sumario.totalLimiteRestante,
      );
      return limitesList;
    } else {
      return null;
    }
  }

  _contadorRegistros({
    double limiteProprio,
    double limiteTerceiro,
    double limiteConsumido,
    double limiteRestante,
  }) {
    setState(() {
      contagemLimiteProprio = limiteProprio;
      contagemLimiteTerceiro = limiteTerceiro;
      contagemLimiteConsumido = limiteConsumido;
      contagemLimiteRestante = limiteRestante;
    });
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (limitesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (limitesList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == limitesList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _limiteItem(context, index, limitesList);
        },
        itemCount: limitesList.length + 1,
      );
    }
  }

  Widget _listagemLimites() {
    return StreamBuilder(
      stream: _streamLimites,
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

  Widget _limiteItem(BuildContext context, int index, List<Lista> lista) {
    if (index >= lista.length) {
      return null;
    }

    return FadeInUp(
      1,
      InkWell(
        child: Container(
          color: lista[index].isSelected ? Colors.blue : Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${_locale.locale['Codigo']}: ${lista[index].codigo ?? ''}",
                  style: TextStyle(
                    // fontSize: 18,
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
                Text(
                  "${_locale.locale['FormaRecebimento']}: ${lista[index].descricao ?? ''}",
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    // fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
                Text(
                  "${_locale.locale['LimiteProprio']}: ${Helper().dinheiroFormatter(lista[index].limiteProprio) ?? ''}",
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    // fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
                Text(
                  "${_locale.locale['LimiteTerceiro']}: ${Helper().dinheiroFormatter(lista[index].limiteTerceiro) ?? ''}",
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    // fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
                Text(
                  "${_locale.locale['LimiteConsumido']}: ${Helper().dinheiroFormatter(lista[index].limiteConsumido) ?? ''}",
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    // fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
                Text(
                  "${_locale.locale['LimiteRestante']}: ${Helper().dinheiroFormatter(lista[index].limiteRestante) ?? ''}",
                  style: TextStyle(
                    fontSize: _media.size.width > 350 ? 18 * _media.textScaleFactor : 12 * _media.textScaleFactor,
                    // fontSize: 18,
                    color: lista[index].isSelected ? Colors.white : Colors.black
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          _selecionarLimite(idLimite: lista[index].id, index: index);
        },
        onLongPress: () {
          _multiplaSelecaoLimite(idLimite: lista[index].id, index: index);
        },
      ),
    );
  }

  _selecionarLimite({int idLimite, int index}) async {
    if (limitesSelecionados.length == 0) {
      dynamic retorno = await ClienteService().limiteCredito.getLimiteCredito(idLimite: idLimite, context: context);
      LimiteCreditoEditarGet limiteRetorno = LimiteCreditoEditarGet.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroLimiteCredito(
        context,
        parceiroId: widget.parceiroId,
        limite: limiteRetorno
      );

      if (resultado != null && resultado == true) {
        setState(() {
          limitesList.clear();
          pesquisa = '';
          _busca.clear();
        });
        _infinite.skipCount = 0;
        _infinite.infiniteScrollCompleto = false;
        _streamLimites = Stream.fromFuture(_fazRequest());
      }
    }
    else {
      _multiplaSelecaoLimite(idLimite: idLimite, index: index);
    }
  }

  _multiplaSelecaoLimite({int idLimite, int index}) {
    if (!limitesSelecionados.contains(idLimite)) {
      limitesSelecionados.add(idLimite);
      setState(() {
        limitesList[index].isSelected = true;
      });
    }
    else {
      limitesSelecionados.remove(idLimite);
      setState(() {
        limitesList[index].isSelected = false;
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
    if(limitesSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().limiteCredito.selecionaTodosLimites(context: context);
      limitesSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        limitesSelecionados.add(data);
      });
      setState(() {
        limitesList.forEach((limite) {
          limite.isSelected = true;
        });
      });
    }
    else if(limitesSelecionados.length <= limitesList.length) {
      limitesSelecionados.clear();
      setState(() {
        limitesList.forEach((limite) {
          limite.isSelected = false;
        });
      });
    }
  }

  List<Lista> _verificaSelecionado({List<Lista> lista}) {
    lista.forEach((limite) {
      if(limitesSelecionados.contains(limite.id)) {
        limite.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (limitesSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarLimiteConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().limiteCredito.deletaLimite(idLimite: limitesSelecionados[0], context: context);
        _deletarLimites(resultado);
      }
    }
    else if (limitesSelecionados.length > 1 && limitesSelecionados.length < limitesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarLimitesSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().limiteCredito.deletaLimitesLote(idLimites: limitesSelecionados, context: context);
        _deletarLimites(resultado);
      }
    }
    else if (limitesSelecionados.length == limitesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarLimitesTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().limiteCredito.deletaLimitesLote(idLimites: limitesSelecionados, context: context);
        _deletarLimites(resultado);
      }
    }
  }

  _deletarLimites(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      setState(() {
        limitesList.clear();
        limitesSelecionados.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamLimites = Stream.fromFuture(_fazRequest());
    }
  }

  _realizaBusca() {
    if (_busca.text != pesquisa) {
      _infinite.verificaPesquisaAlterada();
    }
    else {
      _infinite.pesquisaAlterada = false;
    }

    pesquisa = _busca.text;
    setState(() {
      limitesList = [];
    });
    _streamLimites = Stream.fromFuture(_fazRequest());
  }

  _buscaDebounce() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_busca.text != pesquisa) {
        _realizaBusca();
      }
    });
  }
}
