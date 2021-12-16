import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/compartilhados/componentes/lista-enderecos-busca/lista-enderecos-busca.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/select-busca/select-busca-modal.componente.dart';
import 'package:erp/compartilhados/componentes/select-combobox.componente.dart';
import 'package:erp/models/cliente/lookup/cidadeEstrangeiraLookUp.modelo.dart';
import 'package:erp/models/cliente/outros-enderecos/endereco-editar.modelo.dart';
import 'package:erp/models/cliente/lookup/tipos-enderecos.lookUp.modelo.dart';
import 'package:erp/servicos/cep/cep.servicos.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/cidade-estrangeira.modal.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:search_cep/search_cep.dart';

class CadastroEnderecoTela extends StatefulWidget {
  final EnderecoEditar endereco;
  final int parceiroId;
  final bool estrangeiro;
  CadastroEnderecoTela({this.endereco, this.parceiroId, this.estrangeiro});
  @override
  _CadastroEnderecoTelaState createState() => _CadastroEnderecoTelaState();
}

class _CadastroEnderecoTelaState extends State<CadastroEnderecoTela> {
  EnderecoEditar enderecoEditar = new EnderecoEditar();
  LocalizacaoServico _locale = new LocalizacaoServico();
  Stream<dynamic> _streamComboBoxTiposEnderecos;
  
  // Seleção de tipo de endereço
  List<SelectComboBox> _tiposEnderecos = [];
  List<DropdownMenuItem<SelectComboBox>> _dropDownTiposEnderecos;
  SelectComboBox _tipoEnderecoSelecionado;

  var _cepMaskController = new MaskedTextController(mask: MascarasConstantes.CEP);

  TextEditingController _descricaoOutrosController = new TextEditingController();
  TextEditingController _zipCodeController = new TextEditingController();
  TextEditingController _codigoIBGEController = new TextEditingController();
  TextEditingController _enderecoController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _bairroController = new TextEditingController();
  TextEditingController _complementoController = new TextEditingController();
  TextEditingController _cidadeController = new TextEditingController();
  TextEditingController _estadoController = new TextEditingController();

  TextEditingController _cidadeEstrangeiraShowUpController = new TextEditingController();

  String _descricaoOutros, _cep, _codigoIbge, _endereco, _numero, _bairro,
      _complemento, _cidade, _estado;

  int _cidadeEstrangeiraId;
  CidadeEstrangeiraLookUp _cidadeEstrangeiraSelecionada = new CidadeEstrangeiraLookUp();

  FocusNode _focusDescricaoOutros = new FocusNode();
  FocusNode _focusCEP = new FocusNode();
  FocusNode _focusCodigoIBGE = new FocusNode();
  FocusNode _focusEndereco = new FocusNode();
  FocusNode _focusNumero = new FocusNode();
  FocusNode _focusBairro = new FocusNode();
  FocusNode _focusComplemento = new FocusNode();
  FocusNode _focusCidade = new FocusNode();
  FocusNode _focusCidadeEstrangeira = new FocusNode();
  FocusNode _focusEstado = new FocusNode();

  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autoValidacao = false;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    _streamComboBoxTiposEnderecos = Stream.fromFuture(_populaComboBox());

