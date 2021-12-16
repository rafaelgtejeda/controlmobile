import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp/servicos/cep/cep.servicos.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/compartilhados/componentes/accordion.componente.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/lista-enderecos-busca/lista-enderecos-busca.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/select-combobox.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/models/cliente/prospect/cliente-prospect.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/lista-paises/lista-paises.tela.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:search_cep/search_cep.dart';
import 'package:erp/utils/validators.dart';
import 'package:erp/utils/helper.dart';

class ClienteProspectCadastroComponente extends StatefulWidget {
  final Cliente cliente;
  final bool clienteRapido;
  ClienteProspectCadastroComponente({Key key, this.cliente, this.clienteRapido}) : super(key: key);

  @override
  _ClienteProspectCadastroComponenteState createState() => _ClienteProspectCadastroComponenteState();
}

class _ClienteProspectCadastroComponenteState extends State<ClienteProspectCadastroComponente> {
  
  LocalizacaoServico _locale = new LocalizacaoServico();
  Helper helper = new Helper();

  Cliente _clienteProspectModelo = new Cliente();
  int _empresaId;
  int _idClienteProspect;

  bool _autoValidacao = false;

  bool _isOnline = true;

  String pessoaJuridicaTipoSelect = '';
  String pessoaFisicaTipoSelect = '';
  String estrangeiroTipoSelect = '';
  // Seleção de tipo de cliente
  List<SelectComboBox> _tipos = new List<SelectComboBox>();
  List<DropdownMenuItem<SelectComboBox>> _dropDownTiposClientes;
  SelectComboBox _tipoClienteSelecionado;

  Stream<dynamic> _streamTipos;

  // Focus Nodes
  FocusNode _focusDocumento = new FocusNode();
  FocusNode _focusRazaoSocial = new FocusNode();
  FocusNode _focusNomeFantasia = new FocusNode();

  FocusNode _focusEmail = new FocusNode();
  FocusNode _focusDDITelefone = new FocusNode();
  FocusNode _focusDDDTelefone = new FocusNode();
  FocusNode _focusTelefone = new FocusNode();
  FocusNode _focusDDICelular = new FocusNode();
  FocusNode _focusDDDCelular = new FocusNode();
  FocusNode _focusCelular = new FocusNode();

  FocusNode _focusCEP = new FocusNode();
  FocusNode _focusEndereco = new FocusNode();
  FocusNode _focusNumero = new FocusNode();
  FocusNode _focusBairro = new FocusNode();
  FocusNode _focusComplemento = new FocusNode();
  FocusNode _focusCidade = new FocusNode();
  FocusNode _focusEstado = new FocusNode();


  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // Atributos para submissão
  String _documento, _rg, _razaoSocial, _nomeFantasia, _email;

  String _ddiTelefone, _dddTelefone, _numeroTelefone,
      _ddiCelular, _dddCelular, _numeroCelular;

  String _cep, 
      _endereco, _numero, _bairro,
      _complemento, _cidade, _estado;

  String _appNome = '';

  bool _validaCNPJ = false, _validaCPF = false;

  // Input Controllers

  TextEditingController _rgController = new TextEditingController();

  TextEditingController _documentoEstrangeiroController = new TextEditingController();
  TextEditingController _razaoSocialController = new TextEditingController();
  TextEditingController _nomeFantasiaController = new TextEditingController();

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _ddiTelefoneController = new TextEditingController();
  TextEditingController _dddTelefoneController = new TextEditingController();
  TextEditingController _ddiCelularController = new TextEditingController();
  TextEditingController _dddCelularController = new TextEditingController();

  TextEditingController _enderecoController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _bairroController = new TextEditingController();
  TextEditingController _complementoController = new TextEditingController();
  TextEditingController _cidadeController = new TextEditingController();
  TextEditingController _estadoController = new TextEditingController();

  // Inputs com máscaras
  var _cpfMaskController = new MaskedTextController(mask: MascarasConstantes.CPF);
  var _cnpjMaskController = new MaskedTextController(mask: MascarasConstantes.CNPJ);
  var _telefoneMaskController = new MaskedTextController(mask: MascarasConstantes.PHONE_BR);
  var _celularMaskController = new MaskedTextController(mask: MascarasConstantes.MOBILE_PHONE_BR);
  var _cepMaskController = new MaskedTextController(mask: MascarasConstantes.CEP);

