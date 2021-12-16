import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/parque-tecnologico/parque-grid.modelo.dart';
import 'package:erp/models/cliente/parque-tecnologico/parque-tecnologico-editar.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ParqueTecnologicoListaTela extends StatefulWidget {
  final int parceiroId;
  final int empresaId;
  ParqueTecnologicoListaTela({Key key, this.parceiroId, this.empresaId}) : super(key: key);
  @override
  _ParqueTecnologicoListaTelaState createState() => _ParqueTecnologicoListaTelaState();
}

class _ParqueTecnologicoListaTelaState extends State<ParqueTecnologicoListaTela> {
  List<ParqueGrid> parquesList = new List<ParqueGrid>();
  List<int> parquesSelecionados = new List<int>();
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
  Stream<dynamic> _streamParques;

  _ParqueTecnologicoListaTelaState() {
  }

  @override
  void initState() {
    super.initState();
    parquesList = [];
    parceiro = widget.parceiroId;
    _busca.addListener(_buscaDebounce);
    _locale.iniciaLocalizacao(context);
    _streamParques = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamParques = Stream.fromFuture(_fazRequest());
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
      parquesList.clear();
      parquesSelecionados.clear();
      pesquisa = '';
      _busca.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamParques = Stream.fromFuture(_fazRequest());

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
              title: Text(_locale.locale['ParquesTecnologicos']),
              actions: <Widget>[
                parquesSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: parquesSelecionados.length == 1
                  ? _locale.locale['DeletarParqueSelecionadoToolTip']
                  : _locale.locale['DeletarParquesSelecionadosToolTip'],
                )
                : Container(),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroParqueTecnologico(
                      context,
                      parceiroId: widget.parceiroId,
                      empresaId: widget.empresaId
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        parquesList.clear();
                        pesquisa = '';
                        _busca.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamParques = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale["AdicionarParque"],
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
                        hintText: _locale.locale["BuscarParques"],
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
            body: CustomOfflineWidget(child: _listagemParques()),
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
      dynamic requestParques = await ClienteService().parque.parqueTecnologicoListaTeste(
        skip: _infinite.skipCount,
        search: pesquisa,
        parceiroId: parceiro
      );

      // List<ParqueListaTeste> parquesJson = ParqueListaTeste.fromJson(requestParques);
      List<ParqueGrid> listaParque = new List<ParqueGrid>();
      requestParques.forEach((data) {
        listaParque.add(ParqueGrid.fromJson(data));
      });

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      listaParque = _verificaSelecionado(lista: listaParque);
      _infinite.novaLista = listaParque;
      // Adicione a novaLista á lista original
      parquesList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return parquesList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (parquesList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (parquesList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == parquesList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _parqueItem(context, index, parquesList);
        },
        itemCount: parquesList.length + 1,
      );
    }
  }

  Widget _listagemParques() {
    return StreamBuilder(
      stream: _streamParques,
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

  Widget _parqueItem(BuildContext context, int index, List<ParqueGrid> lista) {
    if (index >= lista.length) {
      return null;
    }

    DateTime data = DateTime.parse(lista[index].dataInstalacao);
    String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);

    return InkWell(
      child: Container(
        color: lista[index].isSelected ? Colors.blue : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${_locale.locale['Equipamento']}: ${lista[index].descricaoEquipamento ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['DescricaoProduto']}: ${lista[index].descricaoProduto ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['DataInstalacao']}: ${dataFormatada ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['DescricaoMarca']}: ${lista[index].descricaoMarca ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['DescricaoModelo']}: ${lista[index].descricaoModelo ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['NumeroSerie']}: ${lista[index].numeroDeSerie ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Quantidade']}: ${(lista[index].quantidade).toInt() ?? ''}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Observacao']}: ${lista[index].observacao ?? ''}",
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
        _selecionarParque(idParque: lista[index].id, index: index);
      },
      onLongPress: () {
        _multiplaSelecaoParque(idParque: lista[index].id, index: index);
      }
    );
  }

  _selecionarParque({int idParque, int index}) async {
    if (parquesSelecionados.length == 0) {
      dynamic retorno = await ClienteService().parque.getParqueTecnologicoTeste(idParque: idParque, context: context);
      ParqueEditar parqueRetorno = ParqueEditar.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroParqueTecnologico(
        context,
        parceiroId: widget.parceiroId,
        empresaId: widget.empresaId,
        parqueTecnologico: parqueRetorno,
      );

      if (resultado != null && resultado == true) {
        setState(() {
          parquesList.clear();
          pesquisa = '';
          _busca.clear();
        });
        _infinite.skipCount = 0;
        _infinite.infiniteScrollCompleto = false;
        _streamParques = Stream.fromFuture(_fazRequest());
      }
    }
    else {
      _multiplaSelecaoParque(idParque: idParque, index: index);
    }
  }

  _multiplaSelecaoParque({int idParque, int index}) {
    if (!parquesSelecionados.contains(idParque)) {
      parquesSelecionados.add(idParque);
      setState(() {
        parquesList[index].isSelected = true;
      });
    }
    else {
      parquesSelecionados.remove(idParque);
      setState(() {
        parquesList[index].isSelected = false;
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
    if(parquesSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().parque.selecionaTodosParques(context: context, parceiroId: widget.parceiroId);
      parquesSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        parquesSelecionados.add(data);
      });
      setState(() {
        parquesList.forEach((parque) {
          parque.isSelected = true;
        });
      });
    }
    else if(parquesSelecionados.length <= parquesList.length) {
      parquesSelecionados.clear();
      setState(() {
        parquesList.forEach((parque) {
          parque.isSelected = false;
        });
      });
    }
  }

  List<ParqueGrid> _verificaSelecionado({List<ParqueGrid> lista}) {
    lista.forEach((parque) {
      if(parquesSelecionados.contains(parque.id)) {
        parque.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (parquesSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarParqueConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().parque.deletaParque(idParque: parquesSelecionados[0], context: context);
        _deletarParques(resultado);
      }
    }
    else if (parquesSelecionados.length > 1 && parquesSelecionados.length < parquesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarParquesSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().parque.deletaParquesLote(idParques: parquesSelecionados, context: context);
        _deletarParques(resultado);
      }
    }
    else if (parquesSelecionados.length == parquesList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarParquesTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().parque.deletaParquesLote(idParques: parquesSelecionados, context: context);
        _deletarParques(resultado);
      }
    }
  }

  _deletarParques(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      setState(() {
        parquesList.clear();
        parquesSelecionados.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamParques = Stream.fromFuture(_fazRequest());
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
      parquesList = [];
    });
    _streamParques = Stream.fromFuture(_fazRequest());
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
