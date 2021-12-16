import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/select-busca/select-busca-modal.componente.dart';
import 'package:erp/models/cliente/limite-credito/limite-credito-editar.modelo.dart';
import 'package:erp/models/lookUp/forma-pagamento-lookup.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/forma-pagamento.modal.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/validators.dart';
import 'package:provider/provider.dart';

class CadastroLimiteCreditoTela extends StatefulWidget {
  final LimiteCreditoEditarGet limiteCredito;
  final int parceiroId;
  CadastroLimiteCreditoTela({this.parceiroId ,this.limiteCredito});
  @override
  _CadastroLimiteCreditoTelaState createState() => _CadastroLimiteCreditoTelaState();
}

class _CadastroLimiteCreditoTelaState extends State<CadastroLimiteCreditoTela> {
  LimiteCreditoEditarGet limiteEditar = new LimiteCreditoEditarGet();
  LimiteCreditoEditarSave limiteSave = new LimiteCreditoEditarSave();
  LocalizacaoServico _locale = new LocalizacaoServico();
  Helper _helper = new Helper();

  List<String> docs = new List<String>();

  TextEditingController _formaRecebimentoCodigoController = new TextEditingController();
  TextEditingController _formaRecebimentoShowUpController = new TextEditingController();
  var _limiteCreditoController = new MoneyMaskedTextController();
  var _limiteCreditoChequeTerceiroController = new MoneyMaskedTextController();
  var _cnpjCPFMaskController = new MaskedTextController(mask: MascarasConstantes.CPF_CNPJ_MULI);

  FormaPagamentoLookup _formaPagamentoSelecionado = new FormaPagamentoLookup();

  int _formaRecebimentoId;

  double _limiteCredito, _limiteTerceiro;

