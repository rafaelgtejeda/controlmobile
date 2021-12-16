import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/produtos-modal/lista-produtos-modal.componente.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart' as lookup;
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/ordem-servico/material-servico.servicos.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelecionaMateriaisServicosTela extends StatefulWidget { 
  
  final int osId;
  final MaterialServicoSave materialServico;
  final int empresaIdOS;

  const SelecionaMateriaisServicosTela({Key key, this.osId, this.materialServico, this.empresaIdOS}) : super(key: key);
  @override
  _SelecionaMateriaisServicosTelaState createState() => _SelecionaMateriaisServicosTelaState();

}

class _SelecionaMateriaisServicosTelaState extends State<SelecionaMateriaisServicosTela> {
  
                   LocalizacaoServico _locale = new LocalizacaoServico();
  RequestUtil _requestUtil = new RequestUtil();
           DiretivasAcessosService _diretivas = new DiretivasAcessosService();

  TextEditingController _itemDescricaoController = new TextEditingController();

  TextEditingController _quantidadeController = new TextEditingController();
                   FocusNode _focusQuantidade = new FocusNode();

     TextEditingController _unidadeController = new TextEditingController();

       var _valorController = new MoneyMaskedTextController();

             lookup.Produto materialServicoSelecionado = new lookup.Produto();
      
                               final _formKey = GlobalKey<FormState>();
                               bool _autoValidacao = false;
                               final _scaffoldKey = GlobalKey<ScaffoldState>();

                                Helper helper = new Helper();
            MaterialServicoSave _materialSave = new MaterialServicoSave();
  
  int osID;
  double _valorUnitario = 0;
  double _total = 0;
  String _unidadeDeMedida = '';
  double _quantidade = 0;

  bool _cobrar = false;
  bool _locacao = false;
  bool _habilitaLocacao = false;

  _SelecionaMateriaisServicosTelaState(){
    // _streamMS = Stream.fromFuture(_fazRequest());
  }

