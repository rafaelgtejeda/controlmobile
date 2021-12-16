import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/produtos-modal/lista-produtos-modal.componente.dart';
import 'package:erp/models/cliente/parque-tecnologico/parque-tecnologico-editar.modelo.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:erp/utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CadastroParqueTecnologicoTela extends StatefulWidget {
  final ParqueEditar parqueTecnologico;
  final int parceiroId;
  final int empresaId;
  CadastroParqueTecnologicoTela({this.empresaId, this.parceiroId ,this.parqueTecnologico});
  @override
  _CadastroParqueTecnologicoTelaState createState() => _CadastroParqueTecnologicoTelaState();
}

class _CadastroParqueTecnologicoTelaState extends State<CadastroParqueTecnologicoTela> {
  ParqueEditar parqueEditar = new ParqueEditar();
  LocalizacaoServico _locale = new LocalizacaoServico();

  TextEditingController _produtoCodigoController = new TextEditingController();
  TextEditingController _produtoShowUpController = new TextEditingController();
  TextEditingController _equipamentoController = new TextEditingController();
  TextEditingController _descricaoProdutoController = new TextEditingController();
  TextEditingController _descricaoMarcaController = new TextEditingController();
  TextEditingController _descricaoModeloController = new TextEditingController();
  TextEditingController _numeroSerieController = new TextEditingController();
  TextEditingController _quantidadeController = new TextEditingController();
  TextEditingController _dataInstalacaoController = new TextEditingController();
  TextEditingController _observacaoController = new TextEditingController();

  Produto _produtoSelecionado = new Produto();

  String _equipamento, _descricaoProduto, _descricaoMarca,
      _descricaoModelo, _numeroSerie, _observacao;

  DateTime _dataInstalacao = DateTime.now();

  int _produtoId;
  double _quantidade;

