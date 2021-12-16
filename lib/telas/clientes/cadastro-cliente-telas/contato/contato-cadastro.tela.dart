import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/models/cliente/contato/contato-editar.modelo.dart';
// import 'package:erp/models/cliente/contato-editar.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/lista-paises/lista-paises.tela.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/validators.dart';
import 'package:provider/provider.dart';

class CadastroContatoTela extends StatefulWidget {
  final ContatoEditar contato;
  final int parceiroId;
  CadastroContatoTela({this.contato, this.parceiroId});
  @override
  _CadastroContatoTelaState createState() => _CadastroContatoTelaState();
}

class _CadastroContatoTelaState extends State<CadastroContatoTela> {
  ContatoEditar contatoEditar = new ContatoEditar();
  LocalizacaoServico _locale = new LocalizacaoServico();

  TextEditingController _nomeController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _ddiTelefoneController = new TextEditingController();
  TextEditingController _dddTelefoneController = new TextEditingController();

  TextEditingController _ddiCelularController = new TextEditingController();
  TextEditingController _dddCelularController = new TextEditingController();

  var _telefoneMaskController = new MaskedTextController(mask: MascarasConstantes.PHONE_BR);
  var _celularMaskController = new MaskedTextController(mask: MascarasConstantes.MOBILE_PHONE_BR);

  String _nome, _email;

  String _ddiTelefone, _dddTelefone, _numeroTelefone,
      _ddiCelular, _dddCelular, _numeroCelular;
  
  bool _boleto = false, _notaFiscal = false, _principal = false;

  FocusNode _focusNome = new FocusNode();
  FocusNode _focusEmail = new FocusNode();

