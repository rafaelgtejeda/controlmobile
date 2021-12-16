import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/rotas/orcamentos.rotas.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens.tab.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class ItensProdutosTabBar extends StatefulWidget {
  final List<Itens> itens;
  final Function(List<Itens>) recebeItens;
  ItensProdutosTabBar({Key key, this.itens, this.recebeItens}) : super(key: key);
  @override
  ItensProdutosTabBarState createState() => ItensProdutosTabBarState();
}

class ItensProdutosTabBarState extends State<ItensProdutosTabBar> with SingleTickerProviderStateMixin {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream _streamLista;

  List<Itens> _itensList = new List<Itens>();
  List<int> _itensSelecionados = new List<int>();

  var _valorTotalController = new MoneyMaskedTextController();
  var _descontoValorController = new MoneyMaskedTextController();
  FocusNode _focusDescontoValor = new FocusNode();
  TextEditingController _descontoPorcentagemController = new TextEditingController();
  FocusNode _focusDescontoPorcentagem = new FocusNode();

  double _descontoValor;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context)
      .then((value) {
        _descontoValorController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ');

        _valorTotalController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ');
      });
    _itensList = widget.itens;
    _streamLista = Stream.fromFuture(_atualizaLista());
    _itensList = widget.itens;
    _focusDescontoValor.addListener(_onFocusChangeDescontoValor);
    _focusDescontoPorcentagem.addListener(_onFocusChangeDescontoPorcentagem);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _atualizaLista() async {
    int contador = 0;
    _itensList.forEach((element) {
      if (element.indiceGeral == null) {
        element.indiceGeral = contador;
        contador++;
      }
    });
    _itensList = _itensList;
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return _tabBarItens();
        }
      ),
    );
  }

  Widget _tabBarItens() {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(36),
          child: _botaoAdicionarItem()
        ),
        actions: <Widget>[
          _itensSelecionados.length > 0
          ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deletar();
            }
          )
          : Container(),
          _itensList.length > 0
          ? IconButton(
            icon: Icon(Icons.select_all),
            onPressed: () {
              _selecionarTodos();
            }
          )
          : Container(),
          _itensList.length > 0
          ? IconButton(
            icon: Text('%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
            onPressed: () async {
              await _alertaModalDesconto(
                itens: _itensList,
                valorTotal: _somaValorTotal(_itensList),
                descontoValor: _somaDescontosValor(_itensList),
                descontoPorcentagem: _somaDescontosPorcentagem(_itensList),
              );
              setState(() {
                _itensList = _itensList;
              });
              return _itensList;
            }
          )
          : Container(),
          // PopupMenuButton<String>(
          //   onSelected: _escolheOpcao,
          //   itemBuilder: (BuildContext context) {
          //     return ConstantesOpcoesPopUpMenu.ESCOLHA_SELECIONAR_TODOS.map((String escolha) {
          //       return PopupMenuItem<String>(
          //         value: escolha,
          //         child: Text(_locate.locale['$escolha']),
          //       );
          //     }).toList();
          //   },
          // ),
        ],
        automaticallyImplyLeading: false,
        title: Text(_locate.locale[TraducaoStringsConstante.Produtos]),
      ),
      body: Container(
        child: StreamBuilder(
          stream: _streamLista,
          builder: (context, snapshot) {
            return _lista();
          }
        ),
      ),
    );
  }

  double _somaValorTotal(List<Itens> itens) {
    double soma = 0;
    itens.forEach((element) {
      soma += element.vlrTotal;
    });
    return soma;
  }

  double _somaDescontosValor(List<Itens> itens) {
    double somaDescontoValor = 0;
    itens.forEach((element) {
      somaDescontoValor += (element.prUnitario - element.prUnitComDesc) * element.quantidade;
    });
    return somaDescontoValor;
  }

  double _somaDescontosPorcentagem(List<Itens> itens) {
    double somaDescontoValor = 0;
    double somaValor = 0;
    double porcentagem = 0;
    itens.forEach((element) {
      somaValor += element.vlrTotal;
    });
    itens.forEach((element) {
      somaDescontoValor += (element.prUnitario - element.prUnitComDesc) * element.quantidade;
    });

    porcentagem = (100 * somaDescontoValor) / somaValor;
    return porcentagem;
  }

  List<Itens> _aplicaDesconto({
    List<Itens> itens,
    double valorTotal,
    double descontoValor,
    int casasDecimais = 4
  }) {
    double _vlTotal = 0;
    for(int i = 0; i < itens.length; i++){
      if(i==(itens.length-1)){
        // itens[i].vlrDesc = double.parse((descontoValor - _vlTotal).toStringAsFixed(casasDecimais));
        itens[i].vlrDesc = double.parse(((descontoValor - _vlTotal) / itens[i].quantidade).toStringAsFixed(casasDecimais));
      }else{
        double porcentagem = (itens[i].vlrTotal * 100) / valorTotal;
        // double resultadoUnitario = descontoValor * porcentagem/100;
        double resultadoUnitario = (descontoValor * porcentagem/100) / itens[i].quantidade;
        double resultadoTotal = descontoValor * porcentagem/100;

        itens[i].vlrDesc = double.parse(resultadoUnitario.toStringAsFixed(casasDecimais));
        // _vlTotal += itens[i].vlrDesc;
        _vlTotal += resultadoTotal;
      }    
      itens[i].percDesc = (itens[i].vlrDesc * 100 ) / itens[i].vlrTotal;
      itens[i].vlrTotComDesc = (itens[i].vlrTotal - itens[i].vlrDesc);
      itens[i].prUnitComDesc = itens[i].prUnitario - itens[i].vlrDesc;
    }  
    return itens;
  }

  Future _alertaModalDesconto({
    List<Itens> itens,
    double valorTotal,
    double descontoValor,
    double descontoPorcentagem,
  }) async {
    _valorTotalController.updateValue(valorTotal);
    _descontoValorController.updateValue(descontoValor);
    _descontoPorcentagemController.text = descontoPorcentagem.toStringAsFixed(2);

    await AlertaComponente().showAlerta(
      context: context,
      barrierDismissible: true,
      titulo: _locate.locale[TraducaoStringsConstante.Desconto],
      conteudo: Container(
        height: 200,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _valorTotalController,
                decoration: CampoTextoDecoration(
                  label: _locate.locale[TraducaoStringsConstante.ValorTotal],
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                enabled: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _descontoPorcentagemController,
                decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.DescontoPorcentagem]),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                focusNode: _focusDescontoPorcentagem,
                onChanged: (input) {
                  _calculaDescontoPorcentagem(double.parse(input));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _descontoValorController,
                decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.ValorDesconto]),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                focusNode: _focusDescontoValor,
                onChanged: (input) {
                  _calculaDescontoValor(_descontoValorController.numberValue);
                },
              ),
            ),
          ],
        ),
      ),
      acoes: [
        FlatButton(
          child: Text(_locate.locale['Ok']),
          onPressed: () {
            itens = _aplicaDesconto(
              itens: itens,
              descontoValor: _descontoValorController.numberValue,
              valorTotal: valorTotal
            );
            _descontoValor = 0;
            _itensList.forEach((element) {
              _descontoValor += element.vlrDesc * element.quantidade;
            });
            widget.recebeItens(_itensList);
            Navigator.pop(context, true);
          },
        ),
        FlatButton(
          child: Text(_locate.locale['Cancelar']),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
      ]
    );
  }

  _onFocusChangeDescontoValor() {
    if (!_focusDescontoValor.hasFocus) {
      _calculaDescontoValor(_descontoValorController.numberValue);
    }
  }

  _calculaDescontoValor(double valor) {
    double descontoPorcentagem;
    double valorTotal = _valorTotalController.numberValue;
    if (valor > valorTotal) {
      valor = valorTotal;
      _descontoValorController.updateValue(valor);
    }
    if (valor < 0) {
      valor = 0;
      _descontoValorController.updateValue(valor);
    }
    setState(() {
      descontoPorcentagem = (100 * valor) / valorTotal;
      if(descontoPorcentagem.isNaN) {
        descontoPorcentagem = 0;
      }
    });
    _descontoPorcentagemController.text = descontoPorcentagem.toStringAsFixed(3);
  }

  _onFocusChangeDescontoPorcentagem() {
    if (!_focusDescontoPorcentagem.hasFocus) {
      if(_descontoPorcentagemController.text.isEmpty) {
        _descontoPorcentagemController.text = 0.toStringAsFixed(3);
      }
      else {
        double porcento =double.parse(_descontoPorcentagemController.text);
        _descontoPorcentagemController.text = porcento.toStringAsFixed(3);
      }
      _calculaDescontoPorcentagem(double.parse(_descontoPorcentagemController.text));
    }
    else {
      // _descontoPorcentagemController.clear();
      _descontoPorcentagemController.selection = TextSelection.fromPosition(TextPosition(offset: _descontoPorcentagemController.text.length));
    }
  }

  _calculaDescontoPorcentagem(double porcentagem) {
    double descontoValor;
    double valorTotal = _valorTotalController.numberValue;
    if (porcentagem > 100) {
      porcentagem = 100;
      _descontoPorcentagemController.text = porcentagem.toStringAsFixed(3);
    }
    if (porcentagem < 0) {
      porcentagem = 0;
      _descontoPorcentagemController.text = porcentagem.toStringAsFixed(3);
    }
    setState(() {
      descontoValor = valorTotal * (0.01 * porcentagem);
    });
    _descontoValorController.updateValue(descontoValor);
  }

  Widget _lista() {
    return (_itensList.length == 0)
    ? SemInformacao()
    : ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) => Divisor(),
      itemBuilder: (context, index) => _item(index: index, item: _itensList[index]),
      itemCount: _itensList.length
    );
  }

  Widget _item({Itens item, int index}) {
    return InkWell(
      onTap: () async {
        if (_itensSelecionados.length == 0) {
          final resultado = await RotasOrcamentos.vaParaCadastroItem(
            context, tipo: TiposItensTabBarConstante.PRODUTOS, item: item, possuiLocacao: false, poussuiComodato: false
          );
          if (resultado != null) {
            _itensList.forEach((element) {
              if(element.indiceGeral == item.indiceGeral) {
                element = resultado;
              }
            });
            _streamLista = Stream.fromFuture(_atualizaLista());
            widget.recebeItens(_itensList);
          }
        }
        else {
          _multiplaSelecaoItem(indiceGeralItem: item.indiceGeral, index: index);
        }
      },
      onLongPress: () {
        _multiplaSelecaoItem(indiceGeralItem: item.indiceGeral, index: index);
      },
      child: Container(
        color: item.isSelected ? Colors.blue : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Texto(
                      item.produto,
                      color: item.isSelected ? Colors.white : Colors.black
                    ),
                    Texto(
                      '${_locate.locale[TraducaoStringsConstante.Quantidade]}: ${item.quantidade.toInt().toString()}',
                      color: item.isSelected ? Colors.white : Colors.black
                    ),
                    Texto(
                      '${_locate.locale[TraducaoStringsConstante.ValorUnitario]}: ' + Helper().dinheiroFormatter(item.prUnitario),
                      color: item.isSelected ? Colors.white : Colors.black
                    ),
                    Texto(
                      '${_locate.locale[TraducaoStringsConstante.ValorDesconto]}: ' + Helper().dinheiroFormatter(item.vlrDesc * item.quantidade),
                      color: item.isSelected ? Colors.white : Colors.black
                    ),
                    Texto(
                      '${_locate.locale[TraducaoStringsConstante.Desconto]}: ${item.percDesc.toStringAsFixed(2)}%',
                      color: item.isSelected ? Colors.white : Colors.black
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 3,
                child: Texto(Helper().dinheiroFormatter(item.vlrTotComDesc))
              )
            ],
          ),
        ),
      ),
    );
  }

  _multiplaSelecaoItem({int indiceGeralItem, int index}) {
    if (!_itensSelecionados.contains(indiceGeralItem)) {
      _itensSelecionados.add(indiceGeralItem);
      setState(() {
        _itensList.forEach((element) {
          if(element.indiceGeral == indiceGeralItem) {
            element.isSelected = true;
          }
        });
        _itensList[index].isSelected = true;
      });
    }
    else {
      _itensSelecionados.remove(indiceGeralItem);
      setState(() {
        _itensList.forEach((element) {
          if(element.indiceGeral == indiceGeralItem) {
            element.isSelected = true;
          }
        });
        _itensList[index].isSelected = false;
      });
    }
  }

  _selecionarTodos() {
    if(_itensSelecionados.length < _itensList.length) {
      _itensSelecionados.clear();

      _itensList.forEach((data) {
        _itensSelecionados.add(data.indiceGeral);
      });
      setState(() {
        _itensList.forEach((item) {
          item.isSelected = true;
        });
      });
    }
    else if(_itensSelecionados.length == _itensList.length) {
      _itensSelecionados.clear();
      setState(() {
        _itensList.forEach((item) {
          item.isSelected = false;
        });
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

  _deletar() async {
    bool deletar = false;
    if (_itensSelecionados.length == 1) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarItemConfirmacao]
        );
      if (deletar == true) {
        _deletarItens();
      }
    }
    else if (_itensSelecionados.length > 1 && _itensSelecionados.length < _itensList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarItensSelecionadosConfirmacao]
        );
      if (deletar == true) {
        _deletarItens();
      }
    }
    else if (_itensSelecionados.length == _itensList.length) {
      deletar = await AlertaComponente()
        .showAlertaConfirmacao(
          context: context,
          mensagem: _locate.locale[TraducaoStringsConstante.DeletarItensTodosConfirmacao]
        );
      if (deletar == true) {
        _deletarItens();
      }
    }
  }

  _deletarItens() {
    if (_itensList.length == _itensSelecionados.length) {
      setState(() {
        _itensList.clear();
        _itensSelecionados.clear();
      });
      widget.recebeItens(_itensList);
      _streamLista = Stream.fromFuture(_atualizaLista());
    }
    else {
      for (int i = 0; i < _itensList.length; i++){
        for(int j = 0; j < _itensSelecionados.length; j++) {
          if(_itensSelecionados[j] == _itensList[i].indiceGeral) {
            setState(() {
              _itensList.removeAt(i);
            });
          }
        }
      }
      _itensSelecionados.clear();
      _reorganizaListas();
      widget.recebeItens(_itensList);
      _streamLista = Stream.fromFuture(_atualizaLista());
    }
  }

  _reorganizaListas() {
    List<Itens> _novaListaItens = new List<Itens>();
    _itensList.forEach((element) {
      element.indiceGeral = _novaListaItens.length;
      _novaListaItens.add(element);
    });
    _itensList.clear();
    _itensList = _novaListaItens;
  }

  _adicionarProduto() async {
    final resultado = await RotasOrcamentos.vaParaCadastroItem(
      context, tipo: TiposItensTabBarConstante.PRODUTOS, possuiLocacao: false, poussuiComodato: false
    );
    if (resultado != null) {
      resultado.indiceGeral = _itensList.length;
      _itensList.add(resultado);
      _streamLista = Stream.fromFuture(_atualizaLista());
      widget.recebeItens(_itensList);
    }
  }

  Widget _botaoAdicionarItem() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 32,
        child: SizedBox.expand(
          child: FlatButton(
            onPressed: _adicionarProduto,
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Texto(
              _locate.locale[TraducaoStringsConstante.AdicionarProdutos],
              color: Colors.white,
              bold: true,
              fontSize: 16
            )
          ),
        ),
      ),
    );
  }
}
