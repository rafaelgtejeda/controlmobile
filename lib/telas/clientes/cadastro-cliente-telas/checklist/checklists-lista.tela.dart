import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/compartilhados/componentes/busca/busca.componente.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/checklist/checklist-editar.modelo.dart';
import 'package:erp/models/cliente/checklist/checklist-grid.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ChecklistListaTela extends StatefulWidget {
  final int parceiroId;
  ChecklistListaTela({Key key, this.parceiroId}) : super(key: key);
  @override
  _ChecklistListaTelaState createState() => _ChecklistListaTelaState();
}

class _ChecklistListaTelaState extends State<ChecklistListaTela> {
  List<CheckListGrid> checklistList = new List<CheckListGrid>();
  List<int> checkListsSelecionados = new List<int>();
  ScrollController _scrollController = new ScrollController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();

  LocalizacaoServico _locale = new LocalizacaoServico();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  Helper helper = new Helper();
  int parceiro;
  Stream<dynamic> _streamCheckLists;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    checklistList.clear();
    parceiro = widget.parceiroId;
    _streamCheckLists = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _buscaKey.currentState?.pesquisa ?? '');
        _streamCheckLists = Stream.fromFuture(_fazRequest());
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

  _atualizarLista() {
    setState(() {
      checklistList.clear();
      checkListsSelecionados.clear();
      _buscaKey.currentState.clearBusca();
    });
    _infinite.restart();
    _streamCheckLists = Stream.fromFuture(_fazRequest());
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['CheckList']),
              actions: <Widget>[
                checkListsSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: checkListsSelecionados.length == 1
                  ? _locale.locale['DeletarCheckListSelecionadoToolTip']
                  : _locale.locale['DeletarCheckListsSelecionadosToolTip'],
                )
                : Container(),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroCheckList(
                      context,
                      parceiroId: widget.parceiroId,
                    );

                    if (resultado != null && resultado == true) {
                      _atualizarLista();
                    }
                  },
                  tooltip: _locale.locale["AdicionarCheckList"],
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
                child: BuscaComponente(
                  key: _buscaKey,
                  placeholder: _locale.locale[TraducaoStringsConstante.BuscarCheckLists],
                  funcao: () {
                    if (_buscaKey.currentState.alterouBusca()) {
                      _infinite.verificaPesquisaAlterada();
                    }
                    else {
                      _infinite.pesquisaAlterada = false;
                    }
                    setState(() {
                      checklistList.clear();
                      checkListsSelecionados.clear();
                    });
                    _infinite.restart();
                    _streamCheckLists = Stream.fromFuture(_fazRequest());
                  },
                ),
              ),
            ),
            body: CustomOfflineWidget(child: _listagemCheckList()),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<dynamic> _fazRequest() async {
    if (!_infinite.infiniteScrollCompleto) {
      dynamic requestCheckLists = await ClienteService().checkList.checkListLista(
        skip: _infinite.skipCount,
        search: _buscaKey.currentState?.pesquisa ?? '',
        parceiroId: parceiro
      );
      List<CheckListGrid> listaCheckList = new List<CheckListGrid>();
      requestCheckLists.forEach((data) {
        listaCheckList.add(CheckListGrid.fromJson(data));
      });
      listaCheckList = _verificaSelecionado(lista: listaCheckList);
      _infinite.novaLista = listaCheckList;
      checklistList.addAll(_infinite.novaLista.cast());
      _infinite.completaInfiniteScroll();
      return checklistList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (checklistList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (checklistList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: _scrollController,
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == checklistList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _checkListItem(context, index, checklistList);
        },
        itemCount: checklistList.length + 1,
      );
    }
  }

  Widget _listagemCheckList() {
    return StreamBuilder(
      stream: _streamCheckLists,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: ListView(
            children: <Widget>[
              _childStreamConexao(context: context, snapshot: snapshot),
            ],
          ),
        );
      },
    );
  }

  Widget _checkListItem(BuildContext context, int index, List<CheckListGrid> lista) {
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
                "${_locale.locale['Sequencia']}: ${lista[index].sequencia}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Descricao']}: ${lista[index].descricao}",
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
        _selecionarCheckList(idCheckList: lista[index].id, index: index);
      },
      onLongPress: () {
        _multiplaSelecaoCheckList(idCheckList: lista[index].id, index: index);
      }
    );
  }

  _selecionarCheckList({int idCheckList, int index}) async {
    if (checkListsSelecionados.length == 0) {
      dynamic retorno = await ClienteService().checkList.getCheckList(idCheckList: idCheckList, context: context);
      CheckListEditar checkListRetorno = CheckListEditar.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroCheckList(
        context,
        checkList: checkListRetorno,
        parceiroId: widget.parceiroId,
      );

      if (resultado != null && resultado == true) {
        _atualizarLista();
      }
    }
    else {
      _multiplaSelecaoCheckList(idCheckList: idCheckList, index: index);
    }
  }

  _multiplaSelecaoCheckList({int idCheckList, int index}) {
    if (!checkListsSelecionados.contains(idCheckList)) {
      checkListsSelecionados.add(idCheckList);
      setState(() {
        checklistList[index].isSelected = true;
      });
    }
    else {
      checkListsSelecionados.remove(idCheckList);
      setState(() {
        checklistList[index].isSelected = false;
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
    if(checkListsSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().checkList.selecionaTodosCheckLists(context: context, parceiroId: widget.parceiroId);
      checkListsSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        checkListsSelecionados.add(data);
      });
      setState(() {
        checklistList.forEach((checkList) {
          checkList.isSelected = true;
        });
      });
    }
    else if(checkListsSelecionados.length <= checklistList.length) {
      checkListsSelecionados.clear();
      setState(() {
        checklistList.forEach((checkList) {
          checkList.isSelected = false;
        });
      });
    }
  }

  List<CheckListGrid> _verificaSelecionado({List<CheckListGrid> lista}) {
    lista.forEach((checkList) {
      if(checkListsSelecionados.contains(checkList.id)) {
        checkList.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (checkListsSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCheckListConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().checkList.deletaCheckList(idCheckList: checkListsSelecionados[0], context: context);
        _deletarCheckLists(resultado);
      }
    }
    else if (checkListsSelecionados.length > 1 && checkListsSelecionados.length < checklistList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCheckListsSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().checkList.deletaCheckListsLote(idCheckLists: checkListsSelecionados, context: context);
        _deletarCheckLists(resultado);
      }
    }
    else if (checkListsSelecionados.length == checklistList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarCheckListsTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().checkList.deletaCheckListsLote(idCheckLists: checkListsSelecionados, context: context);
        _deletarCheckLists(resultado);
      }
    }
  }

  _deletarCheckLists(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      _atualizarLista();
    }
  }
}
