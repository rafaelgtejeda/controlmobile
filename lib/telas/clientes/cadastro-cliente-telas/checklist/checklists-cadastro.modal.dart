import 'dart:convert';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/models/cliente/checklist/checklist-editar.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:provider/provider.dart';

class CheckListsCadastroModal extends StatefulWidget {
  final CheckListEditar checkList;
  final int parceiroId;
  CheckListsCadastroModal({this.checkList, this.parceiroId});

  @override
  _CheckListsCadastroModalState createState() => _CheckListsCadastroModalState();
}

class _CheckListsCadastroModalState extends State<CheckListsCadastroModal> {
  CheckListEditar _checkListEditar = new CheckListEditar();

  TextEditingController _sequenciaController = new TextEditingController();
  TextEditingController _descricaoController = new TextEditingController();

  LocalizacaoServico _locale = new LocalizacaoServico();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidacao = false;

  int _sequencia;
  String _descricao;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    if(widget.checkList != null) {
      _checkListEditar = widget.checkList;
      _sequenciaController.text = _checkListEditar.sequencia.toString();
      _sequencia = _checkListEditar.sequencia;
      _descricaoController.text = _checkListEditar.descricao;
      _descricao = _checkListEditar.descricao;
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
              title: Text(widget.checkList == null ? _locale.locale['CadastroCheckList'] : _locale.locale['EditarCheckList']),
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
                      TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _sequenciaController,
                        decoration: InputDecoration(
                          labelText: "${_locale.locale['Sequencia']}",
                          border: OutlineInputBorder(),
                        ),
                        validator: (input) {
                          if (input.isEmpty) {
                            return _locale.locale['PreenchaSequencia'];
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (input) => _sequencia = int.parse(input),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: _descricaoController,
                        decoration: InputDecoration(
                          labelText: "${_locale.locale['Descricao']}",
                          border: OutlineInputBorder(),
                        ),
                        validator: (input) {
                          if (input.isEmpty) {
                            return _locale.locale['PreenchaDescricao'];
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (input) => _descricao = input,
                      ),
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
        }
      )
    );
  }

  bool _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      _checkListEditar.parceiroId = widget.parceiroId;
      _checkListEditar.sequencia = _sequencia;
      _checkListEditar.descricao = _descricao;

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
    bool resultado;
    if (_checkListEditar.id == null) {
      String checkListJson = json.encode(_checkListEditar.novoCheckListJson());
      Response request = await ClienteService().checkList.adicionarCheckList(
        checkList: checkListJson, context: context
      );
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String checkListJson = json.encode(_checkListEditar.toJson());
      Response request = await ClienteService().checkList.editarCheckList(
        checkList: checkListJson, context: context
      );
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }
}