  FocusNode _focusFormaRecebimentoCodigo = new FocusNode();
  FocusNode _focusFormaRecebimento = new FocusNode();
  FocusNode _focusLimiteCredito = new FocusNode();
  FocusNode _focusLimiteCreditoChequeTerceiro = new FocusNode();
  FocusNode _focusCNPJCPF = new FocusNode();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidacao = false;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context)
      .then((value) {
        if (widget.limiteCredito == null) {
          _limiteCreditoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');

          _limiteCreditoChequeTerceiroController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');
        }
        else {
          _limiteCreditoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.limiteCredito.limiteProprio ?? 0);

          _limiteCreditoChequeTerceiroController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.limiteCredito.limiteTerceiro ?? 0);
        }
      });

    LimiteCreditoEditarGet limiteEdit = widget.limiteCredito;
    _focusFormaRecebimentoCodigo.addListener(_onFocusChangeFormaRecebimento);
    limiteSave.docs = new List<String>();
    if (limiteEdit != null) {
      limiteEditar = limiteEdit;
      _atribuiParaSave();
      _buscaFormaPagamentoPorId(limiteEdit.formaPagamentoId);
    }
  }

  _atribuiParaSave() {
    limiteSave.id = limiteEditar.id;
    limiteSave.formaPagamentoId = limiteEditar.formaPagamentoId;
    limiteSave.parceiroId = widget.parceiroId;
    limiteSave.valorLimiteProprio = limiteEditar.limiteProprio;
    limiteSave.valorLimiteTerceiro = limiteEditar.limiteTerceiro;
    if(limiteEditar.docs.length > 0) {
      limiteEditar.docs.forEach((data) {
        limiteSave.docs.add(data.numeroDocumento);
      });
    }
  }

  void _onFocusChangeFormaRecebimento() {
    if (_focusFormaRecebimentoCodigo.hasFocus) {} else {
      _buscaFormaPagamentoPorCodigo(int.parse(_formaRecebimentoCodigoController.text));
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
              title: Text(widget.limiteCredito == null
                ? _locale.locale[TraducaoStringsConstante.CadastroLimiteCredito]
                : _locale.locale[TraducaoStringsConstante.EditarLimiteCredito]),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  tooltip: _locale.locale[TraducaoStringsConstante.SalvarLimite],
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
                      _limiteForm(),
                      limiteSave.docs.isNotEmpty
                      ? _listaDocumentos()
                      : Container(),
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
                        texto: _locale.locale[TraducaoStringsConstante.Salvar],
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

  Widget _limiteForm() {
    return Column(
      children: <Widget>[
        // Forma de Recebimento Id e Descrição
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                focusNode: _focusFormaRecebimentoCodigo,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                controller: _formaRecebimentoCodigoController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale[TraducaoStringsConstante.Codigo]}",
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: (input) {
                  _buscaFormaPagamentoPorCodigo(int.parse(input));
                  _fieldFocusChange(
                    context, _focusFormaRecebimentoCodigo, _focusLimiteCredito
                  );
                },
                onSaved: (input) {
                  _formaRecebimentoId = _formaPagamentoSelecionado.id;
                },
              ),
            ),
            SizedBox(width: 15,),
            Flexible(
              flex: 5,
              child: TextFormField(
                focusNode: _focusFormaRecebimento,
                keyboardType: TextInputType.text,
                readOnly: true,
                controller: _formaRecebimentoShowUpController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale[TraducaoStringsConstante.FormaRecebimento]}",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FormaPagamentoModal(parceiroId: widget.parceiroId, tipoRetorno: 1,))
                  );
                  if (resultado != null) {
                    _formaPagamentoSelecionado = resultado;
                    _formaRecebimentoShowUpController.text = _formaPagamentoSelecionado.descricao;
                  }
                  if (_formaPagamentoSelecionado != null) {
                    _preencheFormaRecebimento(formaPagamento: _formaPagamentoSelecionado);
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _limiteCreditoController,
          focusNode: _focusLimiteCredito,
          decoration: InputDecoration(
            labelText: "${_locale.locale[TraducaoStringsConstante.LimiteCredito]}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusLimiteCredito, _focusLimiteCreditoChequeTerceiro);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _limiteCredito = _limiteCreditoController.numberValue,
        ),
        SizedBox(height: 15,),

        _formaPagamentoSelecionado.codigo == 2
        ? Column(
          children: <Widget>[
            TextFormField(
              controller: _limiteCreditoChequeTerceiroController,
              focusNode: _focusLimiteCreditoChequeTerceiro,
              decoration: InputDecoration(
                labelText: "${_locale.locale[TraducaoStringsConstante.LimiteCreditoChequeTerceiro]}",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              onSaved: (input) => _limiteTerceiro = _limiteCreditoChequeTerceiroController.numberValue,
            ),
            SizedBox(height: 15,),

            Row(
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: TextFormField(
                    controller: _cnpjCPFMaskController,
                    focusNode: _focusCNPJCPF,
                    maxLength: MascarasConstantes.CNPJ.length,
                    decoration: InputDecoration(
                      labelText: "${_locale.locale[TraducaoStringsConstante.CnpjCpfProprios]}",
                      border: OutlineInputBorder(),
                      counterText: ''
                    ),
                    onChanged: (input) {
                      if(input.length == MascarasConstantes.CPF_CNPJ_MULI.length - 1) {
                        _cnpjCPFMaskController.updateMask(MascarasConstantes.CNPJ);
                      }
                      else if (input.length < MascarasConstantes.CPF.length) {
                        _cnpjCPFMaskController.updateMask(MascarasConstantes.CPF);
                      }
                    },
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _adicionarCPFCNPJ(_cnpjCPFMaskController.text);
                  },
                )
              ],
            ),
            SizedBox(height: 15,),
          ],
        )
        : Container(),
      ],
    );
  }

  Widget _listaDocumentos() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor
        )
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              _locale.locale[TraducaoStringsConstante.CnpjCpf],
              style: TextStyle(
                fontSize: 18
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(
            color: Theme.of(context).primaryColor,
            thickness: 1,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, int index) {
              return _documentoItem(context, index, limiteSave.docs);
            },
            itemCount: limiteSave.docs.length + 1,
          ),
        ],
      ),
    );
  }

  Widget _documentoItem(BuildContext context, int index, List<String> lista) {
    if (index >= lista.length) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        _helper.cpfCnpjFormatter(input: lista[index]),
        style: TextStyle(
          fontSize: 18,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  _adicionarCPFCNPJ(String documento) {
    bool jaExiste = false;
    String input = documento.replaceAll('-', '');
    input = input.replaceAll('.', '');
    input = input.replaceAll('/', '');
    for(int i = 0; i < limiteSave.docs.length; i++) {
      if(limiteSave.docs[i] == input) {
        jaExiste = true;
        break;
      }
    }
    if (!jaExiste) {
      setState(() {
        _cnpjCPFMaskController.clear();
        limiteSave.docs.add(input);
      });
    }
    else {
      _showSnackBar(_locale.locale[TraducaoStringsConstante.DocumentoExistente]);
    }
  }

  _buscaFormaPagamentoPorCodigo(int codigoForma) async {
    if (codigoForma.isNaN) {
      _preencheFormaRecebimento(formaPagamento: null);
    }
    else {
      CarregandoAlertaComponente().showCarregar(context);
      dynamic requestForma = await ClienteService().limiteCredito.formaPagamento.buscaFormaPorCodigo(formaPagamentoCodigo: codigoForma, parceiroId: widget.parceiroId, tipoRetorno: 1);
      List<FormaPagamentoLookup> listaPagamento = new List<FormaPagamentoLookup>();
      requestForma.forEach((data) {
        listaPagamento.add(FormaPagamentoLookup.fromJson(data));
      });
      if (listaPagamento.length > 0) {
        _formaPagamentoSelecionado = listaPagamento[0];
        _preencheFormaRecebimento(formaPagamento: _formaPagamentoSelecionado);
      }
      else {
        _preencheFormaRecebimento(formaPagamento: null);
      }
      CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  _buscaFormaPagamentoPorId(int idForma) async {
    if (idForma.isNaN) {
      return null;
    }
    else {
      // CarregandoAlertaComponente().showCarregar(context);
      dynamic requestForma = await ClienteService().limiteCredito.formaPagamento.buscaFormasPorId(idForma: idForma, tipoRetorno: 1);
      List<FormaPagamentoLookup> listaPagamento = new List<FormaPagamentoLookup>();
      requestForma.forEach((data) {
        listaPagamento.add(FormaPagamentoLookup.fromJson(data));
      });
      if (listaPagamento.length > 0) {
        _formaPagamentoSelecionado = listaPagamento[0];
        _preencheFormaRecebimento(formaPagamento: _formaPagamentoSelecionado);
      }
      else {
        _preencheFormaRecebimento(formaPagamento: null);
      }
      // CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  _preencheFormaRecebimento({FormaPagamentoLookup formaPagamento}) {
    if (formaPagamento != null) {
      setState(() {
        _formaRecebimentoCodigoController.text = formaPagamento.codigo.toString() ?? '';
        _formaRecebimentoShowUpController.text = formaPagamento.descricao ?? '';
      });
    }
    else {
      setState(() {
        _formaRecebimentoCodigoController.clear();
        _formaRecebimentoShowUpController.clear();
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

      limiteSave.parceiroId = widget.parceiroId;
      limiteSave.formaPagamentoId = _formaRecebimentoId;
      limiteSave.valorLimiteProprio = _limiteCredito ?? 0;
      limiteSave.valorLimiteTerceiro = _limiteTerceiro ?? 0;
      
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
    // Tratar Cadastro de Clientes
    bool resultado;
    if (limiteEditar.id == null) {
      String limiteJson = json.encode(limiteSave.novoLimiteCreditoJson());
      Response request = await ClienteService().limiteCredito.adicionarLimiteCredito(limite: limiteJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String limiteJson = json.encode(limiteSave.toJson());
      Response request = await ClienteService().limiteCredito.editarLimiteCredito(limite: limiteJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
