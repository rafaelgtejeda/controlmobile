import 'dart:async';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/produtos-modal/lista-produtos-modal.componente.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens.tab.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';

class CadastroItensModal extends StatefulWidget {
  final int tipo;
  final Itens item;
  final bool possuiLocacao;
  final bool possuiComodato;
  CadastroItensModal({
    Key key, @required this.tipo, this.item, this.possuiLocacao, this.possuiComodato
  }) : super(key: key);
  @override
  _CadastroItensModalState createState() => _CadastroItensModalState();
}

class _CadastroItensModalState extends State<CadastroItensModal> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Timer _debounce;

  List<int> tipos = new List<int>();

  Produto _produtoSelecionado = new Produto();
  Itens _item = new Itens();

  double _quantidade = 0;
  String _unidadeDeMedida = '';
  double _valorUnitario = 0;
  double _descontoPorcentagem = 0;
  double _descontoMoeda = 0;
  double _valorTotal = 0;
  bool _comodato = false;
  bool _locacao = false;
  String _observacoes = '';
  
  final formKey = GlobalKey<FormState>();
  TextEditingController _itemDescricaoController = new TextEditingController();
  TextEditingController _quantidadeController = new TextEditingController();
  FocusNode _focusQuantidade = new FocusNode();
  TextEditingController _unidadeController = new TextEditingController();
  var _valorController = new MoneyMaskedTextController();
  FocusNode _focusValorUnitario = new FocusNode();
  TextEditingController _descontoPorcentagemController = new TextEditingController();
  FocusNode _focusDescontoPorcentagem = new FocusNode();
  var _descontoMoedaController = new MoneyMaskedTextController();
  FocusNode _focusDescontoMoeda = new FocusNode();
  TextEditingController _observacoesController = new TextEditingController();
  var _valorTotalController = new MoneyMaskedTextController();


  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context)
      .then((value)  {
        if(widget.item != null) {
          _valorController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.item.prUnitario);

          _descontoMoedaController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.item.vlrDesc / widget.item.quantidade);

          _valorTotalController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.item.vlrTotComDesc);
        }
        else {
          _valorController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ');

          _descontoMoedaController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ');

          _valorTotalController = new MoneyMaskedTextController(leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} ');
        }
      });
    _atribuiTipos();
    _preencheItemEditar();
    _descontoPorcentagem = widget.item != null ? widget.item.percDesc : 0;
    _descontoMoeda = widget.item != null ? widget.item.vlrDesc / widget.item.quantidade : 0;
    _focusDescontoPorcentagem.addListener(_onFocusChangeDescontoPorcentagem);
    _focusDescontoMoeda.addListener(_onFocusChangeDescontoMoeda);
    _focusValorUnitario.addListener(_onFocusChangeValorUnitario);
    _focusQuantidade.addListener(_onFocusChangeQuantidade);
  }

  _preencheItemEditar() {
    if(widget.item != null) {
      _item = widget.item;
      _quantidade = _item.quantidade;
      _unidadeDeMedida = _item.unidadeMedida;
      _valorUnitario = _item.prUnitario;
      _descontoPorcentagem = _item.percDesc;
      _descontoMoeda = _item.vlrDesc / _quantidade;
      _valorTotal = _item.vlrTotComDesc;
      _comodato = _item.comodato;
      _locacao = _item.locacaoBens;

      _calculaDescontoValor(_descontoMoeda);

      _itemDescricaoController.text = _item.produto;
      _quantidadeController.text = _quantidade.toStringAsFixed(2);
      _unidadeController.text = _unidadeDeMedida;
      _descontoPorcentagemController.text = _descontoPorcentagem.toStringAsFixed(3);
    }
  }

  String _preencheTitulo() {
    if (widget.item != null) {
      switch (widget.tipo) {
        case TiposItensTabBarConstante.PRODUTOS:
          return _locate.locale[TraducaoStringsConstante.EditarProduto];
          break;
        case TiposItensTabBarConstante.SERVICOS:
          return _locate.locale[TraducaoStringsConstante.EditarServico];
          break;
        case TiposItensTabBarConstante.RECEITAS:
          return _locate.locale[TraducaoStringsConstante.EditarReceita];
          break;
        default:
          return _locate.locale[TraducaoStringsConstante.EditarProduto];
      }
    }
    else {
      switch (widget.tipo) {
        case TiposItensTabBarConstante.PRODUTOS:
          return _locate.locale[TraducaoStringsConstante.AdicionarProduto];
          break;
        case TiposItensTabBarConstante.SERVICOS:
          return _locate.locale[TraducaoStringsConstante.AdicionarServico];
          break;
        case TiposItensTabBarConstante.RECEITAS:
          return _locate.locale[TraducaoStringsConstante.AdicionarReceita];
          break;
        default:
          return _locate.locale[TraducaoStringsConstante.AdicionarProduto];
      }
    }
  }

  String _preencheTituloBotao() {
    if (widget.item != null) {
      switch (widget.tipo) {
        case TiposItensTabBarConstante.PRODUTOS:
          return _locate.locale[TraducaoStringsConstante.SalvarProduto];
          break;
        case TiposItensTabBarConstante.SERVICOS:
          return _locate.locale[TraducaoStringsConstante.SalvarServico];
          break;
        case TiposItensTabBarConstante.RECEITAS:
          return _locate.locale[TraducaoStringsConstante.SalvarReceita];
          break;
        default:
          return _locate.locale[TraducaoStringsConstante.SalvarProduto];
      }
    }
    else {
      switch (widget.tipo) {
        case TiposItensTabBarConstante.PRODUTOS:
          return _locate.locale[TraducaoStringsConstante.AdicionarProduto];
          break;
        case TiposItensTabBarConstante.SERVICOS:
          return _locate.locale[TraducaoStringsConstante.AdicionarServico];
          break;
        case TiposItensTabBarConstante.RECEITAS:
          return _locate.locale[TraducaoStringsConstante.AdicionarReceita];
          break;
        default:
          return _locate.locale[TraducaoStringsConstante.AdicionarProduto];
      }
    }
  }

  _atribuiTipos() {
    switch (widget.tipo) {
      case TiposItensTabBarConstante.PRODUTOS:
        setState(() {
          tipos = [1,9,13];
        });
        break;
      case TiposItensTabBarConstante.SERVICOS:
        setState(() {
          tipos = [10];
        });
        break;
      case TiposItensTabBarConstante.RECEITAS:
        setState(() {
          tipos = [10];
        });
        break;
      default:
        setState(() {
          tipos = [1,9,13];
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_preencheTitulo()),
            ),
            body: _formItem(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _formItem() {
    return Form(
      key: formKey,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _selecaoItem(),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _quantidadeController,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.Quantidade]),
              // enabled: _produtoSelecionado.id != null,
              onSaved: (input) {
                _quantidade = double.parse(input);
              },
              validator: (input) {
                if (input.isEmpty || input == 0.toString()) {
                  return _locate.locale[TraducaoStringsConstante.QuantidadeNaoZero];
                }
                else {
                  return null;
                }
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (input) {
                setState(() {
                  _quantidade = double.parse(input);
                  _valorTotal = _quantidade * (_valorUnitario - _descontoMoeda);
                });
                _valorTotalController.updateValue(_valorTotal);
              },
              focusNode: _focusQuantidade,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _unidadeController,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.UnidadeDeMedida]),
              onSaved: (input) {
                _unidadeDeMedida = input;
              },
              enabled: false,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _valorController,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.ValorUnitario]),
              // enabled: _produtoSelecionado.id != null,
              onSaved: (input) {
                _valorUnitario = double.parse(input);
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              focusNode: _focusValorUnitario,
              onChanged: (input) {
                setState(() {
                  _valorUnitario = _valorController.numberValue;
                  _valorTotal = (_valorUnitario - _descontoMoeda) * _quantidade;
                  _valorTotalController.updateValue(_valorTotal);
                });
                _calculaDescontoValor(_descontoMoedaController.numberValue);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _descontoPorcentagemController,
              enabled: _comodato == false,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.DescontoPorcentagem]),
              onSaved: (input) {
                _descontoPorcentagem = double.parse(input);
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              focusNode: _focusDescontoPorcentagem,
              onChanged: (input) {
                _calculaDescontoPorcentagem(double.parse(input));
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _descontoMoedaController,
              enabled: _comodato == false,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.DescontoMoeda]),
              onSaved: (input) {
                _descontoMoeda = double.parse(input);
              },
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              focusNode: _focusDescontoMoeda,
              onChanged: (input) {
                _calculaDescontoValor(_descontoMoedaController.numberValue);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLines: 4,
              controller: _observacoesController,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.Observacoes]),
              onSaved: (input) {
                _observacoes = input;
              },
            ),
          ),

          Visibility(
            visible: widget.possuiComodato,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Texto(_locate.locale[TraducaoStringsConstante.Comodato]),
                  Checkbox(
                    value: _comodato,
                    onChanged: (bool comodato){
                      double porcento = 0;
                      setState(() {
                        _comodato = comodato;
                        if (_comodato == true) {
                          _descontoMoeda = _valorUnitario;
                          porcento = 100;
                        }
                        else {
                          _descontoMoeda = 0;
                          porcento = 0;
                        }
                      });
                      _descontoMoedaController.updateValue(_descontoMoeda);
                    }
                  )
                ],
              ),
            ),
          ),

          Visibility(
            visible: widget.possuiLocacao,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Texto(_locate.locale[TraducaoStringsConstante.Locacao]),
                  Checkbox(
                    value: _locacao,
                    onChanged: (bool locacao){
                      setState(() {
                        _locacao = locacao;
                      });
                    }
                  )
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _valorTotalController,
              enabled: false,
              decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.ValorTotal]),
              onSaved: (input) {
                _valorTotal = _valorTotalController.numberValue;
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _botaoAdicionarItem(
              texto: _preencheTituloBotao(),
              funcao: () {
                if (_submit() == true) {
                  Navigator.pop(context, _item);
                }
              }
            ),
          ),
        ],
      )
    );
  }

  Widget   _selecaoItem() {
    return CampoFormularioTextoSelecao(
      controller: _itemDescricaoController,
      label: _locate.locale[TraducaoStringsConstante.SelecioneItem],
      validacaoMensagem: _locate.locale[TraducaoStringsConstante.SelecioneItemValidacao],
      funcao: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListaProdutosModalComponente(tipos: tipos,))
        );
        _produtoSelecionado = resultado;
        _preencheItemNovo(_produtoSelecionado);
      },
      funcaoSave: (_) => _item.id = _produtoSelecionado.id
    );
  }

  _preencheItemNovo(Produto produto) {
    if (produto != null) {
      _itemDescricaoController.text = produto.descricaoResumida ?? '';
      _quantidadeController.text = 1.toString();
      _unidadeController.text = produto.unidadeMedida ?? '';
      _valorController.updateValue(produto.valorVenda ?? 0);
      _descontoPorcentagemController.text = 0.toStringAsFixed(2);
      _descontoMoedaController.updateValue(0);
      _valorTotalController.updateValue(produto.valorVenda ?? 0);

      _descontoPorcentagem = 0;
      _descontoMoeda = 0;
      _quantidade = 1;
      _unidadeDeMedida = produto.unidadeMedida;
      _valorUnitario = produto.valorVenda;
      _valorTotal = (produto.valorVenda ?? 0) * 1;
      if (widget.possuiLocacao) {
        setState(() {
          _locacao = produto.locacaoBens;
        });
      }
      else {
        setState(() {
          _locacao = false;
        });
      }

      _item.produto = produto.descricao;
      _item.quantidade = 1;
      _item.unidadeMedida = produto.unidadeMedida;
      _item.prUnitario = produto.valorVenda;
      _item.percDesc = 0;
      _item.vlrDesc = 0;
      _item.vlrTotal = produto.valorVenda;
      _item.vlrTotComDesc = produto.valorVenda;
      if (widget.possuiLocacao) {
        _item.locacaoBens = produto.locacaoBens;
      }
      else {
        _item.locacaoBens = false;
      }
    }
    else {
      _itemDescricaoController.clear();
      _quantidadeController.clear();
      _unidadeController.clear();
      _valorController.clear();
      _descontoPorcentagemController.clear();
      _descontoMoedaController.clear();
      _valorTotalController.clear();
    }
  }

  _onFocusChangeQuantidade() {
    if (!_focusQuantidade.hasFocus) {
      if(_quantidadeController.text.isEmpty) {
        _quantidadeController.text = 1.toString();
      }
      else {
        double quant = double.parse(_quantidadeController.text);
        if (quant % 1 != 0) {
          _quantidadeController.text = quant.toStringAsFixed(2);
        }
        else {
          _quantidadeController.text = quant.toString();
        }
      }

      setState(() {
        _quantidade = double.parse(_quantidadeController.text);
        _valorTotal = _quantidade * (_valorUnitario - _descontoMoeda);
      });
      _valorTotalController.updateValue(_valorTotal);
    }
    else {
      _quantidadeController.selection = TextSelection.fromPosition(TextPosition(offset: _quantidadeController.text.length));
    }
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
    if (porcentagem > 100) {
      porcentagem = 100;
      _descontoPorcentagem = 100;
      _descontoPorcentagemController.text = porcentagem.toStringAsFixed(3);
    }
    if (porcentagem < 0) {
      porcentagem = 0;
      _descontoPorcentagem = 0;
      _descontoPorcentagemController.text = porcentagem.toStringAsFixed(3);
    }
    if (_comodato == true) {
      porcentagem = 100;
    }
    else {
      if (porcentagem == 100) {
        porcentagem = 0;
      }
    }
    _descontoPorcentagem = porcentagem;
    setState(() {
      _descontoMoeda = _valorUnitario * (0.01 * porcentagem);
    });
    _descontoMoedaController.updateValue(_descontoMoeda);
    _valorTotal = (_valorUnitario - _descontoMoeda) * _quantidade;
    _valorTotalController.updateValue(_valorTotal);
  }

  _onFocusChangeValorUnitario() {
    if (!_focusValorUnitario.hasFocus) {
      setState(() {
        _valorUnitario = _valorController.numberValue;
        _valorTotal = (_valorUnitario - _descontoMoeda) * _quantidade;
        _valorTotalController.updateValue(_valorTotal);
      });
      _calculaDescontoValor(_descontoMoedaController.numberValue);
    }
  }

  _onFocusChangeDescontoMoeda() {
    if (!_focusDescontoMoeda.hasFocus) {
      _calculaDescontoValor(_descontoMoedaController.numberValue);
    }
  }

  _calculaDescontoValor(double valor) {
    if (valor > _valorUnitario) {
      valor = _valorUnitario;
      _descontoMoeda = _item.prUnitario;
      _descontoMoedaController.updateValue(valor);
    }
    if (valor < 0) {
      valor = 0;
      _descontoMoeda = 0;
      _descontoMoedaController.updateValue(valor);
    }
    _descontoMoeda = valor;
    _valorTotal = (_valorUnitario - _descontoMoeda) * _quantidade;
    setState(() {
      _descontoPorcentagem = (100 * valor) / _valorUnitario;
      if(_descontoPorcentagem.isNaN) {
        _descontoPorcentagem = 0;
      }
    });
    _descontoPorcentagemController.text = _descontoPorcentagem.toStringAsFixed(3);
    _valorTotalController.updateValue(_valorTotal);
  }

  bool _submit() {
    if(formKey.currentState.validate()) {
      if (widget.item != null) {
        if (widget.item.id != null) {
          _item.id = widget.item.id;
        }
      }
      if (widget.item == null) {
        _item.produtoId = _produtoSelecionado.id;
        _item.produto = _produtoSelecionado.descricao;
      }
      _item.tipo = widget.tipo;
      _item.comodato = _comodato;
      _item.locacaoBens = _locacao;
      _item.percDesc = _descontoPorcentagem;
      _item.quantidade = _quantidade;
      _item.unidadeMedida = _unidadeDeMedida;
      _item.vlrDesc = _descontoMoeda * _quantidade;
      _item.vlrTotal = _valorTotal + (_descontoMoeda * _quantidade);
      if (_comodato == true) {
        _item.vlrTotComDesc = 0;
      }
      else {
        _item.vlrTotComDesc = _valorTotal;
      }
      _item.prUnitComDesc = _valorUnitario - _descontoMoeda;
      _item.prUnitario = _valorUnitario;
      return true;
    }
    else {
      return false;
    }
  }

  Widget _botaoAdicionarItem({@required String texto, Function funcao}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 32,
        child: SizedBox.expand(
          child: FlatButton(
            onPressed: funcao ?? () {},
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