  @override
  void initState() {
    super.initState();
    _verificaApp();
    _obtemEmpresa();

    _locale.iniciaLocalizacao(context);
    _streamTipos = Stream.fromFuture(_tiposClientesStream());
    _focusDocumento.addListener(_onFocusChangeDocumento);
    if(widget.cliente != null) {
      Cliente cliente = widget.cliente;
      _preencheClienteEditar(cliente: cliente);
    }
  }

  _preencheClienteEditar({Cliente cliente}) {
    _clienteProspectModelo = cliente;

    if(cliente.pessoa == TipoClienteConstante.PESSOA_JURIDICA) {
      _cnpjMaskController.updateText(cliente.cnpJCPF ?? '');
    }
    else {
      _cpfMaskController.updateText(cliente.cnpJCPF ?? '');
    }
    _razaoSocialController.text = cliente.nome_razaosocial ?? '';
    _nomeFantasiaController.text = cliente.nomeFantasia ?? '';

    _emailController.text = cliente.email ?? '';
    _ddiTelefoneController.text = cliente.ddiTelefone ?? '';
    _dddTelefoneController.text = cliente.dddTelefone ?? '';
    _telefoneMaskController.updateText(cliente.telefone ?? '');
    _ddiCelularController.text = cliente.ddiCelular ?? '';
    _dddCelularController.text = cliente.dddCelular ?? '';
    _celularMaskController.updateText(cliente.celular ?? '');

    _cepMaskController.updateText(cliente.cep ?? '');
    _enderecoController.text = cliente.endereco ?? '';
    _numeroController.text = cliente.numero ?? '';
    _bairroController.text = cliente.bairro ?? '';
    _complementoController.text = cliente.complemento ?? '';
    _cidadeController.text = cliente.cidade ?? '';
    _estadoController.text = cliente.uf ?? '';
  }