  FocusNode _focusDDITelefone = new FocusNode();
  FocusNode _focusDDICelular = new FocusNode();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidacao = false;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);

    ContatoEditar contatoEdit = widget.contato;
    if (contatoEdit != null) {
      contatoEditar = contatoEdit;
      _nomeController.text = contatoEdit.nome ?? "";
      // Email
      _emailController.text = (contatoEdit.email) ?? "";
      
      if(contatoEdit.telefone.ddi == "NaN" || contatoEdit.telefone.ddi == null
      || contatoEdit.telefone.ddd == "NaN" || contatoEdit.telefone.ddd == null) {}
      else {
        // DDI Telefone
        _ddiTelefoneController.text = (contatoEdit.telefone.ddi) ?? "";

        if (contatoEdit.telefone.ddi != '55') {
          _celularMaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
        }
        else {
          _celularMaskController.updateMask(MascarasConstantes.PHONE_BR);
        }
        // DDD Telefone
        _dddTelefoneController.text = (contatoEdit.telefone.ddd) ?? "";
        // Telefone
        _telefoneMaskController.text = (contatoEdit.telefone.phone) ?? "";
      }

      if(contatoEdit.celular.ddi == "NaN" || contatoEdit.celular.ddi == null
      || contatoEdit.celular.ddd == "NaN" || contatoEdit.celular.ddd == null) {}
      else {
        // DDI Celular
        _ddiCelularController.text = (contatoEdit.celular.ddi) ?? "";

        if (contatoEdit.celular.ddi != '55') {
          _celularMaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
        }
        else {
          _celularMaskController.updateMask(MascarasConstantes.PHONE_BR);
        }
        // DDD Celular
        _dddCelularController.text = (contatoEdit.celular.ddd) ?? "";
        // Celular
        _celularMaskController.text = (contatoEdit.celular.phone) ?? "";
      }
      _principal = contatoEdit.principal ?? false;
      _boleto = contatoEdit.boleto ?? false;
      _notaFiscal = contatoEdit.notaFiscal ?? false;
    }
    else {
      _preencheTelefones();
    }
  }

  _preencheTelefones() {
    Telefone telefone = new Telefone();
    Telefone celular = new Telefone();

    contatoEditar.telefone = telefone;
    contatoEditar.celular = celular;
  }

  Widget _buildCheckBox() {
    return Column(
      children: <Widget>[
        CheckboxListTile(
          value: _principal,
          onChanged: (valor) {
            setState(() {
              _principal = valor;
            });
          },
          title: Text(_locale.locale['Principal']),
        ),
        CheckboxListTile(
          value: _boleto,
          onChanged: (valor) {
            setState(() {
              _boleto = valor;
            });
          },
          title: Text(_locale.locale['Boleto']),
        ),
        CheckboxListTile(
          value: _notaFiscal,
          onChanged: (valor) {
            setState(() {
              _notaFiscal = valor;
            });
          },
          title: Text(_locale.locale['NotaFiscal']),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(widget.contato == null
                ? _locale.locale['CadastroContato']
                : _locale.locale['EditarContato']),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  tooltip: _locale.locale['SalvarContato'],
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
                      _contatoForm(),
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

  Widget _contatoForm() {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _nomeController,
          focusNode: _focusNome,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Nome']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          validator: (input) {
            if (input.length > 3 && input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['NomeValidacao']}";
            }
          },
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusNome, _focusEmail);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _nome = Validators().fieldFilledValidator(input, _nome),
        ),
        SizedBox(height: 15,),

        // E-mail
        TextFormField(
          controller: _emailController,
          focusNode: _focusEmail,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Email']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (input) {
            if (input.isEmpty) {
              return null;
            }
            else if (Validators().emailValidator(input) && input.isNotEmpty) {
              return null;
            } 
            else {
              return "${_locale.locale['EmailValidacao']}";
            }
          },
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusEmail, _focusDDITelefone);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _email = input,
        ),
        SizedBox(height: 15,),

        // Telefone
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                focusNode: _focusDDITelefone,
                readOnly: true,
                keyboardType: TextInputType.phone,
                controller: _ddiTelefoneController,
                decoration: InputDecoration(
                  prefixText: "+",
                  labelText: "${_locale.locale['Ddi']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListaPaisesTela()),
                  );
                  if (result != null) {
                    _ddiTelefoneController.text = result;
                  }
                  if (result != '55') {
                    _telefoneMaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
                  }
                  else {
                    _telefoneMaskController.updateMask(MascarasConstantes.PHONE_BR);
                  }
                },
                onSaved: (input) => _ddiTelefone = Validators().fieldFilledValidator(input, _ddiTelefone),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 2,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _dddTelefoneController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['DDD']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onSaved: (input) => _dddTelefone = Validators().fieldFilledValidator(input, _dddTelefone),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 7,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _telefoneMaskController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Telefone']}",
                  border: OutlineInputBorder(),
                ),
                onSaved: (input) {
                  String valor = input;
                  if(input.isNotEmpty) {
                    valor = input.replaceAll("-", "");
                  }
                  _numeroTelefone = Validators().fieldFilledValidator(valor, _numeroTelefone);
                }
              ),
            )
          ],
        ),
        SizedBox(height: 15,),

        // Celular
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                focusNode: _focusDDICelular,
                keyboardType: TextInputType.phone,
                readOnly: true,
                controller: _ddiCelularController,
                decoration: InputDecoration(
                  prefixText: "+",
                  labelText: "${_locale.locale['Ddi']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListaPaisesTela()),
                  );
                  if (result != null) {
                    _ddiCelularController.text = result;
                  }
                  if (result != '55') {
                    _celularMaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
                  }
                  else {
                    _celularMaskController.updateMask(MascarasConstantes.PHONE_BR);
                  }
                  _focusDDICelular.unfocus();
                },
                onSaved: (input) => _ddiCelular = Validators().fieldFilledValidator(input, _ddiCelular),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 2,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _dddCelularController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['DDD']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onSaved: (input) {
                  _dddCelular = Validators().fieldFilledValidator(input, _dddCelular);
                },
              ),
            ),
            SizedBox(width: 15,),
            
            Flexible(
              flex: 7,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _celularMaskController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Celular']}",
                  border: OutlineInputBorder(),
                ),
                onSaved: (input) {
                  String valor = input;
                  if (input.isNotEmpty) {
                    valor = valor.replaceAll("-", "");
                  }
                  _numeroCelular = Validators().fieldFilledValidator(valor, _numeroCelular);
                }
              ),
            )
          ],
        ),
        SizedBox(height: 15,),

        _buildCheckBox(),
        SizedBox(height: 15,),
      ],
    );
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

      contatoEditar.parceiroId = widget.parceiroId;
      contatoEditar.nome = _nome;
      contatoEditar.email = _email ?? '';

      contatoEditar.telefone.ddi = _ddiTelefone ?? '';
      contatoEditar.telefone.ddd = _dddTelefone ?? '';
      contatoEditar.telefone.phone = _numeroTelefone ?? '';

      contatoEditar.celular.ddi = _ddiCelular ?? '';
      contatoEditar.celular.ddd = _dddCelular ?? '';
      contatoEditar.celular.phone = _numeroCelular ?? '';

      contatoEditar.principal = _principal ?? false;
      contatoEditar.boleto = _boleto ?? false;
      contatoEditar.notaFiscal = _notaFiscal ?? false;
      
      // _salvar(funcao: () => funcao());
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
    // Tratar Cadastro de Cliente
    bool resultado;
    if (contatoEditar.id == null) {
      String contatoJson = json.encode(contatoEditar.novoContatoJson());
      Response request = await ClienteService().contato.adicionarContato(contato: contatoJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String contatoJson = json.encode(contatoEditar.toJson());
      Response request = await ClienteService().contato.editarContato(contato: contatoJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