  FocusNode _focusProdutoId = new FocusNode();
  FocusNode _focusEquipamento = new FocusNode();
  FocusNode _focusDescricaoProduto = new FocusNode();
  FocusNode _focusDescricaoMarca = new FocusNode();
  FocusNode _focusDescricaoModelo = new FocusNode();
  FocusNode _focusNumeroSerie = new FocusNode();
  FocusNode _focusQuantidade = new FocusNode();
  FocusNode _focusDataInstalacao = new FocusNode();
  FocusNode _focusObservacao = new FocusNode();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidacao = false;
  bool _textFieldEnabled = true;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);

    ParqueEditar parqueEdit = widget.parqueTecnologico;
    _dataInstalacaoController.text = DateFormat.yMd().format(DateTime.parse(_dataInstalacao.toString())) ?? '';
    _focusProdutoId.addListener(_onFocusChangeProduto);
    if (parqueEdit != null) {
      parqueEditar = parqueEdit;
      _buscaProdutoPorId(parqueEdit.produtoId);
      _equipamentoController.text = parqueEdit.descricaoEquipamento ?? '';
      _descricaoProdutoController.text = parqueEdit.descricaoProduto ?? '';
      _descricaoModeloController.text = parqueEdit.descricaoModelo ?? '';
      _numeroSerieController.text = parqueEdit.numeroDeSerie ?? '';
      _quantidadeController.text = parqueEdit.quantidade.toInt().toString() ?? '';
      _dataInstalacaoController.text = DateFormat.yMd().format(DateTime.parse(parqueEdit.dataInstalacao.toString())) ?? '';
      _observacaoController.text = parqueEdit.observacao ?? '';
    }
    else { }
  }

  void _onFocusChangeProduto() {
    if (_focusProdutoId.hasFocus) {} else {
      _buscaProdutoPorCodigo(_produtoCodigoController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(widget.parqueTecnologico == null
                ? _locale.locale['CadastroParque']
                : _locale.locale['EditarParque']),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  tooltip: _locale.locale['SalvarParque'],
                )
              ],
            ),
            body: CustomOfflineWidget(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Form(
                  key: formKey,
                  autovalidate: _autoValidacao,
                  child: Column(
                    children: <Widget>[
                      _parqueTecnologicoForm(),
                      ButtonComponente(
                        funcao: () async {
                          if (_submit() == true) {
                            if(await _salvar() == true) {
                              Navigator.pop(context, true);
                            }
                          }
                        },
                        ladoIcone: 'Esquerdo',
                        imagemCaminho: AssetsIconApp.Add,
                        somenteTexto: true,
                        somenteIcone: false,
                        texto: _locale.locale['Salvar'],
                        backgroundColor: Colors.blue,
                        textColor: Colors.white
                      )
                    ],
                  )
                ),
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        },
      ),
    );
  }

  Widget _parqueTecnologicoForm() {
    return Column(
      children: <Widget>[
        // Produto Id e Descrição
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                focusNode: _focusProdutoId,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                controller: _produtoCodigoController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Codigo']}",
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (input) {
                  _buscaProdutoPorCodigo(input);
                  _fieldFocusChange(
                    context, _focusProdutoId, _focusEquipamento
                  );
                },
                onSaved: (input) {
                  _produtoId = _produtoSelecionado.id;
                },
              ),
            ),
            SizedBox(width: 15,),
            Flexible(
              flex: 5,
              child: TextFormField(
                keyboardType: TextInputType.text,
                readOnly: true,
                controller: _produtoShowUpController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Produto']}",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  _selecionarProduto();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _equipamentoController,
          focusNode: _focusEquipamento,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Equipamento']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusEquipamento, _focusDescricaoProduto);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _equipamento = Validators().fieldFilledValidator(input, _equipamento),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _descricaoProdutoController,
          focusNode: _focusDescricaoProduto,
          decoration: InputDecoration(
            labelText: "${_locale.locale['DescricaoProduto']}",
            border: OutlineInputBorder(),
          ),
          enabled: _textFieldEnabled,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusDescricaoProduto, _focusDescricaoMarca);
          },
          validator: (input) {
            if (input.isEmpty) {
              return _locale.locale['PreenchaDescricaoProduto'];
            }
            else {
              return null;
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _descricaoProduto = Validators().fieldFilledValidator(input, _descricaoProduto),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _descricaoMarcaController,
          focusNode: _focusDescricaoMarca,
          decoration: InputDecoration(
            labelText: "${_locale.locale['DescricaoMarca']}",
            border: OutlineInputBorder(),
          ),
          enabled: _textFieldEnabled,
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusDescricaoMarca, _focusDescricaoModelo);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _descricaoMarca = Validators().fieldFilledValidator(input, _descricaoMarca),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _descricaoModeloController,
          focusNode: _focusDescricaoModelo,
          decoration: InputDecoration(
            labelText: "${_locale.locale['DescricaoModelo']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusDescricaoModelo, _focusNumeroSerie);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _descricaoModelo = Validators().fieldFilledValidator(input, _descricaoModelo),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _numeroSerieController,
          focusNode: _focusNumeroSerie,
          decoration: InputDecoration(
            labelText: "${_locale.locale['NumeroSerie']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusNumeroSerie, _focusQuantidade);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _numeroSerie = Validators().fieldFilledValidator(input, _numeroSerie),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _quantidadeController,
          focusNode: _focusQuantidade,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Quantidade']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusQuantidade, _focusObservacao);
          },
          validator: (input) {
            if (input == '0' || input.isEmpty) {
              return _locale.locale['QuantidadeNaoZero'];
            }
            else {
              return null;
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _quantidade = double.parse(input),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _dataInstalacaoController,
          focusNode: _focusDataInstalacao,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "${_locale.locale['DataInstalacao']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.datetime,
          onTap: () {_selecionaDataInstalacao(context);},
          validator: (input) {
            if (input.isEmpty) {
              return _locale.locale['PreenchaData'];
            }
            else {
              return null;
            }
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _observacao = Validators().fieldFilledValidator(input, _observacao),
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _observacaoController,
          focusNode: _focusObservacao,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Observacao']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          onSaved: (input) => _observacao = Validators().fieldFilledValidator(input, _observacao),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  Future<Null> _selecionaDataInstalacao(BuildContext context) async {
    final DateTime dataSelecionada = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataInstalacao
    );

    if (dataSelecionada != null && dataSelecionada != _dataInstalacao) {
      setState(() {
        _dataInstalacao = dataSelecionada;
        _dataInstalacaoController.text = DateFormat.yMd().format(DateTime.parse(_dataInstalacao.toString()));
      });
    }
  }

  _selecionarProduto() async {
    final produto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListaProdutosModalComponente(
        tipos: [1, 9, 10, 13],
      )),
    );
    _preencheProduto(produto: produto);
  }

  _buscaProdutoPorCodigo(String codigo) async {
    if (codigo.isEmpty) {
      _preencheProduto(produto: null);
    }
    else {
      CarregandoAlertaComponente().showCarregar(context);
      dynamic requestProduto = await ClienteService().parque.produto.buscaProdutoCodigo(empresaId: widget.empresaId
      , produtoCodigo: codigo);
      ProdutoLookUp resultado = ProdutoLookUp.fromJson(requestProduto);
      if (resultado.lista.length > 0) {
        Produto produto = resultado.lista[0];
        _preencheProduto(produto: produto);
      }
      else {
        _preencheProduto(produto: null);
      }
      CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  _buscaProdutoPorId(int id) async {
    if (id.isNaN) {
      return null;
    }
    else {
      // CarregandoAlertaComponente().showCarregar(context);
      dynamic requestProduto = await ClienteService().parque.produto.buscaProdutoId(empresaId: widget.empresaId
      , produtoId: id);
      ProdutoLookUp resultado = ProdutoLookUp.fromJson(requestProduto);
      if (resultado.lista.length > 0) {
        Produto produto = resultado.lista[0];
        _preencheProduto(produto: produto);
      }
      else {
        _preencheProduto(produto: null);
      }
      // CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  _preencheProduto({Produto produto}) {
    if (produto != null) {
      setState(() {
        _textFieldEnabled = false;
        _produtoCodigoController.text = produto.codigo ?? '';
        _produtoShowUpController.text = produto.descricaoResumida ?? '';
        _descricaoProdutoController.text = produto.descricao ?? '';
        _descricaoMarcaController.text = produto.marca ?? '';
      });
    }
    else {
      setState(() {
        _textFieldEnabled = true;
        _produtoCodigoController.clear();
        _produtoShowUpController.clear();
        _descricaoProdutoController.clear();
        _descricaoMarcaController.clear();
      });
    }
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  bool _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      parqueEditar.parceiroId = widget.parceiroId;
      parqueEditar.empresaId = widget.empresaId;
      parqueEditar.produtoId = _produtoId;

      parqueEditar.descricaoEquipamento = _equipamento ?? '';
      parqueEditar.descricaoProduto = _descricaoProduto ?? '';
      parqueEditar.descricaoMarca = _descricaoMarca ?? '';

      parqueEditar.descricaoModelo = _descricaoModelo ?? '';
      parqueEditar.numeroDeSerie = _numeroSerie ?? '';
      parqueEditar.quantidade = _quantidade ?? 0;

      parqueEditar.dataInstalacao = _dataInstalacao.toString() ?? '';
      parqueEditar.observacao = _observacao ?? '';
      
      return true;
    } else {
      setState(() {
        _showSnackBar(_locale.locale['PreenchaCamposObrigatorios']);
        _autoValidacao = true;
      });
      return false;
    }
  }

  Future<bool> _salvar() async {
    // Tratar Cadastro Clientes
    bool resultado;
    if (parqueEditar.id == null) {
      String parqueJson = json.encode(parqueEditar.novoParqueTecnologicoJson());
      Response request = await ClienteService().parque.adicionarParqueTecnologico(parque: parqueJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String parqueJson = json.encode(parqueEditar.toJson());
      Response request = await ClienteService().parque.editarParqueTecnologico(parque: parqueJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
