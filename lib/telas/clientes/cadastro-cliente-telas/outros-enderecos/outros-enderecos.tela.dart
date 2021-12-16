import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/outros-enderecos/endereco-editar.modelo.dart';
import 'package:erp/models/cliente/outros-enderecos/endereco-grid.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class OutrosEnderecosTela extends StatefulWidget {
  final int parceiroId;
  final bool estrangeiro;
  OutrosEnderecosTela({Key key, this.parceiroId, this.estrangeiro}) : super(key: key);
  @override
  _OutrosEnderecosTelaState createState() => _OutrosEnderecosTelaState();
}

class _OutrosEnderecosTelaState extends State<OutrosEnderecosTela> {
  List<EnderecoGrid> enderecosList = new List<EnderecoGrid>();
  List<int> enderecosSelecionados = new List<int>();
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
  Stream<dynamic> _streamEnderecos;

  _OutrosEnderecosTelaState() {
  }

  @override
  void initState() {
    super.initState();
    enderecosList = [];
    parceiro = widget.parceiroId;
    _busca.addListener(_buscaDebounce);
    _locale.iniciaLocalizacao(context);
    _streamEnderecos = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamEnderecos = Stream.fromFuture(_fazRequest());
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
      enderecosList.clear();
      enderecosSelecionados.clear();
      pesquisa = '';
      _busca.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamEnderecos = Stream.fromFuture(_fazRequest());

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
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['OutrosEnderecos']),
              actions: <Widget>[
                enderecosSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: enderecosSelecionados.length == 1
                  ? _locale.locale['DeletarEnderecoSelecionadoToolTip']
                  : _locale.locale['DeletarEnderecosSelecionadosToolTip'],
                )
                : Container(),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroEndereco(
                      context,
                      parceiroId: widget.parceiroId,
                      estrangeiro: widget.estrangeiro
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        enderecosList.clear();
                        pesquisa = '';
                        _busca.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamEnderecos = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale["AdicionarEndereco"],
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
                        hintText: _locale.locale["BuscarEnderecos"],
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
            body: CustomOfflineWidget(child: _listagemEnderecos()),
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
      dynamic requestEnderecos = await ClienteService().outrosEnderecos.enderecosListaTeste(skip: _infinite.skipCount, search: pesquisa, parceiroId: parceiro);

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      // _infinite.novaLista = requestEnderecos.data['entidade'];

      List<EnderecoGrid> listaEndereco = new List<EnderecoGrid>();
      requestEnderecos.forEach((data) {
        listaEndereco.add(EnderecoGrid.fromJson(data));
      });

      listaEndereco = _verificaSelecionado(lista: listaEndereco);
      _infinite.novaLista = listaEndereco;
      // Adicione a novaLista á lista original
      enderecosList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return enderecosList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (enderecosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (enderecosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == enderecosList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _enderecoItem(context, index, enderecosList);
        },
        itemCount: enderecosList.length + 1,
      );
    }
  }

  Widget _listagemEnderecos() {
    return StreamBuilder(
      stream: _streamEnderecos,
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

  Widget _enderecoItem(BuildContext context, int index, List<EnderecoGrid> lista) {
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
                "${_locale.locale['TipoEndereco']}: ${lista[index].descricaoTipoEndereco}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              (lista[index].tipoEndereco == 4)
              ?Text(
                "${_locale.locale['Descricao']}: " + (lista[index].descricaoEnderecoOutros ?? ""),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              )
              : Container(),
              Text(
                "${_locale.locale['Endereco']}: " + (lista[index].endereco ?? ""),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Numero']}: " + (lista[index].numero ?? ""),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              widget.estrangeiro
              ? Text(("${_locale.locale['ZipCode']} :" + (lista[index].cep ?? '')),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              )
              : Text(("${_locale.locale['CEP']}: " + helper.cepFormatter(cep: lista[index].cep ?? '')),
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
        _selecionarEndereco(idEndereco: lista[index].id, index: index);
      },
      onLongPress: () {
        _multiplaSelecaoEndereco(idEndereco: lista[index].id, index: index);
      }
    );
  }

  _selecionarEndereco({int idEndereco, int index}) async {
    if (enderecosSelecionados.length == 0) {
      dynamic retorno = await ClienteService().outrosEnderecos.getEnderecoTeste(idEndereco: idEndereco, context: context);
      EnderecoEditar enderecoRetorno = EnderecoEditar.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroEndereco(
        context,
        parceiroId: widget.parceiroId,
        estrangeiro: widget.estrangeiro,
        endereco: enderecoRetorno
      );

      if (resultado != null && resultado == true) {
        setState(() {
          enderecosList.clear();
          pesquisa = '';
          _busca.clear();
        });
        _infinite.skipCount = 0;
        _infinite.infiniteScrollCompleto = false;
        _streamEnderecos = Stream.fromFuture(_fazRequest());
      }
    }
    else {
      _multiplaSelecaoEndereco(idEndereco: idEndereco, index: index);
    }
  }

  _multiplaSelecaoEndereco({int idEndereco, int index}) {
    if (!enderecosSelecionados.contains(idEndereco)) {
      enderecosSelecionados.add(idEndereco);
      setState(() {
        enderecosList[index].isSelected = true;
      });
    }
    else {
      enderecosSelecionados.remove(idEndereco);
      setState(() {
        enderecosList[index].isSelected = false;
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
    if(enderecosSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().outrosEnderecos.selecionaTodosEnderecos(context: context, parceiroId: widget.parceiroId);
      enderecosSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        enderecosSelecionados.add(data);
      });
      setState(() {
        enderecosList.forEach((endereco) {
          endereco.isSelected = true;
        });
      });
    }
    else if(enderecosSelecionados.length <= enderecosList.length) {
      enderecosSelecionados.clear();
      setState(() {
        enderecosList.forEach((endereco) {
          endereco.isSelected = false;
        });
      });
    }
  }

  List<EnderecoGrid> _verificaSelecionado({List<EnderecoGrid> lista}) {
    lista.forEach((endereco) {
      if(enderecosSelecionados.contains(endereco.id)) {
        endereco.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (enderecosSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarEnderecoConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().outrosEnderecos.deletaEndereco(idEndereco: enderecosSelecionados[0], context: context);
        _deletarEnderecos(resultado);
      }
    }
    else if (enderecosSelecionados.length > 1 && enderecosSelecionados.length < enderecosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarEnderecosSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().outrosEnderecos.deletaEnderecosLote(idEnderecos: enderecosSelecionados, context: context);
        _deletarEnderecos(resultado);
      }
    }
    else if (enderecosSelecionados.length == enderecosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarEnderecosTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().outrosEnderecos.deletaEnderecosLote(idEnderecos: enderecosSelecionados, context: context);
        _deletarEnderecos(resultado);
      }
    }
  }

  _deletarEnderecos(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      setState(() {
        enderecosList.clear();
        enderecosSelecionados.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamEnderecos = Stream.fromFuture(_fazRequest());
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
      enderecosList = [];
    });
    _streamEnderecos = Stream.fromFuture(_fazRequest());
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
