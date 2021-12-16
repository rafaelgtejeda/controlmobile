import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/select-combobox.componente.dart';
import 'package:erp/models/lookUp/forma-pagamento-lookup.modelo.dart';
import 'package:erp/models/orcamento/informacao-parcela-get.modelo.dart';
import 'package:erp/models/orcamento/informacao-parcela-send.modelo.dart';
import 'package:erp/servicos/cliente/lookup/formaPagamento.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/orcamento/orcamento.servicos.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:provider/provider.dart';

class CadastroPagamentoModal extends StatefulWidget {
  final double valor;
  final int parceiroId;
  CadastroPagamentoModal({Key key, this.valor, this.parceiroId}) : super(key: key);
  @override
  _CadastroPagamentoModalState createState() => _CadastroPagamentoModalState();
}

class _CadastroPagamentoModalState extends State<CadastroPagamentoModal> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  final formKey = GlobalKey<FormState>();
  Stream<dynamic> _streamComboBoxFormasPagamento;
  int _empresaId;
  RequestUtil requestUtil = new RequestUtil();

  List<FormaPagamentoLookup> _listaFormasECondicoes = new List<FormaPagamentoLookup>();

  List<SelectComboBox> _formasPagamento = new List<SelectComboBox>();
  List<DropdownMenuItem<SelectComboBox>> _dropDownFormasPagamento;
  SelectComboBox _formaPagamentoSelecionada;

  List<SelectComboBox> _condicoesPagamento = new List<SelectComboBox>();
  List<DropdownMenuItem<SelectComboBox>> _dropDownCondicoesPagamento;
  SelectComboBox _condicaoPagamentoSelecionada;

  var _valorController = new MoneyMaskedTextController();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context)
      .then((value) => _valorController = new MoneyMaskedTextController(initialValue: widget.valor, leftSymbol: '${_locate.locale[TraducaoStringsConstante.MoedaLocal]} '));
    _streamComboBoxFormasPagamento = Stream.fromFuture(_populaComboBoxFormaPagamento());
    _obtemEmpresaId();
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.CadastroFormaPagamento]),
            ),
            body: CustomOfflineWidget(
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    _buildComboBoxFormaPagamento(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        decoration: CampoTextoDecoration(label: _locate.locale[TraducaoStringsConstante.Valor]),
                        controller: _valorController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    _botaoAdicionarPagamento(),
                    // _buildComboBoxCondicaoPagamento(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<List<SelectComboBox>> _populaComboBoxFormaPagamento() async {

    dynamic requestFormasPagamento = await FormasPagamentoService().listaFormasOrcamento(parceiroId: widget.parceiroId, tipoRetorno: 2);
    requestFormasPagamento.forEach((data) {
      _listaFormasECondicoes.add(FormaPagamentoLookup.fromJson(data));
    });

    _formasPagamento.clear();
    for(FormaPagamentoLookup item in _listaFormasECondicoes) {
      _formasPagamento.add(SelectComboBox(codigo: item.id, descricao: item.descricao));
    }
    
    _dropDownFormasPagamento = getDropDownItensComboBox(_formasPagamento);
    // _formaPagamentoSelecionada = _dropDownFormasPagamento[0].value;
    alteraFormaSelecionada(_dropDownFormasPagamento[0].value);
    // _dropDownCondicoesPagamento = getDropDownItensComboBox(_listaFormasECondicoes[0].condicoes);
    // _condicaoPagamentoSelecionada = _dropDownCondicoesPagamento[0].value;
    return _formasPagamento;
  }

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensComboBox(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  Widget _buildComboBoxFormaPagamento() {
    return StreamBuilder(
      stream: _streamComboBoxFormasPagamento,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return _dafaultComboBox();
        }
        else {
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return _dafaultComboBox();
            default:
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Texto("${_locate.locale[TraducaoStringsConstante.FormaPagamento]}:")
                        ),
                        // SizedBox(width: 16,),
                        Flexible(
                          flex: 1,
                          child: DropdownButton(
                            isExpanded: true,
                            value: _formaPagamentoSelecionada,
                            items: _dropDownFormasPagamento,
                            onChanged: alteraFormaSelecionada,
                          ),
                        )
                        // Expanded(
                        //   child: DropdownButton(
                        //     isExpanded: true,
                        //     value: _formaPagamentoSelecionada,
                        //     items: _dropDownFormasPagamento,
                        //     onChanged: alteraFormaSelecionada,
                        //   ),
                        // )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: Texto("${_locate.locale[TraducaoStringsConstante.CondicaoPagamento]}:")
                        ),
                        // SizedBox(width: 16,),
                        Flexible(
                          flex: 1,
                          child: DropdownButton(
                            isExpanded: true,
                            value: _condicaoPagamentoSelecionada,
                            items: _dropDownCondicoesPagamento,
                            onChanged: alteraCondicaoSelecionada,
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
          }
        }
      },
    );
  }

  Widget _dafaultComboBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Texto("${_locate.locale[TraducaoStringsConstante.FormaPagamento]}")
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 48,
                  child: DropdownButton(
                    items: [],
                    onChanged: (_) {},
                  ),
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                flex: 1,
                child: Texto("${_locate.locale[TraducaoStringsConstante.CondicaoPagamento]}")
              ),
              Flexible(
                flex: 1,
                child: Container(
                  height: 48,
                  child: DropdownButton(
                    items: [],
                    onChanged: (_) {},
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildComboBoxCondicaoPagamento() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text("${_locate.locale[TraducaoStringsConstante.CondicaoPagamento]}"),
        DropdownButton(
          value: _condicaoPagamentoSelecionada,
          items: _dropDownCondicoesPagamento,
          onChanged: alteraCondicaoSelecionada,
        )
      ],
    );
  }

  void alteraFormaSelecionada(SelectComboBox formaPagamentoSelecionada) {
    setState(() {
      _formaPagamentoSelecionada = formaPagamentoSelecionada;
    });
    int indice = 0;
    for(int i = 0; i < _dropDownFormasPagamento.length; i++) {
      if (_dropDownFormasPagamento[i].value == _formaPagamentoSelecionada) {
        indice = i;
        break;
      }
    }
    _condicoesPagamento.clear();
    for(Condicoes item in _listaFormasECondicoes[indice].condicoes) {
      _condicoesPagamento.add(SelectComboBox(codigo: item.id, descricao: item.descricao));
    }
    
    // _dropDownFormasPagamento = getDropDownItensComboBox(_condicoesPagamento);
    // _formaPagamentoSelecionada = _dropDownFormasPagamento[0].value;
    _dropDownCondicoesPagamento = getDropDownItensComboBox(_condicoesPagamento);
    // _condicaoPagamentoSelecionada = _dropDownCondicoesPagamento[0].value;
    if(_dropDownCondicoesPagamento.length != 0 ) {
      alteraCondicaoSelecionada(_dropDownCondicoesPagamento[0].value);
    }
    else {
      List<SelectComboBox> listaVazia = new List<SelectComboBox>();
      SelectComboBox itemVazio = new SelectComboBox();

      itemVazio.codigo = -1;
      itemVazio.descricao = '';

      listaVazia.add(itemVazio);

      _dropDownCondicoesPagamento = getDropDownItensComboBox(listaVazia);
      alteraCondicaoSelecionada(_dropDownCondicoesPagamento[0].value);
    }
  }

  void alteraCondicaoSelecionada(SelectComboBox condicaoPagamentoSelecionada) {
    setState(() {
      _condicaoPagamentoSelecionada = condicaoPagamentoSelecionada;
    });
  }

  _obtemEmpresaId() async {
    int empresa;
    empresa = await requestUtil.obterIdEmpresaShared();
    _empresaId = empresa;
  }

  bool _validaValor() {
    if (_valorController.numberValue <= widget.valor && _valorController.numberValue >= 0) {
      return true;
    }
    else {
      return false;
    }
  }

  Widget _botaoAdicionarPagamento() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Container(
        height: 32,
        child: SizedBox.expand(
          child: FlatButton(
            onPressed: () async {
              if(widget.parceiroId != null && _validaValor()) {
                InformacaoParcelaSend _infoParcela = new InformacaoParcelaSend();
                _infoParcela.formaPagamentoId = _formaPagamentoSelecionada.codigo;
                _infoParcela.condicaoPagamentoId = _condicaoPagamentoSelecionada.codigo;
                _infoParcela.empresaId = _empresaId;
                _infoParcela.valor = _valorController.numberValue;
                _infoParcela.parceiroId = widget.parceiroId;
                _infoParcela.registroId = 0;
                String infoParcelaJson = json.encode(_infoParcela.toJson());
                List<InformacaoParcelaRetorno> _infoParcelaRetorno = new List<InformacaoParcelaRetorno>();
                dynamic resultadoParcela = await OrcamentoService().obterParcelasVencimentos(
                  context: context,
                  infoParcela: infoParcelaJson
                );
                resultadoParcela.forEach((data) {
                  _infoParcelaRetorno.add(InformacaoParcelaRetorno.fromJson(data));
                });
                Navigator.pop(context, _infoParcelaRetorno);
              }
              else if (!_validaValor()) {
                AlertaComponente().showAlertaErro(
                  context: context,
                  // localedMessage: true,
                  mensagem: _locate.locale[TraducaoStringsConstante.ValorValidacao]
                );
              }
              else {
                AlertaComponente().showAlertaErro(
                  context: context,
                  // localedMessage: true,
                  mensagem: _locate.locale[TraducaoStringsConstante.SelecioneClienteValidacao]
                );
              }
            },
            color: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            child: Texto(
              _locate.locale[TraducaoStringsConstante.SalvarPagamento],
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
