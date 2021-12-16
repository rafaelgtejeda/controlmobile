import 'dart:async';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/add-button/add-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/cliente/contato/contato-editar.modelo.dart';
import 'package:erp/models/cliente/contato/contato-grid.modelo.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';

class ContatoListaTela extends StatefulWidget {
  final int parceiroId;
  ContatoListaTela({Key key, this.parceiroId}) : super(key: key);
  @override
  _ContatoListaTelaState createState() => _ContatoListaTelaState();
}

class _ContatoListaTelaState extends State<ContatoListaTela> {
  List<ContatoGrid> contatosList = new List<ContatoGrid>();
  List<int> contatosSelecionados = new List<int>();
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
  Stream<dynamic> _streamContatos;

  _ContatoListaTelaState() {
  }

  @override
  void initState() {
    super.initState();
    contatosList = [];
    parceiro = widget.parceiroId;
    _busca.addListener(_buscaDebounce);
    _locale.iniciaLocalizacao(context);
    _streamContatos = Stream.fromFuture(_fazRequest());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: pesquisa);
        _streamContatos = Stream.fromFuture(_fazRequest());
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
      contatosList.clear();
      contatosSelecionados.clear();
      pesquisa = '';
      _busca.clear();
    });
    _infinite.skipCount = 0;
    _infinite.infiniteScrollCompleto = false;
    _streamContatos = Stream.fromFuture(_fazRequest());

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
              title: Text(_locale.locale['Contato']),
              actions: <Widget>[
                contatosSelecionados.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.delete,),
                  iconSize: 35,
                  onPressed: _confirmarDeletarSelecao,
                  tooltip: contatosSelecionados.length == 1
                  ? _locale.locale['DeletarContatoSelecionadoToolTip']
                  : _locale.locale['DeletarContatosSelecionadosToolTip'],
                )
                : Container(),
                AddButtonComponente(
                  funcao: () async {
                    final resultado = await RotasClientes.vaParaCadastroContato(
                      context,
                      parceiroId: widget.parceiroId,
                    );

                    if (resultado != null && resultado == true) {
                      setState(() {
                        contatosList.clear();
                        pesquisa = '';
                        _busca.clear();
                      });
                      _infinite.skipCount = 0;
                      _infinite.infiniteScrollCompleto = false;
                      _streamContatos = Stream.fromFuture(_fazRequest());
                    }
                  },
                  tooltip: _locale.locale["AdicionarContato"],
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
                        hintText: _locale.locale["BuscarContatos"],
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
            body: CustomOfflineWidget(child: _listagemContatos()),
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
      dynamic requestContatos = await ClienteService().contato.contatosListaTeste(
        skip: _infinite.skipCount,
        search: pesquisa,
        parceiroId: parceiro
      );

      // contato.Contatos contatosJson = contato.Contatos.fromJson(requestContatos.data);

      List<ContatoGrid> listaContato = new List<ContatoGrid>();
      requestContatos.forEach((data) {
        listaContato.add(ContatoGrid.fromJson(data));
      });

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      listaContato = _verificaSelecionado(lista: listaContato);
      _infinite.novaLista = listaContato;
      // Adicione a novaLista á lista original
      contatosList.addAll(_infinite.novaLista.cast());

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return contatosList;
    } else {
      return null;
    }
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (contatosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (contatosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.separated(
        shrinkWrap: true,
        controller: new ScrollController(),
        separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
        itemBuilder: (context, index) {
          if (index == contatosList.length && !_infinite.infiniteScrollCompleto) {
            return Container(
              height: 100,
              width: 100,
              alignment: Alignment.center,
              child: Carregando(),
            );
          }
          return _contatoItem(context, index, contatosList);
        },
        itemCount: contatosList.length + 1,
      );
    }
  }

  Widget _listagemContatos() {
    return StreamBuilder(
      stream: _streamContatos,
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

  _verificacaoNumeroExiste(String numero, {String concat}) {
    String resultado;
    if (numero != '' && numero != "NaN") {
      resultado = (concat ?? '') + numero;
    }
    else {
      resultado = '';
    }
    return resultado;
  }

  Widget _contatoItem(BuildContext context, int index, List<ContatoGrid> lista) {
    if (index >= lista.length) {
      return null;
    }

    String ddiTelefone = _verificacaoNumeroExiste(lista[index].telefone.ddi ?? '', concat: '+');
    String dddTelefone = _verificacaoNumeroExiste(lista[index].telefone.ddd ?? '');
    String numeroTelefone = _verificacaoNumeroExiste(lista[index].telefone.phone ?? '');

    String ddiCelular = _verificacaoNumeroExiste(lista[index].celular.ddi ?? '', concat: '+');
    String dddCelular = _verificacaoNumeroExiste(lista[index].celular.ddd ?? '');
    String numeroCelular = _verificacaoNumeroExiste(lista[index].celular.phone ?? '');

    return InkWell(
      child: Container(
        color: lista[index].isSelected ? Colors.blue : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${_locale.locale['Nome']}: ${lista[index].nome}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Email']}: ${lista[index].email}",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Telefone']}: $ddiTelefone $dddTelefone $numeroTelefone",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locale.locale['Celular']}: $ddiCelular $dddCelular $numeroCelular",
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        _locale.locale['Boleto'],
                        style: TextStyle(
                          fontSize: 18,
                          color: lista[index].isSelected ? Colors.white : Colors.black
                        ),
                      ),
                      SizedBox(height: 15,),
                      lista[index].boleto
                      ? Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                      : Icon(
                        Icons.clear,
                        color: Colors.red
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        _locale.locale['NotaFiscal'],
                        style: TextStyle(
                          fontSize: 18,
                          color: lista[index].isSelected ? Colors.white : Colors.black
                        ),
                      ),
                      SizedBox(height: 15,),
                      lista[index].notaFiscal
                      ? Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                      : Icon(
                        Icons.clear,
                        color: Colors.red
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text(
                        _locale.locale['Principal'],
                        style: TextStyle(
                          fontSize: 18,
                          color: lista[index].isSelected ? Colors.white : Colors.black
                        ),
                      ),
                      SizedBox(height: 15,),
                      lista[index].principal
                      ? Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                      : Icon(
                        Icons.clear,
                        color: Colors.red
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _selecionarContato(idContato: lista[index].id, index: index);
      },
      onLongPress: () {
        _multiplaSelecaoContato(idContato: lista[index].id, index: index);
      }
    );
  }

  _selecionarContato({int idContato, int index}) async {
    if (contatosSelecionados.length == 0) {
      dynamic retorno = await ClienteService().contato.getContatoTeste(idContato: idContato, context: context);
      ContatoEditar contatoRetorno = ContatoEditar.fromJson(retorno);

      final resultado = await RotasClientes.vaParaCadastroContato(
        context,
        contato: contatoRetorno,
        parceiroId: widget.parceiroId,
      );

      if (resultado != null && resultado == true) {
        setState(() {
          contatosList.clear();
          pesquisa = '';
          _busca.clear();
        });
        _infinite.skipCount = 0;
        _infinite.infiniteScrollCompleto = false;
        _streamContatos = Stream.fromFuture(_fazRequest());
      }
    }
    else {
      _multiplaSelecaoContato(idContato: idContato, index: index);
    }
  }

  _multiplaSelecaoContato({int idContato, int index}) {
    if (!contatosSelecionados.contains(idContato)) {
      contatosSelecionados.add(idContato);
      setState(() {
        contatosList[index].isSelected = true;
      });
    }
    else {
      contatosSelecionados.remove(idContato);
      setState(() {
        contatosList[index].isSelected = false;
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
    if(contatosSelecionados.length == 0) {
      dynamic requestSelecionarTodos = await ClienteService().contato.selecionaTodosContatos(context: context, parceiroId: widget.parceiroId);
      contatosSelecionados.clear();

      requestSelecionarTodos.forEach((data) {
        contatosSelecionados.add(data);
      });
      setState(() {
        contatosList.forEach((contato) {
          contato.isSelected = true;
        });
      });
    }
    else if(contatosSelecionados.length <= contatosList.length) {
      contatosSelecionados.clear();
      setState(() {
        contatosList.forEach((contato) {
          contato.isSelected = false;
        });
      });
    }
  }

  List<ContatoGrid> _verificaSelecionado({List<ContatoGrid> lista}) {
    lista.forEach((contato) {
      if(contatosSelecionados.contains(contato.id)) {
        contato.isSelected = true;
      }
    });
    return lista;
  }

  _confirmarDeletarSelecao() async {
    bool deletar = false;
    if (contatosSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarContatoConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().contato.deletaContato(idContato: contatosSelecionados[0], context: context);
        _deletarContatos(resultado);
      }
    }
    else if (contatosSelecionados.length > 1 && contatosSelecionados.length < contatosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarContatosSelecionadosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().contato.deletaContatosLote(idContatos: contatosSelecionados, context: context);
        _deletarContatos(resultado);
      }
    }
    else if (contatosSelecionados.length == contatosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(context: context, mensagem: _locale.locale['DeletarContatosTodosConfirmacao']);
      if (deletar == true) {
        Response resultado = await ClienteService().contato.deletaContatosLote(idContatos: contatosSelecionados, context: context);
        _deletarContatos(resultado);
      }
    }
  }

  _deletarContatos(Response resultado) {
    // Tratar Deletes Offline
    if(resultado.statusCode == 200) {
      setState(() {
        contatosList.clear();
        contatosSelecionados.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamContatos = Stream.fromFuture(_fazRequest());
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
      contatosList = [];
    });
    _streamContatos = Stream.fromFuture(_fazRequest());
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