    EnderecoEditar enderecoEdit = widget.endereco;
    if (enderecoEdit != null) {
      enderecoEditar = enderecoEdit;
      if(enderecoEdit.cidadeEstrangeiroId != null) {
          _preencheCidadeEstrangeira(cidadeEstrangeiraId: enderecoEdit.cidadeEstrangeiroId)
            .then((data) {
              CidadeEstrangeiraLookUp resultadoCidadeEstrangeira = CidadeEstrangeiraLookUp.fromJson(data[0]);
              _cidadeEstrangeiraSelecionada = resultadoCidadeEstrangeira;
              _cidadeEstrangeiraId = _cidadeEstrangeiraSelecionada.id;
              _cidadeEstrangeiraShowUpController.text = _cidadeEstrangeiraSelecionada.descricao;
            });

          _zipCodeController.text = enderecoEdit.cep ?? "";
        }
        else {
          _descricaoOutrosController.text = enderecoEdit.descricaoEnderecoOutros ?? "";
          // CEP
          _cepMaskController.text = enderecoEdit.cep ?? "";
          // Codigo IBGE
          _codigoIBGEController.text = enderecoEdit.codigoIBGE ?? "";
          // Estado
          _estadoController.text = enderecoEdit.uf ?? "";
          // Cidade
          _cidadeController.text = enderecoEdit.cidade ?? "";
        }
        // Endereço
        _enderecoController.text = enderecoEdit.endereco ?? "";
        // Número
        _numeroController.text = enderecoEdit.numero ?? "";
        // Bairro
        _bairroController.text = enderecoEdit.bairro?? "";
        // Complemento
        _complementoController.text = enderecoEdit.complemento ?? "";
    }
  }

  Future<List<SelectComboBox>> _populaComboBox() async {
    bool adicionaDoEndereco = false;

    dynamic requestTiposEnderecos = await ClienteService().outrosEnderecos.getTiposEnderecosTeste(widget.parceiroId);
    List<TiposEnderecosLookUp> listaTipos = new List<TiposEnderecosLookUp>();
    requestTiposEnderecos.forEach((data) {
      listaTipos.add(TiposEnderecosLookUp.fromJson(data));
    });
    _tiposEnderecos.clear();
    for(TiposEnderecosLookUp item in listaTipos) {
      _tiposEnderecos.add(SelectComboBox(codigo: item.codigo, descricao: item.descricao));
    }

    if (widget.endereco != null) {
      for(SelectComboBox item in _tiposEnderecos) {
        if (widget.endereco != null && item.codigo == widget.endereco.tipoEndereco) {
          adicionaDoEndereco = false;
          break;
        }
        else {
          adicionaDoEndereco = true;
        }
      }
    }

    if (adicionaDoEndereco) {
      _tiposEnderecos.add(SelectComboBox(codigo: widget.endereco.tipoEndereco, descricao: widget.endereco.descricaoTipoEndereco));
    }
    
    _dropDownTiposEnderecos = getDropDownItensComboBox(_tiposEnderecos);
    if (widget.endereco != null) {
      for(int i = 0; i < _dropDownTiposEnderecos.length; i++) {
        if(_dropDownTiposEnderecos[i].value.codigo == widget.endereco.tipoEndereco) {
          setState(() {
            _tipoEnderecoSelecionado = _dropDownTiposEnderecos[i].value;
          });
        }
      }
    }
    return _tiposEnderecos;
  }

  Widget _buildComboBox() {
    return StreamBuilder(
      stream: _streamComboBoxTiposEnderecos,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text("${_locale.locale['TipoEndereco']}"),
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
          switch(snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("${_locale.locale['TipoEndereco']}"),
                  Container(
                    height: 48,
                    child: DropdownButton(
                      items: [],
                      onChanged: (_) {},
                    ),
                  )
                ],
              );
            default:
            return Column(
              children: <Widget>[
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    labelText: _locale.locale['TipoEndereco'],
                  ),
                  value: _tipoEnderecoSelecionado,
                  items: _dropDownTiposEnderecos,
                  autovalidate: _autoValidacao,
                  isDense: true,
                  onChanged: alteraTipoSelecionado,
                  validator: (value) {
                    if(value != null) {
                        return null;
                      }
                      else {
                        return _locale.locale['SelecioneTipoEnderecoValidacao'];
                      }
                  },
                ),
              ],
            );
          }
        }
      },
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
              title: Text(widget.endereco == null
                ? _locale.locale['CadastroEndereco']
                : _locale.locale['EditarEndereco']),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  // funcao: () {_submit(funcao: () {});},
                  // funcao: _submit,
                  tooltip: _locale.locale['SalvarEndereco'],
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
                      _buildComboBox(),
                      SizedBox(height: 15,),
                      // Descrição de Outros Endereços
                      (_tipoEnderecoSelecionado != null && _tipoEnderecoSelecionado.codigo == 4)
                      ? TextFormField(
                        controller: _descricaoOutrosController,
                        focusNode: _focusDescricaoOutros,
                        decoration: InputDecoration(
                          labelText: "${_locale.locale['DescricaoEndereco']}",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          _fieldFocusChange(context, _focusDescricaoOutros, _focusCEP);
                        },
                        onSaved: (input) => _descricaoOutros = Validators().fieldFilledValidator(input, _descricaoOutros),
                      )
                      : Container(),
                      
                      widget.estrangeiro
                      ? _enderecoEstrangeiroForm()
                      :_enderecoForm(),
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

  Widget _enderecoForm() {
    return Column(
      children: <Widget>[
        // CEP
        SizedBox(height: 15,),
        TextFormField(
          focusNode: _focusCEP,
          controller: _cepMaskController,
          decoration: InputDecoration(
            labelText: "${_locale.locale['CEP']}",
            border: OutlineInputBorder(),
            counterText: '',
            suffixIcon: Tooltip(
              message: "${_locale.locale['CEPTooltip']}",
              child: InkWell(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${_locale.locale['NaoSeiCEP']}",
                        style: TextStyle(
                          fontSize: 14
                        ),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  _showSnackBar("${_locale.locale['BuscaEndereco']}");
                },
              )
            ),
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) => _buscaCEP(input),
          onChanged: (input) {
            if(input.length == 9) {
              _buscaCEP(input);
            }
          },
          maxLength: 9,
          keyboardType: TextInputType.number,
          validator: (input) {
            if (input.length > 8 && input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['CEPValidacao']}";
            }
          },
          onSaved: (input) {
            _cep = input.replaceAll("-", "");
          }
        ),
        SizedBox(height: 15,),
        
        // Código IBGE
        TextFormField(
          controller: _codigoIBGEController,
          focusNode: _focusCodigoIBGE,
          decoration: InputDecoration(
            counterText: '',
            labelText: "${_locale.locale['CodigoIBGE']}",
            border: OutlineInputBorder(),
          ),
          maxLength: 7,
          keyboardType: TextInputType.phone,
          validator: (input) {
            if (input.length > 6 && input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['CodigoIBGEValidacao']}";
            }
          },
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusCodigoIBGE, _focusEndereco);
          },
          onSaved: (input) => _codigoIbge = input,
        ),
        SizedBox(height: 15,),

        // Endereço
        TextFormField(
          controller: _enderecoController,
          focusNode: _focusEndereco,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Endereco']}",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusEndereco, _focusNumero);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['EnderecoValidacao']}";
            }
          },
          onSaved: (input) => _endereco = Validators().fieldFilledValidator(input, _endereco),
        ),
        SizedBox(height: 15,),

        // Número
        TextFormField(
          controller: _numeroController,
          focusNode: _focusNumero,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Numero']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusNumero, _focusBairro);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['NumeroValidacao']}";
            }
          },
          onSaved: (input) => _numero = Validators().fieldFilledValidator(input, _numero),
        ),
        SizedBox(height: 15,),

        // Bairro
        TextFormField(
          controller: _bairroController,
          focusNode: _focusBairro,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Bairro']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusBairro, _focusComplemento);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['BairroValidacao']}";
            }
          },
          onSaved: (input) => _bairro = Validators().fieldFilledValidator(input, _bairro),
        ),
        SizedBox(height: 15,),

        // Complemento
        TextFormField(
          controller: _complementoController,
          focusNode: _focusComplemento,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Complemento']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context,_focusComplemento, _focusCidade);
          },
          onSaved: (input) => _complemento = Validators().fieldFilledValidator(input, _complemento),
        ),
        SizedBox(height: 15,),

        // Cidade
        TextFormField(
          controller: _cidadeController,
          focusNode: _focusCidade,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Cidade']}",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context,_focusCidade, _focusEstado);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['CidadeValidacao']}";
            }
          },
          onSaved: (input) => _cidade = Validators().fieldFilledValidator(input, _cidade),
        ),
        SizedBox(height: 15,),

        // Estado
        TextFormField(
          controller: _estadoController,
          focusNode: _focusEstado,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Estado']}",
            counterText: '',
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.blue[700],),
              onPressed: () {
                _preencheInfoCepDeEndereco();
              },
              tooltip: "${_locale.locale['LocalidadeTooltip']}",
            )
          ),
          maxLength: 2,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['LocalidadeTooltip']}";
            }
          },
          onSaved: (input) => _estado = Validators().fieldFilledValidator(input, _estado),
        ),
        SizedBox(height: 15,),
      ],
    );
  }

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensComboBox(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  Widget _enderecoEstrangeiroForm() {
    return Column(
      children: <Widget>[
        // Zip Code
        SizedBox(height: 15,),
        TextFormField(
          focusNode: _focusCEP,
          controller: _zipCodeController,
          decoration: InputDecoration(
            labelText: "${_locale.locale['ZipCode']}",
            border: OutlineInputBorder(),
            counterText: '',
          ),
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (input) => _buscaCEP(input),
          maxLength: 20,
          keyboardType: TextInputType.number,
          onSaved: (input) {
            _cep = input.replaceAll("-", "");
          }
        ),
        SizedBox(height: 15,),

        // Endereço
        TextFormField(
          controller: _enderecoController,
          focusNode: _focusEndereco,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Endereco']}",
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusEndereco, _focusNumero);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['EnderecoValidacao']}";
            }
          },
          onSaved: (input) => _endereco = Validators().fieldFilledValidator(input, _endereco),
        ),
        SizedBox(height: 15,),

        // Número
        TextFormField(
          controller: _numeroController,
          focusNode: _focusNumero,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Numero']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusNumero, _focusBairro);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['NumeroValidacao']}";
            }
          },
          onSaved: (input) => _numero = Validators().fieldFilledValidator(input, _numero),
        ),
        SizedBox(height: 15,),

        // Bairro
        TextFormField(
          controller: _bairroController,
          focusNode: _focusBairro,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Bairro']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context, _focusBairro, _focusComplemento);
          },
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['BairroValidacao']}";
            }
          },
          onSaved: (input) => _bairro = Validators().fieldFilledValidator(input, _bairro),
        ),
        SizedBox(height: 15,),

        // Complemento
        TextFormField(
          controller: _complementoController,
          focusNode: _focusComplemento,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Complemento']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) {
            _fieldFocusChange(context,_focusComplemento, _focusCidade);
          },
          onSaved: (input) => _complemento = Validators().fieldFilledValidator(input, _complemento),
        ),
        SizedBox(height: 15,),

        // Cidade
        TextFormField(
          controller: _cidadeEstrangeiraShowUpController,
          focusNode: _focusCidadeEstrangeira,
          readOnly: true,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Cidade']}",
            border: OutlineInputBorder(),
          ),
          onTap: () async {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CidadeEstrangeiraModal())
            );
            if (resultado != null) {
              _cidadeEstrangeiraSelecionada = resultado;
              _cidadeEstrangeiraShowUpController.text = _cidadeEstrangeiraSelecionada.descricao;
            }
          },
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.text,
          // onSaved: (input) => _cidadeEstrangeiraId = Validators().fieldFilledValidator(input, _cidadeEstrangeiraId),
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locale.locale['CidadeValidacao']}";
            }
          },
          onSaved: (_) => _cidadeEstrangeiraId = _cidadeEstrangeiraSelecionada.id,
        ),
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

  _buscaCEP(String input) {
    CarregandoAlertaComponente().showCarregar(context);
    CepService().buscaPorCep(cep: input)
      .then((data) {
        _preencheInfoCep(cepInfo: data);
        CarregandoAlertaComponente().dismissCarregar(context);
      })
      .catchError((e) {
        CarregandoAlertaComponente().dismissCarregar(context);
        _showSnackBar(_locale.locale['CEPValidacao']);
      });
    _fieldFocusChange(context, _focusCEP, _focusCodigoIBGE);
  }

  _preencheInfoCepDeEndereco() async {
    String ufBusca = _estadoController.text;
    String cidadeBusca = _cidadeController.text;
    String enderecoBusca = _enderecoController.text;

    if(ufBusca.isEmpty || cidadeBusca.isEmpty || enderecoBusca.isEmpty) {
      _showSnackBar("${_locale.locale['LocalidadeErro']}");
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
      _codigoIBGEController.text = cepInfo.ibge ?? "";
      _enderecoController.text = cepInfo.logradouro ?? "";
      _bairroController.text = cepInfo.bairro ?? "";
      _complementoController.text = cepInfo.complemento ?? "";
      _cidadeController.text = cepInfo.localidade ?? "";
      _estadoController.text = cepInfo.uf ?? "";
    });
  }

  Future _preencheCidadeEstrangeira({int cidadeEstrangeiraId}) async{
    return await ClienteService().cidadeEstrangeira.getCidadeEstrangeira(cidadeEstrangeiraId);
  }

  void alteraTipoSelecionado(SelectComboBox tipoSelecionado) {
    setState(() {
      _tipoEnderecoSelecionado = tipoSelecionado;
    });
  }

  bool _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();

      enderecoEditar.parceiroId = widget.parceiroId;
      enderecoEditar.tipoEndereco = _tipoEnderecoSelecionado.codigo;
      enderecoEditar.descricaoEnderecoOutros = _descricaoOutros;
      enderecoEditar.cep = _cep;
      enderecoEditar.codigoIBGE = _codigoIbge;
      enderecoEditar.endereco = _endereco;
      enderecoEditar.numero = _numero;
      enderecoEditar.bairro = _bairro;
      enderecoEditar.complemento = _complemento;
      enderecoEditar.cidade = _cidade;
      enderecoEditar.uf = _estado;
      enderecoEditar.cidadeEstrangeiroId = _cidadeEstrangeiraId ?? null;
      
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
    // Tratar Cadastro Cliente
    bool resultado;
    if (enderecoEditar.id == null) {
      String enderecoJson = json.encode(enderecoEditar.novoEnderecoJson());
      Response request = await ClienteService().outrosEnderecos.adicionarEndereco(
        endereco: enderecoJson, context: context
      );
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String enderecoJson = json.encode(enderecoEditar.toJson());
      Response request = await ClienteService().outrosEnderecos.editarEndereco(
        endereco: enderecoJson, context: context
      );
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
