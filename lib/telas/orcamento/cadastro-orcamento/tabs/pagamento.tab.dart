import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/rotas/orcamentos.rotas.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PagamentoTabBar extends StatefulWidget {
  final double total;
  final List<Vencimentos> vencimentos;
  final Function(List<Vencimentos>) recebeVencimentos;
  final int parceiroId;
  PagamentoTabBar({Key key, this.vencimentos, this.recebeVencimentos, this.total, this.parceiroId}) : super(key: key);
  @override
  PagamentoTabBarState createState() => PagamentoTabBarState();
}

class PagamentoTabBarState extends State<PagamentoTabBar> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream _streamPagamentos;
  List<Vencimentos> _pagamentosList = new List<Vencimentos>();
  List<int> _pagamentosSelecionados = new List<int>();
  double _valor = 0;
  double _valorVencimentos = 0;

  bool _isOnline = true;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _pagamentosList = widget.vencimentos;
    _streamPagamentos = Stream.fromFuture(_atualizaLista());
    _pagamentosList = widget.vencimentos;
    _calculaValores();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return _bodyPagamentos();
        }
      ),
    );
  }

  Future _atualizaLista() async {
    _pagamentosList = _pagamentosList;
  }

  _calculaValores() {
    _valorVencimentos = 0;
    _pagamentosList.forEach((element) {
      _valorVencimentos += element.valor;
    });

    setState(() {
      _valorVencimentos = _valorVencimentos;
    });

    _valor = widget.total - _valorVencimentos;

  }

  Widget _bodyPagamentos() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _isOnline
          ? _valor <= 0
            ? Container()
            : _botaoAdicionarPagamento()
          : Container(
            height: 32,
            child: Center(
              child: Text(
                _locate.locale[TraducaoStringsConstante.IndisponivelOffline],
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        actions: <Widget>[
          _pagamentosSelecionados.length > 0
          ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deletar();
            }
          )
          : Container(),
          _pagamentosList.length > 0
          ? IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              _selecionarTodos();
            }
          )
          : Container(),
          // PopupMenuButton<String>(
          //   onSelected: _escolheOpcao,
          //   itemBuilder: (BuildContext context) {
          //     return ConstantesOpcoesPopUpMenu.ESCOLHAS.map((String escolha) {
          //       return PopupMenuItem<String>(
          //         value: escolha,
          //         child: Text(_locate.locale['$escolha']),
          //       );
          //     }).toList();
          //   },
          // ),
        ],
      ),
      body: StreamBuilder(
        stream: _streamPagamentos,
        builder: (context, snapshot) {
          return _listaPagamento();
        }
      ),
    );
  }

  Widget _listaPagamento() {
    return (_pagamentosList.length == 0)
    ? SemInformacao()
    : ListView.separated(
      separatorBuilder: (context, index) => Divisor(),
      itemBuilder: (context, index) {
        if (index == _pagamentosList.length) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Texto(_locate.locale[TraducaoStringsConstante.Total]),
                Texto(
                  Helper().dinheiroFormatter(_valorVencimentos),
                  color: Helper().positivoNegativoDinheiroCor(_valorVencimentos)
                ),
              ],
            ),
          );
        }
        return _itemPagamento(index: index, lista: _pagamentosList);
      },
      itemCount: _pagamentosList.length + 1
    );
  }

  Widget _itemPagamento({List<Vencimentos> lista, int index}) {
    DateTime data = DateTime.parse(lista[index].vencimento);
    String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);

    if(index >= lista.length) {
      return null;
    }

    // return Slidable(
    //   actionPane: SlidableDrawerActionPane(),
    //   actionExtentRatio: 0.25,
    //   secondaryActions: <Widget>[
    //     IconSlideAction(
    //       caption: _locate.locale['Remover'],
    //       color: Colors.red,
    //       icon: Icons.delete,
    //       onTap: () {
    //         _deletar(idOrcamento: lista[index].id);
    //           // _confirmarDeletarMateriaisServico(msLista[index].id);
    //       },
    //     ),
    //   ],

      return InkWell(
      // child: InkWell(
        child: Container(
          color: lista[index].isSelected ? Colors.blue : Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Texto(
                      '${_locate.locale[TraducaoStringsConstante.Vencimento]}: $dataFormatada',
                      color: lista[index].isSelected ? Colors.white : Colors.black
                    ),
                    Texto(
                      lista[index].formaPagamento,
                      color: lista[index].isSelected ? Colors.white : Colors.black
                    ),
                  ],
                ),
                Texto(
                  Helper().dinheiroFormatter(lista[index].valor),
                  color: Helper().positivoNegativoDinheiroCor(lista[index].valor),
                  bold: true
                )
              ],
            ),
          ),
        ),
        onTap: () {
          _selecaoOrcamento(lista: lista, index: index);
        },
        onLongPress: () {
          _multiplaSelecaoItem(numeroParcela: lista[index].parcela, index: index);
        },
      // ),
      );
    // );
  }

  // _deletar({int idOrcamento}) async {
  //   bool deletar = false;
  //   // if (_orcamentosSelecionados.length == 1) {
  //     deletar = await AlertaComponente()
  //       .showAlertaConfirmacao(context: context, mensagem: _locate.locale['DeletarOrcamentoConfirmacao']);
  //     if (deletar == true) {
  //       Response resultado = await OrcamentoService().deletaOrcamento(idOrcamento: idOrcamento, context: context);
  //       _deletarOrcamentos(resultado);
  //     }
  //   // }
  // }

  // _deletarOrcamentos(Response resultado) {
  //   if (resultado.statusCode == 200) {
  //     setState(() {
  //       _orcamentoList.clear();
  //       // _orcamentosSelecionados.clear();
  //       pesquisa = '';
  //       _busca.clear();
  //     });
  //     _infinite.skipCount = 0;
  //     _infinite.infiniteScrollCompleto = false;
  //     _streamOrcamentos = Stream.fromFuture(_fazRequest());
  //   }
  // }

  _selecaoOrcamento({List<Vencimentos> lista, int index}) {
    // if (_pagamentosSelecionados.length == 0) {
    // }
    // else {
      _multiplaSelecaoItem(numeroParcela: lista[index].parcela, index: index);
    // }
  }

  _multiplaSelecaoItem({int numeroParcela, int index}) {
    if (!_pagamentosSelecionados.contains(numeroParcela)) {
      _pagamentosSelecionados.add(numeroParcela);
      setState(() {
        _pagamentosList.forEach((element) {
          if(element.parcela == numeroParcela) {
            element.isSelected = true;
          }
        });
        // _listaExibida[index].isSelected = true;
      });
    }
    else {
      _pagamentosSelecionados.remove(numeroParcela);
      setState(() {
        _pagamentosList.forEach((element) {
          if(element.parcela == numeroParcela) {
            element.isSelected = false;
          }
        });
        // _listaExibida[index].isSelected = false;
      });
    }
  }

  _selecionarTodos() {
    if(_pagamentosSelecionados.length < _pagamentosList.length) {
      _pagamentosSelecionados.clear();

      _pagamentosList.forEach((data) {
        _pagamentosSelecionados.add(data.parcela);
      });
      setState(() {
        _pagamentosList.forEach((pagamento) {
          pagamento.isSelected = true;
        });
      });
    }
    else if(_pagamentosSelecionados.length == _pagamentosList.length) {
      _pagamentosSelecionados.clear();
      setState(() {
        _pagamentosList.forEach((pagamento) {
          pagamento.isSelected = false;
        });
      });
    }
  }

  _deletar() async {
    bool deletar = false;
    if (_pagamentosSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarPagamentoConfirmacao]
        );
      if (deletar == true) {
        _deletarPagamentos();
      }
    }
    else if (_pagamentosSelecionados.length > 1 && _pagamentosSelecionados.length < _pagamentosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarPagamentosSelecionadosConfirmacao]
        );
      if (deletar == true) {
        _deletarPagamentos();
      }
    }
    else if (_pagamentosSelecionados.length == _pagamentosList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarPagamentosTodosConfirmacao]
        );
      if (deletar == true) {
        _deletarPagamentos();
      }
    }
  }

  _deletarPagamentos() {
    if (_pagamentosList.length == _pagamentosSelecionados.length) {
      setState(() {
        _pagamentosList.clear();
        _pagamentosSelecionados.clear();
      });
      _calculaValores();
      widget.recebeVencimentos(_pagamentosList);
      _streamPagamentos = Stream.fromFuture(_atualizaLista());
    }
    else {

      for (int i = 0; i < _pagamentosList.length; i++){
        for(int j = 0; j < _pagamentosSelecionados.length; j++) {
          if(_pagamentosSelecionados[j] == _pagamentosList[i].parcela) {
            setState(() {
              _pagamentosList.removeAt(i);
            });
          }
        }
      }
      _pagamentosSelecionados.clear();
      _reorganizaListas();
      _calculaValores();
      widget.recebeVencimentos(_pagamentosList);
      _streamPagamentos = Stream.fromFuture(_atualizaLista());
    }
  }

  _reorganizaListas() {
    List<Vencimentos> _novaListaPagamentos = new List<Vencimentos>();
    _pagamentosList.forEach((element) {
      element.parcela = _novaListaPagamentos.length + 1;
      _novaListaPagamentos.add(element);
    });
    _pagamentosList.clear();
    _pagamentosList = _novaListaPagamentos;
  }

  Widget _botaoAdicionarPagamento({Function funcao}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 32,
        child: SizedBox.expand(
          child: FlatButton(
            onPressed: () async {
              final resultado = await RotasOrcamentos.vaParaCadastroPagamento(context, valor: _valor, parceiroId: widget.parceiroId);
              if (resultado != null) {
                resultado.forEach((element) {
                  Vencimentos novoVencimento = new Vencimentos();
                  novoVencimento.condicaoPagamentoId = element.condicaoPagamentoId;
                  novoVencimento.formaPagamentoId = element.formaPagamentoId;
                  novoVencimento.formaPagamento = element.descricaoFormaPagamento;
                  novoVencimento.vencimento = element.vencimento;
                  novoVencimento.valor = element.valor;
                  novoVencimento.parcela = _pagamentosList.length + 1;

                  _pagamentosList.add(novoVencimento);
                });
                _calculaValores();
                _streamPagamentos = Stream.fromFuture(_atualizaLista());
                widget.recebeVencimentos(_pagamentosList);
              }
            },
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Texto(
              _locate.locale[TraducaoStringsConstante.AdicionarPagamento],
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