  @override
  void initState() { 
    super.initState();
     osID = widget.osId;
    _locale.iniciaLocalizacao(context)
      .then((value) {
        if (widget.materialServico == null) {
          _valorController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');
        }
        else {
          _valorController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.materialServico.valor ?? 0);
        }
      });
    _diretivas.iniciaDiretivas();
    _fazRequestObtemGeraFinanceiro()
      .then((value) => _cobrar = value);
    _preencheItemEditar();
  }

  Future<bool> _fazRequestObtemGeraFinanceiro() async {
    OSConfigMaterial osConfigMaterial = new OSConfigMaterial();
    dynamic getOSConfig = await OrdemServicoService().getOSConfigMaterial(osId: widget.osId);
    if(getOSConfig is !OSConfigMaterial) {
      return false;
    }
    else {
      osConfigMaterial = OSConfigMaterial.fromJson(getOSConfig);
      return osConfigMaterial.cobrar;
    }
  }

  _preencheItemEditar() {
    if(widget.materialServico != null) {
      _materialSave = widget.materialServico;
      _quantidade = _materialSave.quantidade;
      _unidadeDeMedida = _materialSave.unidadeMedida;
      _valorUnitario = _materialSave.valor;
      _total = _materialSave.valor * _materialSave.quantidade;
      _cobrar = _materialSave.cobrar;
      if (widget.materialServico.produtoTipo == ProdutoTipoConstante.SERVICOS) {
        _habilitaLocacao = true;
        if (_materialSave.locacao == null) {
          _locacao = false;
        }
        else {
          _locacao = _materialSave.locacao;
        }
      }
      else {
        _locacao = false;
        _habilitaLocacao = false;
      }
      materialServicoSelecionado.id = _materialSave.produtoId;

      _itemDescricaoController.text = _materialSave.descricao;
      _quantidadeController.text = _quantidade.toStringAsFixed(2);
      _unidadeController.text = _unidadeDeMedida;
    }
  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      exibirOffline: true,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Container(
            // chama o scafold
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                elevation: 0,
                 title: Text(_locale.locale[TraducaoStringsConstante.Materiais].toUpperCase()),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _getMateriaisServicos(),
                    _painel()
                  ],
                ),
              ),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            ),
          );
        },
      ),
    );
  }

  Widget _painel() {
    return Column(
      children: <Widget>[
        Container(
          child: Column(
            children: <Widget>[
              SizedBox(height: 12.0),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 81,
                    height: 2,
                    decoration: BoxDecoration(
                    color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))
                    ),
                  ),
                ],
              ),

              Visibility(
                visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarValorMaterialServico,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 20, bottom: 0, right: 20),
                  child: Column(
                    children: <Widget>[

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          
                          Align(alignment: Alignment.centerLeft, child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0), child: Text(
                              '${_locale.locale[TraducaoStringsConstante.ValorUnitario]}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                          )),

                          Align(alignment: Alignment.centerRight, child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0),
                            child: Text(
                              helper.dinheiroFormatter(_valorUnitario),
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                            ),
                            )
                          ),

                        ],
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          
                          Align(alignment: Alignment.centerLeft, child: Padding(
                            padding: EdgeInsets.only(bottom:8.0), child: Text('${_locale.locale[TraducaoStringsConstante.Total]}: ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          )),

                          Align(alignment: Alignment.centerRight, child: Padding(
                            padding: const EdgeInsets.only(bottom:8.0), child: Text(
                              helper.dinheiroFormatter(_total),
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)
                            ),
                            )
                          ),

                        ],
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        FadeInUp(3, _btnAdicionarALista()),

      ],
    );
  }

  _calculaValoresPainel() {
    setState(() {
      _total = _valorController.numberValue * double.parse(_quantidadeController.text);
    });
  }

  _preencheItemNovo(lookup.Produto produto) {
    if (produto != null) {
      _itemDescricaoController.text = produto.descricaoResumida ?? '';
      _quantidadeController.text = 1.toStringAsFixed(2);
      _unidadeController.text = produto.unidadeMedida ?? '';
      _valorController.updateValue(produto.valorVenda ?? 0);

      _quantidade = 1;
      _unidadeDeMedida = produto.unidadeMedida;
      _valorUnitario = produto.valorVenda;
      if (produto.tipo == ProdutoTipoConstante.SERVICOS) {
        setState(() {
          _habilitaLocacao = true;
          _locacao = produto.locacaoBens;
        });
      }
      else {
        _habilitaLocacao = false;
        _locacao = false;
      }

      // _materialSave.cobrar = _cobrar;
      // _materialSave.osId = widget.osId;
      _materialSave.descricao = produto.descricao;
      _materialSave.descricaoResumida = produto.descricaoResumida;
      _materialSave.produtoId = produto.id;
      _materialSave.unidadeMedida = produto.unidadeMedida;
      _materialSave.valor = produto.valorVenda;
      _materialSave.quantidade = 1;
    }
    else {
      _itemDescricaoController.clear();
      _quantidadeController.clear();
      _unidadeController.clear();
      _valorController.clear();
    }
    setState(() {
      _valorUnitario = materialServicoSelecionado.valorVenda;
      _total = materialServicoSelecionado.valorVenda * 1;
    });
  }

  Widget _getMateriaisServicos(){

    return Form(
        key: _formKey,
        autovalidate: _autoValidacao,
        child: Column(
        children: <Widget>[

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: CampoFormularioTextoSelecao(
              controller: _itemDescricaoController,
              label: _locale.locale[TraducaoStringsConstante.SelecioneMaterialServico],
              validacaoMensagem: _locale.locale[TraducaoStringsConstante.SelecioneMaterialServicoValidacao],
              funcao: () async {
                final resultado = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListaProdutosModalComponente(
                    tipos: [1, 9, 10, 13],
                    empresaIdOverride: widget.empresaIdOS,
                  ))
                );
                materialServicoSelecionado = resultado;
                _preencheItemNovo(materialServicoSelecionado);
              },
              funcaoSave: (_) => _materialSave.produtoId = materialServicoSelecionado.id
            ),
          ),

            FadeInUp(1, 
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          
                          Align(alignment: Alignment.centerRight, 
                          child: Padding(
                            padding: const EdgeInsets.only(bottom:0.0),

                              child: TextFormField(
                              controller: _quantidadeController,
                              decoration: InputDecoration(
                                labelText: "${_locale.locale[TraducaoStringsConstante.Quantidade]} em $_unidadeDeMedida",
                                border: OutlineInputBorder(),
                              ),

                                keyboardType: TextInputType.number,

                                onChanged: (input) {
                                   _calculaValoresPainel();
                                },

                                )

                            )

                          ),

                        ],

                      ),
              ),
           ),

           Visibility(
             visible: _diretivas.diretivasDisponiveis.ordemServico.possuiVisualizarValorMaterialServico,
             child: FadeInUp(2, 

                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[

                           Align(alignment: Alignment.centerRight,

                            child: Padding(
                              padding: const EdgeInsets.only(bottom:0.0),
                                child: TextFormField(
                                  controller: _valorController,
                                  decoration: InputDecoration(
                                  labelText: _locale.locale[TraducaoStringsConstante.Valor],
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (input) {
                                  setState(() {
                                    _valorUnitario = _valorController.numberValue;
                                  });
                                  _calculaValoresPainel();
                                },
                                  )
                              )
                            ),

                          ],
                          
                        ),
                ),

             ),
           ),

          FadeInUp(
            3,
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_locale.locale[TraducaoStringsConstante.Cobrar], style: TextStyle(fontSize: 16)),
                  Checkbox(
                    value: _cobrar,
                    onChanged: (bool cobrar){
                      setState(() {
                        _cobrar = cobrar;
                      });
                    }
                  )
                ],
              ),
            )
          ),

          Visibility(
            visible: _habilitaLocacao,
            child: FadeInUp(
              3,
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(_locale.locale[TraducaoStringsConstante.Locacao], style: TextStyle(fontSize: 16)),
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
              )
            ),
          ),

        ],

      ),
    );

  
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  Widget _btnAdicionarALista(){
    return ButtonComponente(
      texto: _locale.locale[TraducaoStringsConstante.AdicionarALista],
      imagemCaminho: AssetsIconApp.ArrowLeftWhite, 
      backgroundColor: Colors.green, 
      textColor: Colors.white,
      somenteTexto: false,
      somenteIcone: false,
      ladoIcone: 'Direito',
      funcao: () async {
        if (_submit() == true) {
          if(await _salvar() == true) {
            Navigator.pop(context, true);
          }
        }
      }
    );
  }

  bool _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      _materialSave.cobrar = _cobrar;
      _materialSave.locacao = _locacao;
      _materialSave.descricao = materialServicoSelecionado.descricao;
      _materialSave.descricaoResumida = _itemDescricaoController.text;
      _materialSave.osId = widget.osId;
      _materialSave.produtoId = materialServicoSelecionado.id;
      _materialSave.unidadeMedida = _unidadeDeMedida;
      // _materialSave.valor = double.parse(_valorController.text);
      _materialSave.valor = _valorController.numberValue;
      _materialSave.quantidade = double.parse(_quantidadeController.text);
      
      return true;
    } else {
      setState(() {
        _showSnackBar(_locale.locale[TraducaoStringsConstante.PreenchaCamposObrigatorios]);
        _autoValidacao = true;
      });
      return false;
    }
  }

  Future<bool> _salvar() async {
    bool resultado = false;

    if (_materialSave.id == null) {
      String materialServicoJson = json.encode(_materialSave.novoMaterialServicoJson());
      if(!await _requestUtil.verificaOnline()) {
        bool request = await MarterialServicoService().adicionaMaterialServico(materialServico: materialServicoJson, context: context);
        resultado = request;
      }
      else {
        Response request = await MarterialServicoService().adicionaMaterialServico(materialServico: materialServicoJson, context: context);
        if (request.statusCode == 200) resultado = true;
        else resultado = false;
      }
      return resultado;
    } else {
      String materialServicoJson = json.encode(_materialSave.toJson());
      if(!await _requestUtil.verificaOnline()) {
        bool request = await MarterialServicoService().atualizaMaterialServico(materialServico: materialServicoJson, context: context);
        resultado = request;
      }
      else {
        Response request = await MarterialServicoService().atualizaMaterialServico(materialServico: materialServicoJson, context: context);
        if (request.statusCode == 200) resultado = true;
        else resultado = false;
      }
      return resultado;
    }
  }

}
