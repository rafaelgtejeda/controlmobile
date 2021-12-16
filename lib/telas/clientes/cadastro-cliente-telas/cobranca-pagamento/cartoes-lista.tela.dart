import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/cobranca-pagamento/cartao-editar.modelo.dart';
import 'package:erp/models/cliente/cobranca-pagamento/cartao-grid.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class CartoesListaTela extends StatefulWidget {
  final int parceiroId;
  CartoesListaTela({Key key, this.parceiroId}) : super(key: key);
  @override
  _CartoesListaTelaState createState() => _CartoesListaTelaState();
}

class _CartoesListaTelaState extends State<CartoesListaTela> {
  List<CartaoCreditoGrid> cartoesList = new List<CartaoCreditoGrid>();
  List<int> cartoesSelecionados = new List<int>();
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
  Stream<dynamic> _streamCartoes;

  _CartoesListaTelaState() {
  }

  @override
  void initState() {
    super.initState();
    cartoesList = [];
    parceiro = widget.parceiroId;
    _busca.addListener(_buscaDebounce);
    _locale.iniciaLocalizacao(context);
    _streamCartoes = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamCartoes = Stream.fromFuture(_fazRequest());
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
      cartoesList.clear();
      cartoesSelecionados.clear();
      pesquisa = '';
      _busca.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamCartoes = Stream.fromFuture(_fazRequest());

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
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['CobrancaPagamento']),
              actions: <Widget>[
                cartoesSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: cartoesSelecionados.length == 1
                  ? _locale.locale['DeletarCartaoSelecionadoToolTip']
                  : _locale.locale['DeletarCartoesSelecionadosToolTip'],
                )
                : Container(),
                IconButton(
                  icon: Icon(FontAwesomeIcons.link),
                  iconSize: 25,
                  onPressed: _gerarLinkCartao,
                  tooltip: _locale.locale['GerarLink'],
                ),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroCartao(
                      context,
                      parceiroId: widget.parceiroId,
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        cartoesList.clear();
                        pesquisa = '';
                        _busca.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamCartoes = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale["AdicionarCartao"],
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
                        hintText: _locale.locale["BuscarCartoes"],
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
            body: CustomOfflineWidget(child: _listagemCartoes()),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<dynamic> _fazRequest() async {
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestCartoes = await ClienteService().cobrancaPagamento.cartoesLista(
        skip: _infinite.skipCount,
        search: pesquisa,
        parceiroId: parceiro
      );

      List<CartaoCreditoGrid> listaCartao = new List<CartaoCreditoGrid>();
      requestCartoes.forEach((data) {
        listaCartao.add(CartaoCreditoGrid.fromJson(data));
      });

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      listaCartao = _verificaSelecionado(lista: listaCartao);
      _infinite.novaLista = listaCartao;
      // Adicione a novaLista á lista original
      cartoesList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return cartoesList;
    } else {
      return null;
    }
  }
  
  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (cartoesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (cartoesList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == cartoesList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _cartaoItem(context, index, cartoesList);
        },
        itemCount: cartoesList.length + 1,
      );
    }
  }

  Widget _listagemCartoes() {
    return StreamBuilder(
      stream: _streamCartoes,
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

  Widget _cartaoItem(BuildContext context, int index, List<CartaoCreditoGrid> lista) {
    if (index >= lista.length) {
      return null;
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
                "${_locale.locale['Numero']}: ${lista[index].numero ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Titular']}: ${lista[index].titular ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Bandeira']}: ${lista[index].bandeira ?? ''}",
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
        _selecionarCartao(idCartao: lista[index].id, index: index);
      },
      onLongPress: () {
        _multiplaSelecaoCartoes(idCartao: lista[index].id, index: index);
      }
    );
  }

  _selecionarCartao({int idCartao, int index}) async {
    if (cartoesSelecionados.length == 0) {
      dynamic retorno = await ClienteService().cobrancaPagamento.getCartao(idCartao: idCartao, context: context);
      CartaoCreditoEditar cartaoRetorno = CartaoCreditoEditar.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroCartao(
        context,
        parceiroId: widget.parceiroId,
        cartao: cartaoRetorno
      );

      if (resultado != null && resultado == true) {
        setState(() {
          cartoesList.clear();
          pesquisa = '';
          _busca.clear();
        });
        _infinite.skipCount = 0;
        _infinite.infiniteScrollCompleto = false;
        _streamCartoes = Stream.fromFuture(_fazRequest());
      }
    }
    else {
      _multiplaSelecaoCartoes(idCartao: idCartao, index: index);
    }
  }

  _multiplaSelecaoCartoes({int idCartao, int index}) {
    if (!cartoesSelecionados.contains(idCartao)) {
      cartoesSelecionados.add(idCartao);
      setState(() {
        cartoesList[index].isSelected = true;
      });
    }
    else {
      cartoesSelecionados.remove(idCartao);
      setState(() {
        cartoesList[index].isSelected = false;
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
    if(cartoesSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().cobrancaPagamento.selecionaTodosCartoes(context: context, parceiroId: widget.parceiroId);
      cartoesSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        cartoesSelecionados.add(data);
      });
      setState(() {
        cartoesList.forEach((cartao) {
          cartao.isSelected = true;
        });
      });
    }
    else if(cartoesSelecionados.length <= cartoesList.length) {
      cartoesSelecionados.clear();
      setState(() {
        cartoesList.forEach((cartao) {
          cartao.isSelected = false;
        });
      });
    }
  }

  List<CartaoCreditoGrid> _verificaSelecionado({List<CartaoCreditoGrid> lista}) {
    lista.forEach((cartao) {
      if(cartoesSelecionados.contains(cartao.id)) {
        cartao.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (cartoesSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCartaoConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().cobrancaPagamento.deletaCartao(idCartao: cartoesSelecionados[0], context: context);
        _deletarCartoes(resultado);
      }
    }
    else if (cartoesSelecionados.length > 1 && cartoesSelecionados.length < cartoesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCartoesSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().cobrancaPagamento.deletaCartoesLote(idCartoes: cartoesSelecionados, context: context);
        _deletarCartoes(resultado);
      }
    }
    else if (cartoesSelecionados.length == cartoesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCartoesTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().cobrancaPagamento.deletaCartoesLote(idCartoes: cartoesSelecionados, context: context);
        _deletarCartoes(resultado);
      }
    }
  }

  _deletarCartoes(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      setState(() {
        cartoesList.clear();
        cartoesSelecionados.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamCartoes = Stream.fromFuture(_fazRequest());
    }
  }

  _gerarLinkCartao() {
    ClienteService().cobrancaPagamento.getCartaoLink(widget.parceiroId, context: context)
      .then((data) {
        RotasClientes.vaParaCadastroCartaoLink(
          context,
          link: data
        );
      });
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
      cartoesList = [];
    });
    _streamCartoes = Stream.fromFuture(_fazRequest());
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