  _verificaApp() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _appNome = _prefs.getString(SharedPreference.APP);
  }

  _obtemEmpresa() async {
    _empresaId = await RequestUtil().obterIdEmpresaShared();
  }

  Future<List<SelectComboBox>> _tiposClientesStream() async {
    await _locale.iniciaLocalizacao(context);

    SelectComboBox tipoJuridica = new SelectComboBox();
    tipoJuridica.codigo = TipoClienteConstante.PESSOA_JURIDICA;
    tipoJuridica.descricao = _locale.locale[TraducaoStringsConstante.PessoaJuridica];

    SelectComboBox tipoFisica = new SelectComboBox();
    tipoFisica.codigo = TipoClienteConstante.PESSOA_FISICA;
    tipoFisica.descricao = _locale.locale[TraducaoStringsConstante.PessoaFisica];

    SelectComboBox tipoEstrangeiro = new SelectComboBox();
    tipoEstrangeiro.codigo = TipoClienteConstante.ESTRANGEIRO;
    tipoEstrangeiro.descricao = _locale.locale[TraducaoStringsConstante.Estrangeiro];

    _tipos.add(tipoJuridica);
    _tipos.add(tipoFisica);
    _tipos.add(tipoEstrangeiro);

    _dropDownTiposClientes = getDropDownItensSelecao(_tipos);

    if(widget.cliente != null) {
      _tipoClienteSelecionado = _dropDownTiposClientes[(widget.cliente.pessoa) - 1].value;
    }
    else {
      _tipoClienteSelecionado = _dropDownTiposClientes[0].value;
    }

    return _tipos;
  }

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensComboBox(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(_locale.locale[TraducaoStringsConstante.CadastroCliente]),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (await _submit() == true) {
                      if(await _salvar() == true) {
                        if(widget.clienteRapido) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                        else {
                          Navigator.pop(context, true);
                        }
                      }
                    }
                  },
                  tooltip: _locale.locale['SalvarCliente'],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Form(
                key: formKey,
                autovalidate: _autoValidacao,
                child: Column(
                  children: <Widget>[
                    // Texto(
                    //   (_appNome == Config.Fullcontrol)
                    //   ? _locale.locale[TraducaoStringsConstante.ClienteProspectDescricaoInicioFullcontrol]
                    //   : _locale.locale[TraducaoStringsConstante.ClienteProspectDescricaoInicioAtmos],
                    //   fontSize: 18
                    // ),
                    // Texto(
                    //   _locale.locale[TraducaoStringsConstante.ClienteProspectDescricaoFinal],
                    //   fontSize: 18
                    // ),
                    _buildComboTiposClientes(),
                    _informacoesEssenciais(),
                    _contato(),
                    enderecoPrincipalAccordion(),
                    ButtonComponente(
                      funcao: () async {
                        if (await _submit() == true) {
                          if(await _salvar() == true) {
                            if(widget.clienteRapido) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                            else {
                              Navigator.pop(context, true);
                            }
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
                ),
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  _buildComboTiposClientes() {
    return StreamBuilder(
      stream: _streamTipos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(_locale.locale[TraducaoStringsConstante.TipoCliente]),
              Container(
                height: 48,
                child: DropdownButton(
                  items: [],
                  onChanged: (_) {},
                ),
              )
            ],
          );
        }
        else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(_locale.locale[TraducaoStringsConstante.TipoCliente]),
                  Container(
                    height: 48,
                    child: DropdownButton(
                      items: [],
                      onChanged: (_) {},
                    ),
                  )
                ],
              );
              break;
            default:
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(_locale.locale[TraducaoStringsConstante.TipoCliente]),
                DropdownButton(
                  value: _tipoClienteSelecionado,
                  items: _dropDownTiposClientes,
                  onChanged: alteraTipoSelecionado,
                )
              ],
            );
            break;
          }
        }
      }
    );
  }

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensSelecao(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  Future<Cliente> _verificaDocumentoExistente({String documento}) async {
    // if(_clienteProspectModelo.id == null) {
    //   Empresa empresa = await Empresa().getById(_empresaId);
    //   if(empresa.ondeProcuraContato != 0) {
    //     return await Cliente().select().empresaId.equals(empresa.ondeProcuraContato).and
    //       .startBlock.cnpJCPF.equals(documento).endBlock
    //       .toSingle();
    //   }
    //   else {
    //     return await Cliente().select().cnpJCPF.equals(documento).toSingle();
    //   }
    // }
    // else {
    //   Empresa empresa = await Empresa().getById(_empresaId);
    //   if(empresa.ondeProcuraContato != 0) {
    //     return await Cliente().getById(_clienteProspectModelo.id, empresa.ondeProcuraContato);
    //   }
    //   else {
    //     Cliente resultado = await Cliente().select().id.equals(_clienteProspectModelo.id).and.cnpJCPF.equals(documento).toSingle();
    //     return resultado.id == _clienteProspectModelo.id ? null : resultado;
    //     // return await Cliente().select().id.not.equals(_clienteProspectModelo.id).and.cnpJCPF.equals(documento).toSingle();
    //   }
    // }
    if(_clienteProspectModelo.id == null) {
      return await Cliente().select().cnpJCPF.equals(documento).toSingle();
    }
    else {
      Cliente resultado = await Cliente().select().id.equals(_clienteProspectModelo.id).and.cnpJCPF.equals(documento).toSingle();
      return resultado.id == _clienteProspectModelo.id ? null : resultado;
    }
  }

  Widget _informacoesEssenciais() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[900],
          width: double.maxFinite,
          height: 36,
          child: Center(
            child: Texto(
              _locale.locale[TraducaoStringsConstante.InformacoesEssenciais],
              bold: true,
              color: Colors.white,
              fontSize: 20
            ),
          ),
        ),
        Visibility(
          visible: _tipoClienteSelecionado != null
            && _tipoClienteSelecionado.codigo == TipoClienteConstante.PESSOA_JURIDICA,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _cnpjMaskController,
              focusNode: _focusDocumento,
              decoration: InputDecoration(
                counterText: '',
                labelText: _locale.locale[TraducaoStringsConstante.CNPJ],
                border: OutlineInputBorder(),
              ),
              maxLength: 18,
              autovalidate: _validaCNPJ,
              keyboardType: TextInputType.phone,
              validator: (input) {
                if (Validators().cnpjValidator(input)) {
                  String valor;
                  valor = input.replaceAll(".", "");
                  valor = valor.replaceAll("/", "");
                  valor = valor.replaceAll("-", "");
                  dynamic resultado;
                  _verificaDocumentoExistente(documento: valor).then((value) => resultado = value);
                  if(resultado is Cliente) {
                    return _locale.locale[TraducaoStringsConstante.CNPJCadastradoValidacao];
                  }
                  else {
                    if(input.length < 18) {
                      return _locale.locale[TraducaoStringsConstante.CNPJInvalido];
                    }
                    else {
                      return null;
                    }
                  }
                } 
                else {
                  return _locale.locale[TraducaoStringsConstante.CNPJInvalido];
                }
              },
              onSaved: (input) {
                String valor;
                valor = input.replaceAll(".", "");
                valor = valor.replaceAll("/", "");
                valor = valor.replaceAll("-", "");
                _documento = valor;
              },
              onFieldSubmitted: (input) async {
                if(input.length == 18) {
                  String documento;
                  documento = input.replaceAll(".", "");
                  documento = documento.replaceAll("/", "");
                  documento = documento.replaceAll("-", "");
                }
                setState(() {
                  _validaCNPJ = true;
                });
                _focusDocumento.nextFocus();
              },
              textInputAction: TextInputAction.next,
              onChanged: (input) {
                if(input.length > 0 && input.length < 18) {
                  setState(() {
                    _validaCNPJ = true;
                  });
                }
              },
            ),
          )
        ),

        Visibility(
          visible: _tipoClienteSelecionado != null
            && _tipoClienteSelecionado.codigo == TipoClienteConstante.PESSOA_FISICA,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _cpfMaskController,
              focusNode: _focusDocumento,
              decoration: InputDecoration(
                counterText: '',
                labelText: _locale.locale[TraducaoStringsConstante.CPF],
                border: OutlineInputBorder(),
              ),
              maxLength: 14,
              autovalidate: _validaCPF,
              keyboardType: TextInputType.phone,
              validator: (input) {
                if (Validators().cpfValidator(input) && input.isNotEmpty) {
                  String valor;
                  valor = input.replaceAll(".", "");
                  valor = valor.replaceAll("/", "");
                  valor = valor.replaceAll("-", "");
                  dynamic resultado;
                  _verificaDocumentoExistente(documento: valor).then((value) => resultado = value);
                  if(resultado != null) {
                    return _locale.locale[TraducaoStringsConstante.CPFCadastradoValidacao];
                  }
                  else {
                    if(input.length < 14) {
                      return _locale.locale[TraducaoStringsConstante.CPFInvalido];
                    }
                    else {
                      return null;
                    }
                  }
                } 
                else {
                  return _locale.locale[TraducaoStringsConstante.CPFInvalido];
                }
              },
              onSaved: (input) {
                String valor;
                valor = input.replaceAll(".", "");
                valor = valor.replaceAll("/", "");
                valor = valor.replaceAll("-", "");
                _documento = valor;
              },
              onFieldSubmitted: (input) async {
                if(input.length == 14) {
                  String documento;
                  documento = input.replaceAll(".", "");
                  documento = documento.replaceAll("/", "");
                  documento = documento.replaceAll("-", "");
                }
                setState(() {
                  _validaCPF = true;
                });
                _focusDocumento.nextFocus();
              },
              onChanged: (input) {
                if(input.length > 0 && input.length < 14) {
                setState(() {
                  _validaCPF = true;
                });
                }
              },
              textInputAction: TextInputAction.next,
            ),
          )
        ),

        Visibility(
          visible: _tipoClienteSelecionado != null
            && _tipoClienteSelecionado.codigo == TipoClienteConstante.ESTRANGEIRO,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              controller: _documentoEstrangeiroController,
              focusNode: _focusDocumento,
              decoration: InputDecoration(
                counterText: '',
                labelText: _locale.locale[TraducaoStringsConstante.Documento],
                border: OutlineInputBorder(),
              ),
              maxLength: 20,
              keyboardType: TextInputType.phone,
              validator: (input) {
                if (input.isNotEmpty) {
                  return null;
                } 
                else {
                  String valor;
                  valor = input.replaceAll(".", "");
                  valor = valor.replaceAll("/", "");
                  valor = valor.replaceAll("-", "");
                  dynamic resultado;
                  _verificaDocumentoExistente(documento: valor).then((value) => resultado = value);
                  if(resultado != null) {
                    return _locale.locale[TraducaoStringsConstante.DocumentoCadastradoValidacao];
                  }
                  else {
                    if(input.isEmpty) {
                      return _locale.locale[TraducaoStringsConstante.DocumentoValidacao];
                    }
                    else {
                      return null;
                    }
                  }
                }
              },
              onSaved: (input) {
                String valor;
                valor = input.replaceAll(".", "");
                valor = valor.replaceAll("/", "");
                valor = valor.replaceAll("-", "");
                _documento = valor;
              },
              onFieldSubmitted: (input) async {
                if(input.length > 0 && input.length < 20) {
                  String documento;
                  documento = input.replaceAll(".", "");
                  documento = documento.replaceAll("/", "");
                  documento = documento.replaceAll("-", "");
                }
                _focusDocumento.nextFocus();
              },
              textInputAction: TextInputAction.next,
            ),
          )
        ),
            
        // (_tipoClienteSelecionado.codigo == 2)
        // ? Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8),
        //   child: TextFormField(
        //     controller: _rgController,
        //     decoration: InputDecoration(
        //       counterText: '',
        //       labelText: "${_locale.locale['RG']}",
        //       border: OutlineInputBorder(),
        //     ),
        //     maxLength: 20,
        //     keyboardType: TextInputType.phone,
        //     onSaved: (input) => _rg = Validators().fieldFilledValidator(input, _rg),
        //   ),
        // )
        // : Container(),

        // (_tipoClienteSelecionado.codigo == 1)
        // ? Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8),
        //   child: TextFormField(
        //     controller: _inscricaoEstadualController,
        //     decoration: InputDecoration(
        //       counterText: '',
        //       labelText: "${_locale.locale['InscricaoEstadual']}",
        //       border: OutlineInputBorder(),
        //     ),
        //     maxLength: 20,
        //     keyboardType: TextInputType.phone,
        //     onSaved: (input) => _inscricaoEstadual = Validators().fieldFilledValidator(input, _inscricaoEstadual),
        //   ),
        // )
        // : Container(),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _razaoSocialController,
            focusNode: _focusRazaoSocial,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.NomeRazaoSocial],
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            validator: (input) {
              if (input.length > 3 && input.isNotEmpty) {
                return null;
              } else {
                return _locale.locale[TraducaoStringsConstante.NomeValidacao];
              }
            },
            onFieldSubmitted: (term) {
              _focusRazaoSocial.nextFocus();
            },
            textInputAction: TextInputAction.next,
            onSaved: (input) => _razaoSocial = Validators().fieldFilledValidator(input, _razaoSocial),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _nomeFantasiaController,
            focusNode: _focusNomeFantasia,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.NomeFantasia],
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onSaved: (input) => _nomeFantasia = Validators().fieldFilledValidator(input, _nomeFantasia),
            onFieldSubmitted: (term) {
              _focusNomeFantasia.nextFocus();
            },
          ),
        ),
      ]
    );
  }

  void _onFocusChangeDocumento() async {
    if (_focusDocumento.hasFocus) {} else {
      if(_tipoClienteSelecionado.codigo != TipoClienteConstante.ESTRANGEIRO) {
        String documento;
        documento = 
          _tipoClienteSelecionado.codigo == TipoClienteConstante.PESSOA_JURIDICA 
            ? _cnpjMaskController.text.replaceAll(".", "")
            : _cpfMaskController.text.replaceAll(".", "");
        documento = documento.replaceAll("/", "");
        documento = documento.replaceAll("-", "");
        await _verificacao(documento: documento);
      }
    }
  }

  _verificacao({String documento}) async {
    dynamic resultado = await _verificaDocumentoExistente(documento: documento);
    if(resultado != null) {
      if(await AlertaComponente().showAlertaConfirmacao(
        context: context,
        mensagem: _locale.locale[TraducaoStringsConstante.DocumentoCadastradoAlerta]
      )) {
        if(await _alertaDocumentoExistente(resultado) is Cliente) {
          _preencheClienteEditar(cliente: resultado);
        }
      }
    }
  }

  Future<Cliente> _alertaDocumentoExistente(Cliente cliente) async {
    MediaQueryData _media = MediaQuery.of(context);

    return await showDialog(
      context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(_locale.locale[TraducaoStringsConstante.ClienteJaCadastrado]),
            content: StatefulBuilder(
              builder: (context, _) {
                return Scrollbar(
                  child: ListView(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[

                          // Informações Essenciais
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              color: Colors.grey[900],
                              width: double.maxFinite,
                              height: 36,
                              child: Center(
                                child: Texto(
                                  _locale.locale[TraducaoStringsConstante.InformacoesEssenciais],
                                  bold: true,
                                  color: Colors.white,
                                  fontSize: _media.size.width > 400 ? 16 : 15
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: cliente.pessoa == TipoClienteConstante.PESSOA_FISICA,
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.CPF] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: Helper().cpfCnpjFormatter(input: cliente.cnpJCPF ?? '')),
                                ]
                              ),
                            ),
                          ),
                          Visibility(
                            visible: cliente.pessoa == TipoClienteConstante.PESSOA_JURIDICA,
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.CNPJ] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: Helper().cpfCnpjFormatter(input: cliente.cnpJCPF ?? '')),
                                ]
                              ),
                            ),
                          ),
                          Visibility(
                            visible: cliente.pessoa == TipoClienteConstante.ESTRANGEIRO,
                            child: RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.Documento] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: cliente.cnpJCPF ?? ''),
                                ]
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Nome] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.nome_razaosocial ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.NomeFantasia] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.nomeFantasia ?? ''),
                              ]
                            ),
                          ),

                          // Contato
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              color: Colors.grey[900],
                              width: double.maxFinite,
                              height: 36,
                              child: Center(
                                child: Texto(
                                  _locale.locale[TraducaoStringsConstante.Contato],
                                  bold: true,
                                  color: Colors.white,
                                  fontSize: _media.size.width > 400 ? 16 : 15
                                ),
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Email] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.email ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Telefone] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '+${cliente.ddiTelefone ?? ""} (${cliente.dddTelefone ?? ""}) ${cliente.telefone ?? ""}'
                                ),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Celular] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(
                                  text: '+${cliente.ddiCelular ?? ""} (${cliente.dddCelular ?? ""}) ${cliente.celular ?? ""}'
                                ),
                              ]
                            ),
                          ),

                          // Endereço Principal
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              color: Colors.grey[900],
                              width: double.maxFinite,
                              height: 36,
                              child: Center(
                                child: Texto(
                                  _locale.locale[TraducaoStringsConstante.EnderecoPrincipal],
                                  bold: true,
                                  color: Colors.white,
                                  fontSize: _media.size.width > 400 ? 16 : 15
                                ),
                              ),
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Estado] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.uf ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Cidade] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.cidade ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Bairro] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.bairro ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Endereco] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.endereco ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Numero] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.numero ?? ''),
                              ]
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan> [
                                TextSpan(
                                  text: _locale.locale[TraducaoStringsConstante.Complemento] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                ),
                                TextSpan(text: cliente.complemento ?? ''),
                              ]
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Text(_locale.locale[TraducaoStringsConstante.GostariaEditarCliente]),
                    ],
                  ),
                );
              }
            ),
            actions: [
              FlatButton(
                child: Text(_locale.locale[TraducaoStringsConstante.Editar]),
                onPressed: () {
                  Navigator.pop(context, cliente);
                },
              ),
              FlatButton(
                child: Text(_locale.locale[TraducaoStringsConstante.Cancelar]),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ]
          );
        },
      barrierDismissible: true,
    );
  }

  Widget _contato() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[900],
          width: double.maxFinite,
          height: 36,
          child: Center(
            child: Texto(
              _locale.locale[TraducaoStringsConstante.Contato],
              bold: true,
              color: Colors.white,
              fontSize: 20
            ),
          ),
        ),

        // E-mail
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _emailController,
            focusNode: _focusEmail,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Email],
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
                return _locale.locale[TraducaoStringsConstante.EmailValidacao];
              }
            },
            onSaved: (input) => _email = input,
            textInputAction: TextInputAction.next,
            // onFieldSubmitted: (term) {
            //   _focusEmail.nextFocus();
            // },
          ),
        ),
        // Telefone 1
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
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
                    labelText: _locale.locale[TraducaoStringsConstante.Ddi],
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
                    _focusDDITelefone.nextFocus();
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
                  focusNode: _focusDDDTelefone,
                  decoration: InputDecoration(
                    labelText: _locale.locale[TraducaoStringsConstante.DDD],
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLength: 3,
                  onSaved: (input) => _dddTelefone = Validators().fieldFilledValidator(input, _dddTelefone),
                  onFieldSubmitted: (term) {
                    _focusDDDTelefone.nextFocus();
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              SizedBox(width: 15,),

              Flexible(
                flex: 7,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _telefoneMaskController,
                  focusNode: _focusTelefone,
                  decoration: InputDecoration(
                    labelText: _locale.locale[TraducaoStringsConstante.Telefone],
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
        ),

        // Celular
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
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
                    labelText: _locale.locale[TraducaoStringsConstante.Ddi],
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
                      _celularMaskController.updateMask(MascarasConstantes.MOBILE_PHONE_BR);
                    }
                    // _focusDDICelular.unfocus();
                    _focusDDICelular.nextFocus();
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
                  focusNode: _focusDDDCelular,
                  decoration: InputDecoration(
                    labelText: _locale.locale[TraducaoStringsConstante.DDD],
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLength: 3,
                  onSaved: (input) => _dddCelular = Validators().fieldFilledValidator(input, _dddCelular),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _focusDDDCelular.nextFocus();
                  },
                ),
              ),
              SizedBox(width: 15,),
              
              Flexible(
                flex: 7,
                child: TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: _celularMaskController,
                  focusNode: _focusCelular,
                  decoration: InputDecoration(
                    labelText: _locale.locale[TraducaoStringsConstante.Celular],
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (input) {
                    String valor = input;
                    if (input.isNotEmpty) {
                      valor = valor.replaceAll("-", "");
                    }
                    _numeroCelular = Validators().fieldFilledValidator(valor, _numeroCelular);
                  },
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _focusCelular.nextFocus();
                  },
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget enderecoPrincipalAccordion() {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[900],
          // width: double.maxFinite,
          // height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
            child: Center(
              child: Texto(
                _locale.locale[TraducaoStringsConstante.EnderecoPrincipal],
                bold: true,
                color: Colors.white,
                fontSize: 20
              ),
            ),
          ),
        ),
        // CEP
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            focusNode: _focusCEP,
            controller: _cepMaskController,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.CEP],
              border: OutlineInputBorder(),
              counterText: '',
              suffixIcon: Tooltip(
                message: _locale.locale[TraducaoStringsConstante.CEPTooltip],
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          _locale.locale[TraducaoStringsConstante.NaoSeiCEP],
                          style: TextStyle(
                            fontSize: 14
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _preencheInfoCepDeEndereco();
                    // _showSnackBar("${_locale.locale['BuscaEndereco']}");
                  },
                )
              ),
            ),
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (input) {
              if(_isOnline) {
                _buscaCEP(input);
              }
              else {
                _focusCEP.nextFocus();
              }
            },
            onChanged: (input) {
              if(input.length == 9) {
                if(_isOnline) {
                  _buscaCEP(input);
                }
                else{
                  _focusCEP.nextFocus();
                }
              }
            },
            maxLength: 9,
            keyboardType: TextInputType.number,
            validator: (input) {
              if (input.length > 8 && input.isNotEmpty) {
                return null;
              } else {
                return _locale.locale[TraducaoStringsConstante.CEPValidacao];
              }
            },
            onSaved: (input) {
              _cep = input.replaceAll("-", "");
            }
          ),
        ),

        // Endereço
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _enderecoController,
            focusNode: _focusEndereco,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Endereco],
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _focusEndereco.nextFocus();
            },
            onSaved: (input) => _endereco = Validators().fieldFilledValidator(input, _endereco),
          ),
        ),

        // Número
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _numeroController,
            focusNode: _focusNumero,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Numero],
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _focusNumero.nextFocus();
            },
            onSaved: (input) => _numero = Validators().fieldFilledValidator(input, _numero),
          ),
        ),

        // Bairro
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _bairroController,
            focusNode: _focusBairro,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Bairro],
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _focusBairro.nextFocus();
            },
            onSaved: (input) => _bairro = Validators().fieldFilledValidator(input, _bairro),
          ),
        ),

        // Complemento
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _complementoController,
            focusNode: _focusComplemento,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Complemento],
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _focusComplemento.nextFocus();
            },
            onSaved: (input) => _complemento = Validators().fieldFilledValidator(input, _complemento),
          ),
        ),

        // Cidade
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _cidadeController,
            focusNode: _focusCidade,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Cidade],
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              _focusCidade.nextFocus();
            },
            onSaved: (input) => _cidade = Validators().fieldFilledValidator(input, _cidade),
          ),
        ),

        // Estado
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            controller: _estadoController,
            focusNode: _focusEstado,
            decoration: InputDecoration(
              labelText: _locale.locale[TraducaoStringsConstante.Estado],
              counterText: '',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.search, color: Colors.blue[700],),
                onPressed: () {
                  _preencheInfoCepDeEndereco();
                },
                tooltip: _locale.locale[TraducaoStringsConstante.LocalidadeTooltip],
              )
            ),
            maxLength: 2,
            textCapitalization: TextCapitalization.characters,
            keyboardType: TextInputType.text,
            validator: (input) {
              if (input.isNotEmpty) {
                return null;
              } else {
                return _locale.locale[TraducaoStringsConstante.LocalidadeTooltip];
              }
            },
            onSaved: (input) => _estado = Validators().fieldFilledValidator(input, _estado),
            onFieldSubmitted: (term) async {
              if (await _submit() == true) {
                if(await _salvar() == true) {
                  if(widget.clienteRapido) {
                    Navigator.pop(context, _idClienteProspect);
                    Navigator.pop(context, _idClienteProspect);
                  }
                  else {
                    Navigator.pop(context, true);
                  }
                }
              }
            },
          ),
        ),
    ]);
  }

  _buscaCEP(String input) {
    CarregandoAlertaComponente().showCarregar(context);
    CepService().buscaPorCep(cep: input)
      .then((data) {
        _preencheInfoCep(cepInfo: data);
        CarregandoAlertaComponente().dismissCarregar(context);
        _fieldFocusChange(context, _focusCEP, _focusNumero);
      })
      .catchError((e) {
        CarregandoAlertaComponente().dismissCarregar(context);
        _showSnackBar(_locale.locale[TraducaoStringsConstante.CEPValidacao]);
        _fieldFocusChange(context, _focusCEP, _focusCEP);
      });
    // _fieldFocusChange(context, _focusCEP, _focusNumero);
  }

  _preencheInfoCepDeEndereco() async {
    String ufBusca = _estadoController.text;
    String cidadeBusca = _cidadeController.text;
    String enderecoBusca = _enderecoController.text;

    if(ufBusca.isEmpty || cidadeBusca.isEmpty || enderecoBusca.isEmpty) {
      _showSnackBar(_locale.locale[TraducaoStringsConstante.LocalidadeErro]);
    } else {
      CarregandoAlertaComponente().showCarregar(context);
      List<CepInfo> listaCeps;
      listaCeps = await CepService().buscaPorLocalidade(
        endereco: enderecoBusca,
        cidade: cidadeBusca,
        uf: ufBusca
      );
      CarregandoAlertaComponente().dismissCarregar(context);

      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ListaEnderecosBuscaComponente(listaCepsOriginal: listaCeps,)),
      );
      if (resultado != null) {
        _preencheInfoCep(cepInfo: resultado);
      }
    }
  }

  _preencheInfoCep({@required CepInfo cepInfo}) {
    setState(() {
      _cepMaskController.text = cepInfo.cep ?? "";

      _enderecoController.text =
        (_enderecoController.text.isEmpty && cepInfo.logradouro.isNotEmpty)
        ? cepInfo.logradouro
        : _enderecoController.text ?? '';

      _bairroController.text =
        (_bairroController.text.isEmpty && cepInfo.bairro.isNotEmpty)
        ? cepInfo.bairro
        : _bairroController.text ?? '';

      _complementoController.text =
        (_complementoController.text.isEmpty && cepInfo.complemento.isNotEmpty)
        ? cepInfo.complemento
        : _complementoController.text ?? '';
      
      _cidadeController.text = cepInfo.localidade ?? "";
      _estadoController.text = cepInfo.uf ?? "";
    });
  }

  void alteraTipoSelecionado(SelectComboBox tipoSelecionado) {
    setState(() {
      _tipoClienteSelecionado = tipoSelecionado;
    });
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }

  Future<bool> _submit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      // if(_clienteProspectModelo.id == null) {
      //     _clienteProspectModelo.id = await Cliente().select().toCount();
      // }
      _clienteProspectModelo.empresaId = _empresaId;
      _clienteProspectModelo.pessoa = _tipoClienteSelecionado.codigo;
      
      _clienteProspectModelo.cnpJCPF = _documento;

      _clienteProspectModelo.nome_razaosocial = _razaoSocialController.text;
      _clienteProspectModelo.nomeFantasia = _nomeFantasiaController.text;

      _clienteProspectModelo.email = _emailController.text;

      _clienteProspectModelo.ddiTelefone = _ddiTelefoneController.text;
      _clienteProspectModelo.dddTelefone = _dddTelefoneController.text;
      _clienteProspectModelo.telefone = _telefoneMaskController.text.replaceAll("-", "");

      _clienteProspectModelo.ddiCelular = _ddiCelularController.text;
      _clienteProspectModelo.dddCelular = _dddCelularController.text;
      _clienteProspectModelo.celular = _celularMaskController.text.replaceAll("-", "");

      _clienteProspectModelo.cep = _cepMaskController.text.replaceAll("-", "");
      _clienteProspectModelo.endereco = _enderecoController.text;
      _clienteProspectModelo.numero = _numeroController.text;
      _clienteProspectModelo.bairro = _bairroController.text;
      _clienteProspectModelo.complemento = _complementoController.text;
      _clienteProspectModelo.cidade = _cidadeController.text;
      _clienteProspectModelo.uf = _estadoController.text;
      return true;
    } else {
      setState(() {
        _showSnackBar(_locale.locale[TraducaoStringsConstante.PreenchaCamposObrigatorios]);
        _autoValidacao = true;
      });
      return false;
    }
  }

  // Future<bool> _salvar() async {
  //   bool resultado;
  //   String clienteProspectJson = json.encode(_clienteProspectModelo.toJson());
  //   Response request = await ClienteService().clienteProspectIncluir(cliente: clienteProspectJson, context: context);
  //   if (request.statusCode == 200) {
  //     _idClienteProspect = int.parse(request.data['id']);
  //     resultado = true;
  //   }
  //   else resultado = false;
  //   return resultado;
  //   // return true;
  // }

  Future<bool> _salvar() async {
    await _clienteProspectModelo.save();
    _idClienteProspect = _clienteProspectModelo.id;
    return true;
  }
  
}
