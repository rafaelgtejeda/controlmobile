import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/models/parametro.modelo.dart';
import 'package:erp/servicos/cep/cep.servicos.dart';
import 'package:erp/servicos/parametro.servicos.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:erp/models/cliente/consulta-cnpj.modelo.dart';
import 'package:erp/models/cliente/cliente-editar.modelo.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/models/cliente/lookup/regiaoLookUp.modelo.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/regiao.modal.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/grupo-contato.modal.dart';
import 'package:erp/compartilhados/componentes/vendedor-selecao/vendedor-selecao.componente.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/cidade-estrangeira.modal.dart';
import 'package:erp/compartilhados/componentes/lista-enderecos-busca/lista-enderecos-busca.componente.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/ramo-atividade.modal.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/modals-listas/tabela-preco.modal.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/select-combobox.componente.dart';
import 'package:erp/models/cliente/lookup/cidadeEstrangeiraLookUp.modelo.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/models/cliente/lookup/ramoAtividadeLookUp.modelo.dart';
import 'package:erp/models/cliente/lookup/grupoContatoLookUp.modelo.dart';
import 'package:erp/compartilhados/componentes/accordion.componente.dart';
import 'package:erp/models/cliente/lookup/tabelaPrecoLookUp.modelo.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/lista-paises/lista-paises.tela.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:search_cep/search_cep.dart';
import 'package:erp/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:erp/utils/helper.dart';

class CadastroClienteTela extends StatefulWidget {
  final ClienteEditar cliente;
  CadastroClienteTela({this.cliente});

  @override
  _CadastroClienteTelaState createState() => _CadastroClienteTelaState();
}

class _CadastroClienteTelaState extends State<CadastroClienteTela> {
  ClienteEditar clienteEditar = new ClienteEditar();

  LocalizacaoServico _locale = new LocalizacaoServico();

  RequestUtil requestUtil = new RequestUtil();
  Helper helper = new Helper();

  bool _autoValidacao = false;
  bool _naoSeiCEP = false;

  int _parceiroId;

  RamoAtividadeLookUp _ramoAtividadeSelecionado = new RamoAtividadeLookUp();
  RegiaoLookUp _regiaoSelecionada = new RegiaoLookUp();
  GrupoContatoLookUp _grupoContatoSelecionado = new GrupoContatoLookUp();
  CidadeEstrangeiraLookUp _cidadeEstrangeiraSelecionada = new CidadeEstrangeiraLookUp();
  VendedoresLookUp _vendedorSelecionado = new VendedoresLookUp();
  TabelaPrecoLookUp _tabelaPrecoSelecionada = new TabelaPrecoLookUp();

  String pessoaJuridicaTipoSelect = '';
  String pessoaFisicaTipoSelect = '';
  String estrangeiroTipoSelect = '';
  String produtorRuralTipoSelect = '';
  // Seleção de tipo de cliente
  // List<SelectComboBox> _tipos = [
  //   SelectComboBox(codigo: 1, descricao: "Pessoa Jurídica"),
  //   SelectComboBox(codigo: 2, descricao: "Pessoa Física"),
  //   SelectComboBox(codigo: 3, descricao: "Estrangeiro"),
  //   SelectComboBox(codigo: 4, descricao: "Produtor Rural"),
  // ];
  List<SelectComboBox> _tipos = new List<SelectComboBox>();
  List<DropdownMenuItem<SelectComboBox>> _dropDownTiposClientes;
  SelectComboBox _tipoClienteSelecionado;
  Stream<dynamic> _streamTipos;

  String vazioSituacaoSelect = '';
  String ativoSituacaoSelect = '';
  String inativoSituacaoSelect = '';
  String bloqueadoSituacaoSelect = '';
  // Seleção de situação de cliente
  List<SelectComboBox> _clienteSituacao = [
    // SelectComboBox(codigo: 0, descricao: ""),
    // SelectComboBox(codigo: 1, descricao: "Ativo"),
    // SelectComboBox(codigo: 2, descricao: "Inativo"),
    // SelectComboBox(codigo: 3, descricao: "Bloqueado"),

  ];
  List<DropdownMenuItem<SelectComboBox>> _dropDownSituacaoCliente;
  SelectComboBox _situacaoClienteSelecionado;

  // Seleção de contrbuição para Inscrição Estadual
  int radioGroupContribuicao = 0;
  // Seleção dos tipo de limite de crédito
  int radioGroupLimiteCredito = 0;

  bool _enableContribuicao = true;


  // Focus Nodes
  FocusNode _focusRazaoSocial = new FocusNode();
  FocusNode _focusNomeFantasia = new FocusNode();
  FocusNode _focusCodigo = new FocusNode();
  FocusNode _focusSituacao = new FocusNode();

  FocusNode _focusRamoAtividade = new FocusNode();
  FocusNode _focusRegiao = new FocusNode();
  FocusNode _focusGrupoContato = new FocusNode();

  FocusNode _focusDDITelefone1 = new FocusNode();
  FocusNode _focusDDITelefone2 = new FocusNode();
  FocusNode _focusDDICelular = new FocusNode();

  FocusNode _focusCEP = new FocusNode();
  FocusNode _focusCodigoIBGE = new FocusNode();
  FocusNode _focusEndereco = new FocusNode();
  FocusNode _focusNumero = new FocusNode();
  FocusNode _focusBairro = new FocusNode();
  FocusNode _focusComplemento = new FocusNode();
  FocusNode _focusCidade = new FocusNode();
  FocusNode _focusCidadeEstrangeira = new FocusNode();
  FocusNode _focusEstado = new FocusNode();

  FocusNode _focusVendedorResponsavel = new FocusNode();
  FocusNode _focusTabelaPreco = new FocusNode();


  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  // Atributos para submissão
  int _empresaId;

  String _documento, _inscricaoMunicipal, _rg,
      _inscricaoEstadual, _razaoSocial, _nomeFantasia,
      _codigo, _email;

  String _ddiTelefone1, _dddTelefone1, _numeroTelefone1,
      _ddiTelefone2, _dddTelefone2, _numeroTelefone2,
      _ddiCelular, _dddCelular, _numeroCelular;

  String _cep, 
         _codigoIbge, 
         _endereco, _numero, _bairro,
         _complemento, _cidade, _estado;

  int _ramoAtividadeId, _regiaoId, _grupoContatoId;
  int _cidadeEstrangeiraId;
  int _vendedorId, _tabelaPrecoId;
  double _limiteCredito = 0.0;

  // Input Controllers
  TextEditingController _documentoEstrangeiroController = new TextEditingController();

  TextEditingController _rgController = new TextEditingController();
  TextEditingController _inscricaoMunicipalController = new TextEditingController();
  TextEditingController _inscricaoEstadualController = new TextEditingController();

  TextEditingController _razaoSocialController = new TextEditingController();
  TextEditingController _nomeFantasiaController = new TextEditingController();
  TextEditingController _codigoController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _ddiTelefone1Controller = new TextEditingController();
  TextEditingController _dddTelefone1Controller = new TextEditingController();

  TextEditingController _ddiTelefone2Controller = new TextEditingController();
  TextEditingController _dddTelefone2Controller = new TextEditingController();

  TextEditingController _ddiCelularController = new TextEditingController();
  TextEditingController _dddCelularController = new TextEditingController();

  TextEditingController _zipCodeController = new TextEditingController();
  TextEditingController _codigoIBGEController = new TextEditingController();
  TextEditingController _enderecoController = new TextEditingController();
  TextEditingController _numeroController = new TextEditingController();
  TextEditingController _bairroController = new TextEditingController();
  TextEditingController _complementoController = new TextEditingController();
  TextEditingController _cidadeController = new TextEditingController();
  TextEditingController _estadoController = new TextEditingController();
  
  TextEditingController _ramoAtividadeShowUpController = new TextEditingController();
  TextEditingController _regiaoShowUpController = new TextEditingController();
  TextEditingController _grupoContatoShowUpController = new TextEditingController();
  TextEditingController _cidadeEstrangeiraShowUpController = new TextEditingController();

  TextEditingController _vendedorShowUpController = new TextEditingController();
  TextEditingController _tabelaPrecoShowUpController = new TextEditingController();

  var _limiteCreditoController = new MoneyMaskedTextController();
  var _limiteConsumidoController = new MoneyMaskedTextController();
  var _limiteRestanteController = new MoneyMaskedTextController();

  // Inputs com máscaras
  var _cpfMaskController = new MaskedTextController(mask: MascarasConstantes.CPF);
  var _cnpjMaskController = new MaskedTextController(mask: MascarasConstantes.CNPJ);
  var _telefone1MaskController = new MaskedTextController(mask: MascarasConstantes.PHONE_BR);
  var _telefone2MaskController = new MaskedTextController(mask: MascarasConstantes.PHONE_BR);
  var _celularMaskController = new MaskedTextController(mask: MascarasConstantes.MOBILE_PHONE_BR);
  var _cepMaskController = new MaskedTextController(mask: MascarasConstantes.CEP);

  // Situação Setup
  Stream<dynamic> _streamComboBoxClienteSituacao;

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context)
      .then((value) {
        if(widget.cliente == null) {
          _limiteCreditoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');

          _limiteConsumidoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');

          _limiteRestanteController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ');
        }
        else {
          _limiteCreditoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.cliente.totalLimite ?? 0);

          _limiteConsumidoController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.cliente.limiteConsumido ?? 0);

          _limiteRestanteController = new MoneyMaskedTextController(leftSymbol: '${_locale.locale[TraducaoStringsConstante.MoedaLocal]} ', initialValue: widget.cliente.limiteRestante ?? 0);
        }
      });

    /*
    // _streamComboBoxClienteSituacao = Stream.fromFuture(_populaComboBox());
    // _populaComboBox()
    //   .then((data) {
    //     setState(() {
    //       _clienteSituacao = data;
    //     });
    //   });
    */

    _getEmpresaId();
    ClienteEditar clienteEdit = widget.cliente;
    // _dropDownTiposClientes = getDropDownItensSelecao(_tipos);
    _streamTipos = Stream.fromFuture(_tiposClientesStream());
    /*
    // _dropDownSituacaoCliente = getDropDownItensSelecao(_clienteSituacao);
    */
    if (clienteEdit != null) {
      if (clienteEdit.pessoa == 0) {
        clienteEdit.pessoa = 2;
      }
      clienteEditar = clienteEdit;
      _parceiroId = clienteEdit.id;
      clienteEdit.empresaId = _empresaId;

      switch (clienteEdit.pessoa) {
        case 1:
          _cnpjMaskController.text = clienteEdit.cnpJCPF;
          break;
        case 2:
        case 4:
          _cpfMaskController.text = clienteEdit.cnpJCPF;
          break;
        case 3:
          _documentoEstrangeiroController.text = clienteEdit.cnpJCPF;
          break;
      }

      _rgController.text = clienteEdit.rg ?? "";

      _inscricaoMunicipalController.text = clienteEdit.im ?? "";
      _inscricaoEstadualController.text = clienteEdit.ie ?? "";
      if (clienteEdit.ie == "NÃO CONTRIBUINTE" || clienteEdit.ie == "ISENTO") { }
      switch (clienteEdit.ie) {
        case "NÃO CONTRIBUINTE":
          radioGroupContribuicao = 1;
          break;
        case "ISENTO":
          radioGroupContribuicao = 2;
          break;
        default:
          radioGroupContribuicao = 0;
          break;
      }
      _razaoSocialController.text = clienteEdit.nome ?? "";
      _nomeFantasiaController.text = clienteEdit.nomeFantasia ?? "";
      _codigoController.text = clienteEdit.codigo ?? "";
      // Situação
      // _situacaoClienteSelecionado = _dropDownSituacaoCliente[clienteEdit.situacao].value ?? 0;
      // if (clienteEdit.situacao != 0 && _dropDownSituacaoCliente.length > 3) {
      //   _dropDownSituacaoCliente.removeRange(0, 1);
      // }

      // Ramo de Atividade
      if (clienteEdit.ramoAtividadeId != null) {
        _preencheRamoAtividade(ramoAtividadeId: clienteEdit.ramoAtividadeId).then((data) {
          RamoAtividadeLookUp resultadoRamo = RamoAtividadeLookUp.fromJson(data[0]);
          _ramoAtividadeSelecionado = resultadoRamo;
          _ramoAtividadeId = _ramoAtividadeSelecionado.id;
          _ramoAtividadeShowUpController.text = _ramoAtividadeSelecionado.descricao;
        });
      }
      // Região
      if (clienteEdit.regiaoId != null) {
        _preencheRegiao(regiaoId: clienteEdit.regiaoId).then((data) {
          RegiaoLookUp resultadoRegiao = RegiaoLookUp.fromJson(data[0]);
          _regiaoSelecionada = resultadoRegiao;
          _regiaoId = _regiaoSelecionada.id;
          _regiaoShowUpController.text = _regiaoSelecionada.descricao;
        });
      }
      // Grupo de Contato
      if (clienteEdit.grupoContatoId != null) {
        _preencheGrupoContato(grupoContatoId: clienteEdit.grupoContatoId).then((data) {
          GrupoContatoLookUp resultadoGrupoContato = GrupoContatoLookUp.fromJson(data[0]);
          _grupoContatoSelecionado = resultadoGrupoContato;
          _grupoContatoId = _grupoContatoSelecionado.id;
          _grupoContatoShowUpController.text = _grupoContatoSelecionado.descricao;
        });
      }
      
      // Email
      if(clienteEdit.contatoPrincipal != null) {
        _emailController.text = (clienteEdit.contatoPrincipal.email) ?? "";
        
        if(clienteEdit.contatoPrincipal.telefone.ddi == "NaN" || clienteEdit.contatoPrincipal.telefone.ddi == null
        || clienteEdit.contatoPrincipal.telefone.ddd == "NaN" || clienteEdit.contatoPrincipal.telefone.ddd == null) {}
        else {
          // DDI Telefone 1
          _ddiTelefone1Controller.text = (clienteEdit.contatoPrincipal.telefone.ddi) ?? "";
          // DDD Telefone 1
          _dddTelefone1Controller.text = (clienteEdit.contatoPrincipal.telefone.ddd) ?? "";
          // Telefone 1
          _telefone1MaskController.text = (clienteEdit.contatoPrincipal.telefone.phone) ?? "";
        }

        if(clienteEdit.contatoPrincipal.telefone2.ddi == "NaN" || clienteEdit.contatoPrincipal.telefone2.ddi == null
        || clienteEdit.contatoPrincipal.telefone2.ddd == "NaN" || clienteEdit.contatoPrincipal.telefone2.ddd == null) {}
        else {
          // DDI Telefone 2
          _ddiTelefone2Controller.text = (clienteEdit.contatoPrincipal.telefone2.ddi) ?? "";
          // DDD Telefone 2
          _dddTelefone2Controller.text = (clienteEdit.contatoPrincipal.telefone2.ddd) ?? "";
          // Telefone 2
          _telefone2MaskController.text = (clienteEdit.contatoPrincipal.telefone2.phone) ?? "";
        }

        if(clienteEdit.contatoPrincipal.celular.ddi == "NaN" || clienteEdit.contatoPrincipal.celular.ddi == null
        || clienteEdit.contatoPrincipal.celular.ddd == "NaN" || clienteEdit.contatoPrincipal.celular.ddd == null) {}
        else {
          // DDI Celular
          _ddiCelularController.text = (clienteEdit.contatoPrincipal.celular.ddi) ?? "";
          // DDD Celular
          _dddCelularController.text = (clienteEdit.contatoPrincipal.celular.ddd) ?? "";
          // Celular
          _celularMaskController.text = (clienteEdit.contatoPrincipal.celular.phone) ?? "";
        }
      }

      if(clienteEdit.enderecoPrincipal != null) {
        if(clienteEdit.enderecoPrincipal.cidadeEstrangeiroId != null && clienteEdit.enderecoPrincipal.codigoIBGE == null) {
          _preencheCidadeEstrangeira(cidadeEstrangeiraId: clienteEdit.enderecoPrincipal.cidadeEstrangeiroId)
            .then((data) {
              CidadeEstrangeiraLookUp resultadoCidadeEstrangeira = CidadeEstrangeiraLookUp.fromJson(data[0]);
              _cidadeEstrangeiraSelecionada = resultadoCidadeEstrangeira;
              _cidadeEstrangeiraId = _cidadeEstrangeiraSelecionada.id;
              _cidadeEstrangeiraShowUpController.text = _cidadeEstrangeiraSelecionada.descricao;
            });

          _zipCodeController.text = clienteEdit.enderecoPrincipal.cep ?? "";
        }
        if (clienteEdit.enderecoPrincipal.cidadeEstrangeiroId == null && clienteEdit.pessoa == 3 
          && (clienteEdit.enderecoPrincipal.cep != null || clienteEdit.enderecoPrincipal.cep != '')) {
          _zipCodeController.text = clienteEdit.enderecoPrincipal.cep ?? "";
        }
        // CEP
        _cepMaskController.text = clienteEdit.enderecoPrincipal.cep ?? "";
        // Codigo IBGE
        _codigoIBGEController.text = clienteEdit.enderecoPrincipal.codigoIBGE ?? "";
        // Estado
        _estadoController.text = clienteEdit.enderecoPrincipal.uf ?? "";
        // Cidade
        _cidadeController.text = clienteEdit.enderecoPrincipal.cidade ?? "";
        // Endereço
        _enderecoController.text = clienteEdit.enderecoPrincipal.endereco ?? "";
        // Número
        _numeroController.text = clienteEdit.enderecoPrincipal.numero ?? "";
        // Bairro
        _bairroController.text = clienteEdit.enderecoPrincipal.bairro?? "";
        // Complemento
        _complementoController.text = clienteEdit.enderecoPrincipal.complemento ?? "";
      }

      // Vendedor Responsável
      if (clienteEdit.vendedorId != null) {
        _preencheVendedor(vendedorId: clienteEdit.vendedorId).then((data) {
          VendedoresLookUp resultadoVendedor = VendedoresLookUp.fromJson(data[0]);
          _vendedorSelecionado = resultadoVendedor;
          _vendedorId = _vendedorSelecionado.id;
          _vendedorShowUpController.text = _vendedorSelecionado.nome;
        });
      }
      // Tabela Preço
      if (clienteEdit.tabelaPrecoId != null) {
        _preencheTabelaPreco(tabelaPrecoId: clienteEdit.tabelaPrecoId).then((data) {
          TabelaPrecoLookUp resultadoTabelaPreco = TabelaPrecoLookUp.fromJson(data[0]);
          _tabelaPrecoSelecionada = resultadoTabelaPreco;
          _tabelaPrecoId = _tabelaPrecoSelecionada.id;
          _tabelaPrecoShowUpController.text = _tabelaPrecoSelecionada.descricao;
        });
      }

      // Limite de Crédito
      radioGroupLimiteCredito = clienteEdit.tipoLimite;
      // _limiteCreditoController.updateValue(clienteEdit.totalLimite ?? 0);
      // Limite Consumido
      // _limiteConsumidoController.text = clienteEdit.limiteConsumido.toString() ?? "0";
      // Limite Restante
      // _limiteRestanteController.text = clienteEdit.limiteRestante.toString() ?? "0";
    }
    else {
      _preencheCliente();
      // _tipoClienteSelecionado = _dropDownTiposClientes[0].value;

      _getPadraoLimiteCredito();
      _limiteCreditoController.updateValue(0);
      _limiteConsumidoController.updateValue(0);
      _limiteRestanteController.updateValue(0);
    }
  }

  Future<List<SelectComboBox>> _tiposClientesStream() async {
    await _locale.iniciaLocalizacao(context);

    SelectComboBox tipoJuridica = new SelectComboBox();
    tipoJuridica.codigo = 1;
    tipoJuridica.descricao = _locale.locale[TraducaoStringsConstante.PessoaJuridica];

    SelectComboBox tipoFisica = new SelectComboBox();
    tipoFisica.codigo = 2;
    tipoFisica.descricao = _locale.locale[TraducaoStringsConstante.PessoaFisica];

    SelectComboBox tipoEstrangeiro = new SelectComboBox();
    tipoEstrangeiro.codigo = 3;
    tipoEstrangeiro.descricao = _locale.locale[TraducaoStringsConstante.Estrangeiro];

    SelectComboBox tipoProdutorRural = new SelectComboBox();
    tipoProdutorRural.codigo = 4;
    tipoProdutorRural.descricao = _locale.locale[TraducaoStringsConstante.ProdutorRural];

    _tipos.add(tipoJuridica);
    _tipos.add(tipoFisica);
    _tipos.add(tipoEstrangeiro);
    _tipos.add(tipoProdutorRural);

    _dropDownTiposClientes = getDropDownItensSelecao(_tipos);

    if(widget.cliente != null) {
      _tipoClienteSelecionado = _dropDownTiposClientes[((widget.cliente.pessoa) - 1)].value;
    }
    else {
      _tipoClienteSelecionado = _dropDownTiposClientes[0].value;
    }

    return _tipos;
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

  // Future<ParametroModelo> _getPadraoLimiteCredito() async {
  Future _getPadraoLimiteCredito() async {
    dynamic requestLimiteCreditoPadrao = await ParametroService().getParametroPadraoLimiteCredito();
    ParametroModelo parametro = ParametroModelo.fromJson(requestLimiteCreditoPadrao);

    switch (parametro.valor) {
      case TiposPadraoLimiteCredito.NAO_CONTROLAR:
        setState(() {
          radioGroupLimiteCredito = 0;
        });
        break;
      case TiposPadraoLimiteCredito.POR_TOTAL:
        setState(() {
          radioGroupLimiteCredito = 1;
        });
        break;
      case TiposPadraoLimiteCredito.POR_FORMA_RECEBIMETO:
        setState(() {
          radioGroupLimiteCredito = 2;
        });
        break;
      default:
        setState(() {
          radioGroupLimiteCredito = 0;
        });
        break;
    }

    // return parametro;
  }

  /*
  // Future<List<SelectComboBox>> _populaComboBox() async {
  //   dynamic requestSituacoesClientes = await ClienteService().clienteSituacoesLookup();
  //   List<ClienteSituacaoLookup> listaSituacoes = new List<ClienteSituacaoLookup>();
  //   requestSituacoesClientes.forEach((data) {
  //     listaSituacoes.add(ClienteSituacaoLookup.fromJson(data));
  //   });
  //   _clienteSituacao.clear();
  //   for(ClienteSituacaoLookup item in listaSituacoes) {
  //     _clienteSituacao.add(SelectComboBox(codigo: item.id, descricao: item.descricao));
  //   }
    
  //   _dropDownSituacaoCliente = getDropDownItensComboBox(_clienteSituacao);
  //   if (widget.cliente != null) {
  //     for(int i = 0; i < _dropDownSituacaoCliente.length; i++) {
  //       if(_dropDownSituacaoCliente[i].value.codigo == widget.cliente.situacaoParceiro) {
  //         setState(() {
  //           _situacaoClienteSelecionado = _dropDownSituacaoCliente[i].value;
  //         });
  //       }
  //     }
  //   }
  //   return _clienteSituacao;
  // }

  // Widget _buildCombo() {
  //   return Column(
  //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: <Widget>[
  //       // Text("${_locale.locale['Situacao']}"),
  //       DropdownButtonFormField(
  //         decoration: InputDecoration(
  //           labelText: _locale.locale['Situacao'],
  //         ),
  //         value: _situacaoClienteSelecionado,
  //         items: _dropDownSituacaoCliente,
  //         autovalidate: _autoValidacao,
  //         isDense: true,
  //         onChanged: alteraSituacaoSelecionado,
  //         validator: (value) {
  //           if(value != null) {
  //               return null;
  //             }
  //             else {
  //               return _locale.locale['SelecioneSituacaoValidacao'];
  //             }
  //         },
  //       )
  //     ],
  //   );
  // }
  */

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensComboBox(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  _preencheCliente() {
    EnderecoPrincipal endereco = new EnderecoPrincipal();
    ContatoPrincipal contato = new ContatoPrincipal();

    Telefone telefone1 = new Telefone();
    Telefone telefone2 = new Telefone();
    Telefone celular = new Telefone();

    contato.telefone = telefone1;
    contato.telefone2 = telefone2;
    contato.celular = celular;

    clienteEditar.enderecoPrincipal = endereco;
    clienteEditar.contatoPrincipal = contato;
  }

  Future _preencheRamoAtividade({int ramoAtividadeId}) async{
    return await ClienteService().ramoAtividade.getRamoAtividade(ramoAtividadeId);
  }

  _adicionaRamoAtividade() async {
    TextEditingController _ramoAtividadeAddCodigo = new TextEditingController();
    TextEditingController _ramoAtividadeAddDescricao = new TextEditingController();
    RamoAtividadeCadastro _ramoAtividadeSalvar = new RamoAtividadeCadastro();
    RamoAtividadeUltimoCodigo _ultimoCodigo = new RamoAtividadeUltimoCodigo();
    final _formRamoAtividadeKey = GlobalKey<FormState>();
    RequestUtil _request = new RequestUtil();

    dynamic ultimoCodigo = await ClienteService().ramoAtividade.getUltimoCodigoRamoAtividade();
    print(ultimoCodigo);
    _ultimoCodigo = RamoAtividadeUltimoCodigo.fromJson(
      await ClienteService().ramoAtividade.getUltimoCodigoRamoAtividade()
    );
    _ramoAtividadeId = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(_locale.locale['CadastroRamoAtividade']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('${_locale.locale['UltimoCodigoRamo']}: ${_ultimoCodigo.codigo}'),
            SizedBox(
              height: 15
            ),
            Form(
              key: _formRamoAtividadeKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _ramoAtividadeAddCodigo,
                    decoration: InputDecoration(
                      labelText: "${_locale.locale['Codigo']}",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (input) {
                      if(input.isNotEmpty) {
                        return null;
                      }
                      else {
                        return _locale.locale['PreenchaCamposObrigatorios'];
                      }
                    },
                    onSaved: (input) {
                      _ramoAtividadeSalvar.codigo = input;
                    },
                  ),
                  SizedBox(
                    height: 15
                  ),
                  TextFormField(
                    controller: _ramoAtividadeAddDescricao,
                    decoration: InputDecoration(
                      labelText: "${_locale.locale['Descricao']}",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (input) {
                      if(input.isNotEmpty) {
                        return null;
                      }
                      else {
                        return _locale.locale['PreenchaCamposObrigatorios'];
                      }
                    },
                    onSaved: (input) {
                      _ramoAtividadeSalvar.descricao = input;
                    },
                  )
                ],
              )
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              if (_formRamoAtividadeKey.currentState.validate()) {
                _formRamoAtividadeKey.currentState.save();
                _ramoAtividadeSalvar.empresaId = await _request.obterIdEmpresaShared();

                String ramoAtividadeJson = json.encode(_ramoAtividadeSalvar.novoRamoAtividadeJson());
                Response resposta = await ClienteService().ramoAtividade.adicionaRamoAtividade(ramoAtividadeJson, context: context);
                if (resposta.statusCode == 200) {
                  Navigator.of(context).pop(int.parse(resposta.data['id']));
                }
              }
            },
            child: Text(_locale.locale['Salvar'])
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(_locale.locale['Cancelar'])
          ),
        ],
      )
    );
    if(_ramoAtividadeId != null) {
      _preencheRamoAtividade(ramoAtividadeId: _ramoAtividadeId).then((data) {
        RamoAtividadeLookUp resultadoRamo = RamoAtividadeLookUp.fromJson(data[0]);
        _ramoAtividadeSelecionado = resultadoRamo;
        _ramoAtividadeId = _ramoAtividadeSelecionado.id;
        _ramoAtividadeShowUpController.text = _ramoAtividadeSelecionado.descricao;
      });
    }
  }

  Future _preencheRegiao({int regiaoId}) async{
    return await ClienteService().regiao.getRegiao(regiaoId);
  }

  _adicionaRegiao() async {
    TextEditingController _regiaoAddDescricao = new TextEditingController();
    RegiaoCadastro _regiaoSalvar = new RegiaoCadastro();
    final _formRegiaoKey = GlobalKey<FormState>();
    RequestUtil _request = new RequestUtil();
    _regiaoId = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(_locale.locale['CadastroRegiao']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Form(
              key: _formRegiaoKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _regiaoAddDescricao,
                    decoration: InputDecoration(
                      labelText: "${_locale.locale['Descricao']}",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (input) {
                      if(input.isNotEmpty) {
                        return null;
                      }
                      else {
                        return _locale.locale['PreenchaCamposObrigatorios'];
                      }
                    },
                    onSaved: (input) {
                      _regiaoSalvar.descricao = input;
                    },
                  )
                ],
              )
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              if (_formRegiaoKey.currentState.validate()) {
                _formRegiaoKey.currentState.save();
                _regiaoSalvar.empresaId = await _request.obterIdEmpresaShared();

                String regiaoJson = json.encode(_regiaoSalvar.novaRegiaoJson());
                Response resposta = await ClienteService().regiao.adicionaRegiao(regiaoJson, context: context);
                if (resposta.statusCode == 200) {
                  Navigator.of(context).pop(int.parse(resposta.data['id']));
                }
              }
            },
            child: Text(_locale.locale['Salvar'])
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(_locale.locale['Cancelar'])
          ),
        ],
      )
    );
    if(_regiaoId != null) {
      _preencheRegiao(regiaoId: _regiaoId).then((data) {
        RegiaoLookUp resultadoRegiao = RegiaoLookUp.fromJson(data[0]);
        _regiaoSelecionada = resultadoRegiao;
        _regiaoId = _regiaoSelecionada.id;
        _regiaoShowUpController.text = _regiaoSelecionada.descricao;
      });
    }
  }

  Future _preencheGrupoContato({int grupoContatoId}) async{
    return await ClienteService().grupoContato.getGrupoContato(grupoContatoId);
  }

  _adicionaGrupoContato() async {
    TextEditingController _grupoContatoAddDescricao = new TextEditingController();
    GrupoContatoCadastro _grupoContatoSalvar = new GrupoContatoCadastro();
    final _formGrupoContatoKey = GlobalKey<FormState>();
    RequestUtil _request = new RequestUtil();
    _grupoContatoId = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text(_locale.locale['CadastroGrupoContato']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Form(
              key: _formGrupoContatoKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _grupoContatoAddDescricao,
                    decoration: InputDecoration(
                      labelText: "${_locale.locale['Descricao']}",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    validator: (input) {
                      if(input.isNotEmpty) {
                        return null;
                      }
                      else {
                        return _locale.locale['PreenchaCamposObrigatorios'];
                      }
                    },
                    onSaved: (input) {
                      _grupoContatoSalvar.descricao = input;
                    },
                  )
                ],
              )
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              if (_formGrupoContatoKey.currentState.validate()) {
                _formGrupoContatoKey.currentState.save();
                _grupoContatoSalvar.empresaId = await _request.obterIdEmpresaShared();

                String grupoContatoJson = json.encode(_grupoContatoSalvar.novoGrupoContatoJson());
                Response resposta = await ClienteService().grupoContato.adicionaGrupoContato(grupoContatoJson, context: context);
                if (resposta.statusCode == 200) {
                  Navigator.of(context).pop(int.parse(resposta.data['id']));
                }
              }
            },
            child: Text(_locale.locale['Salvar'])
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(_locale.locale['Cancelar'])
          ),
        ],
      )
    );
    if(_grupoContatoId != null) {
      _preencheGrupoContato(grupoContatoId: _grupoContatoId).then((data) {
        GrupoContatoLookUp resultadoGrupoContato = GrupoContatoLookUp.fromJson(data[0]);
        _grupoContatoSelecionado = resultadoGrupoContato;
        _grupoContatoId = _grupoContatoSelecionado.id;
        _grupoContatoShowUpController.text = _grupoContatoSelecionado.descricao;
      });
    }
  }

  Future _preencheCidadeEstrangeira({int cidadeEstrangeiraId}) async{
    return await ClienteService().cidadeEstrangeira.getCidadeEstrangeira(cidadeEstrangeiraId);
  }

  Future _preencheVendedor({int vendedorId}) async{
    return await ClienteService().vendedor.getVendedor(vendedorId);
  }

  Future _preencheTabelaPreco({int tabelaPrecoId}) async{
    return await ClienteService().tabelaPreco.getTabelaPreco(tabelaPrecoId);
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
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
              title: Text(
                widget.cliente == null
                  ? "${_locale.locale['CadastroCliente']}"
                  : "${_locale.locale['EditarCliente']}"
              ),
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context, true);
                      }
                    }
                  },
                  tooltip: _locale.locale['SalvarCliente'],
                ),
              ],
            ),
            body: CustomOfflineWidget(child: _cadastroClienteBody()),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _cadastroClienteBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Form(
        key: formKey,
        autovalidate: _autoValidacao,
        child: Column(
          children: <Widget>[
            _buildComboTiposClientes(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: <Widget>[
            //     Text("${_locale.locale['TipoCliente']}"),
            //     DropdownButton(
            //       value: _tipoClienteSelecionado,
            //       items: _dropDownTiposClientes,
            //       onChanged: alteraTipoSelecionado,
            //     )
            //   ],
            // ),
            
            SizedBox(height: 15,),
            (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 1)
                ? TextFormField(
                  controller: _cnpjMaskController,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: "${_locale.locale['CNPJ']}",
                    border: OutlineInputBorder(),
                    suffixIcon: Tooltip(
                      message: "${_locale.locale['ConsultaCNPJTooltip']}",
                      child: InkWell(
                        child: Icon(Icons.search),
                        // child: Column(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: <Widget>[
                        //     Padding(
                        //       padding: const EdgeInsets.symmetric(horizontal: 12),
                        //       child: Text(
                        //         "${_locale.locale['NaoSeiCEP']}",
                        //         style: TextStyle(
                        //           fontSize: 14
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        onTap: () async {
                          if(Validators().cnpjValidator(_cnpjMaskController.text)) {
                            await _consultaCNPJ(_cnpjMaskController.text);
                          }
                          else {
                            _showSnackBar(_locale.locale['CNPJInvalido']);
                          }
                          // _showSnackBar("${_locale.locale['BuscaEndereco']}");
                        },
                      )
                    ),
                  ),
                  maxLength: 18,
                  keyboardType: TextInputType.phone,
                  validator: (input) {
                    if (Validators().cnpjValidator(input)) {
                      return null;
                    } else {
                      return "${_locale.locale['CNPJInvalido']}";
                    }
                  },
                  onSaved: (input) {
                    String valor;
                    valor = input.replaceAll(".", "");
                    valor = valor.replaceAll("/", "");
                    valor = valor.replaceAll("-", "");
                    _documento = valor;
                  },
                )
                : (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 3)
                    ? TextFormField(
                      controller: _documentoEstrangeiroController,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: "${_locale.locale['Documento']}",
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 20,
                      keyboardType: TextInputType.phone,
                      onSaved: (input) {
                        String valor;
                        valor = input.replaceAll(".", "");
                        valor = valor.replaceAll("/", "");
                        valor = valor.replaceAll("-", "");
                        _documento = valor;
                      },
                    )
                    : TextFormField(
                      controller: _cpfMaskController,
                      decoration: InputDecoration(
                        counterText: '',
                        labelText: "${_locale.locale['CPF']}",
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 14,
                      keyboardType: TextInputType.phone,
                      validator: (input) {
                        if (Validators().cpfValidator(input)) {
                          return null;
                        } else {
                          return "${_locale.locale['CPFInvalido']}";
                        }
                      },
                      onSaved: (input) {
                        String valor;
                        valor = input.replaceAll(".", "");
                        valor = valor.replaceAll("/", "");
                        valor = valor.replaceAll("-", "");
                        _documento = valor;
                      },
                    ),

            SizedBox(height: 15,),
            (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 2)
            ? Column(
              children: <Widget>[
                TextFormField(
                  controller: _rgController,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: "${_locale.locale['RG']}",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                  keyboardType: TextInputType.phone,
                  onSaved: (input) => _rg = Validators().fieldFilledValidator(input, _rg),
                ),
                SizedBox(height: 15,),
              ],
            )
            : Container(),
            ((_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 1)
              || (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 2))
            ? Column(
              children: <Widget>[
                TextFormField(
                  controller: _inscricaoMunicipalController,
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: "${_locale.locale['InscricaoMunicipal']}",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 20,
                  keyboardType: TextInputType.phone,
                  onSaved: (input) => _inscricaoMunicipal = Validators().fieldFilledValidator(input, _inscricaoMunicipal),
                ),
                SizedBox(height: 15,),
              ],
            )
            : Container(),

            ((_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 1)
            || (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 4))
            ? Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Radio(
                      value: 0,
                      groupValue: radioGroupContribuicao,
                      onChanged: (T) {
                        setState(() {
                          radioGroupContribuicao = T;
                        });
                      },
                    ),
                    GestureDetector(
                      child: Text("${_locale.locale['Contribuinte']}"),
                      onTap: () {
                        setState(() {
                          radioGroupContribuicao = 0;
                          _inscricaoEstadualController.clear();
                          _enableContribuicao = true;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: radioGroupContribuicao,
                      onChanged: (T) {
                        setState(() {
                          radioGroupContribuicao = T;
                        });
                      },
                    ),
                    GestureDetector(
                      child: Text("${_locale.locale['NaoContribuinte']}"),
                      onTap: () {
                        setState(() {
                          radioGroupContribuicao = 1;
                          _inscricaoEstadualController.clear();
                          _inscricaoEstadualController.text = "NÃO CONTRIBUINTE";
                          _enableContribuicao = false;
                        });
                      },
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio(
                      value: 2,
                      groupValue: radioGroupContribuicao,
                      onChanged: (T) {
                        setState(() {
                          radioGroupContribuicao = T;
                        });
                      },
                    ),
                    GestureDetector(
                      child: Text("${_locale.locale['Isento']}"),
                      onTap: () {
                        setState(() {
                          radioGroupContribuicao = 2;
                          _inscricaoEstadualController.clear();
                          _inscricaoEstadualController.text = "ISENTO";
                          _enableContribuicao = false;
                        });
                      },
                    )
                  ],
                ),
              ],
            )
            :Container(),

            ((_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 1)
            || (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 4))
            ? TextFormField(
              controller: _inscricaoEstadualController,
              decoration: InputDecoration(
                counterText: '',
                labelText: "${_locale.locale['InscricaoEstadual']}",
                border: OutlineInputBorder(),
              ),
              enabled: _enableContribuicao,
              maxLength: 20,
              keyboardType: TextInputType.phone,
              onSaved: (input) => _inscricaoEstadual = Validators().fieldFilledValidator(input, _inscricaoEstadual),
            )
            : Container(),
            informacoesEssenciaisAccordion(),
            (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 3)
            ? enderecoPrincipalEstrangeiroAccordion()
            : enderecoPrincipalAccordion(),
            tilePaginas(texto: "${_locale.locale['OutrosEnderecos']}", funcao: _vaiParaOutrosEnderecos),
            tilePaginas(texto: "${_locale.locale['Contato']}", funcao: _vaiParaContatos),
            vendaAccordion(),
            tilePaginas(texto: "${_locale.locale['ParqueTecnologico']}", funcao: _vaiParaParqueTecnologico),
            tilePaginas(texto: "${_locale.locale['CheckList']}", funcao: _vaiParaCheckLists),
            tilePaginas(texto: "${_locale.locale['CobrancaPagamento']}", funcao: _vaiParaCobrancaPagamento),
            limiteCreditoAccordion(),
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
        ),
      ),
    );
  }

  _consultaCNPJ(String cnpj) async {
    dynamic requestCNPJ = await ClienteService().consultarCNPJ(cnpj: cnpj, context: context);
    ConsultaCNPJModelo resultadoConsulta = ConsultaCNPJModelo.fromJson(requestCNPJ);

    if (resultadoConsulta.enderecos.length > 1) {
      final resultadoSelecao = await _selecionaEnderecoCNPJ(resultadoConsulta.enderecos);

      if (resultadoSelecao != null && resultadoSelecao is int) {
        _preencheCNPJ(resultadoCNPJ: resultadoConsulta, index: resultadoSelecao);
      }
    }
    else {
      _preencheCNPJ(resultadoCNPJ: resultadoConsulta, index: 0);
    }
  }

  Future<int> _selecionaEnderecoCNPJ(List<Endereco> enderecos) async {
    int radioEndereco = 0;
    MediaQueryData _media = MediaQuery.of(context);
    double c_width = _media.size.width*0.5;
    double c_height = _media.size.height*0.6;

    return await AlertaComponente().showAlerta(
      context: context,
      titulo: _locale.locale[TraducaoStringsConstante.SelecioneEndereco],
      conteudo: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            height: c_height,
            width: c_width,
            // width: double.maxFinite,
            child: Scrollbar(
              child: ListView(
                children: <Widget>[
                  Text(_locale.locale[TraducaoStringsConstante.EscolhaEnderecoCNPJDescricao]),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      child: Container(
                        width: c_width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Radio(
                                  value: 0,
                                  groupValue: radioEndereco,
                                  onChanged: (T) {
                                    setState(() {
                                      radioEndereco = T;
                                    });
                                  },
                                ),
                                Flexible(
                                  child: Text(
                                    _locale.locale[TraducaoStringsConstante.EnderecoCorreio],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 4,),

                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.Cidade] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: enderecos[0].cidade ?? ''),
                                ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.Estado] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: enderecos[0].uf ?? ''),
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
                                  TextSpan(text: enderecos[0].bairro ?? ''),
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
                                  TextSpan(text: enderecos[0].endereco ?? ''),
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
                                  TextSpan(text: enderecos[0].numero ?? ''),
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
                                  TextSpan(text: enderecos[0].complemento ?? ''),
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          radioEndereco = 0;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GestureDetector(
                      child: Container(
                        width: c_width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: radioEndereco,
                                  onChanged: (T) {
                                    setState(() {
                                      radioEndereco = T;
                                    });
                                  },
                                ),
                                Flexible(
                                  child: Text(
                                    _locale.locale[TraducaoStringsConstante.EnderecoReceita],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 4,),

                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.Cidade] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: enderecos[1].cidade ?? ''),
                                ]
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan> [
                                  TextSpan(
                                    text: _locale.locale[TraducaoStringsConstante.Estado] + ': ' , style: TextStyle(fontWeight: FontWeight.bold)
                                  ),
                                  TextSpan(text: enderecos[1].uf ?? ''),
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
                                  TextSpan(text: enderecos[1].bairro ?? ''),
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
                                  TextSpan(text: enderecos[1].endereco ?? ''),
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
                                  TextSpan(text: enderecos[1].numero ?? ''),
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
                                  TextSpan(text: enderecos[1].complemento ?? ''),
                                ]
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          radioEndereco = 1;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
      // mensagem: mensagem,
      barrierDismissible: true,
      acoes: [
        FlatButton(
          child: Text(_locale.locale[TraducaoStringsConstante.Confirmar]),
          onPressed: () {
            Navigator.pop(context, radioEndereco);
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
  }

  _preencheCNPJ({@required ConsultaCNPJModelo resultadoCNPJ, int index = 0}) {
    _razaoSocialController.text = resultadoCNPJ.entidade.nome;
    _nomeFantasiaController.text = resultadoCNPJ.entidade.fantasia;
    _emailController.text = resultadoCNPJ.entidade.email;

    _cepMaskController.text = resultadoCNPJ.enderecos[index].cep.replaceAll('.', '').replaceAll('-', '');
    // _buscaCEP(_cepMaskController.text.replaceAll('.', '').replaceAll('-', ''));
    _codigoIBGEController.text = resultadoCNPJ.enderecos[index].codigoIBGE;
    _cidadeController.text = resultadoCNPJ.enderecos[index].cidade;
    _estadoController.text = resultadoCNPJ.enderecos[index].uf;
    _bairroController.text = resultadoCNPJ.enderecos[index].bairro;
    _enderecoController.text = resultadoCNPJ.enderecos[index].endereco;
    _numeroController.text = resultadoCNPJ.enderecos[index].numero;
    _complementoController.text = resultadoCNPJ.enderecos[index].complemento;

    dynamic telefone = Helper().separadorDDDTelefone(input: resultadoCNPJ.entidade.telefone);
    _ddiTelefone1Controller.text = '55';
    _dddTelefone1Controller.text = telefone['ddd'];
    _telefone1MaskController.text = telefone['telefone'];
  }

  List<DropdownMenuItem<SelectComboBox>> getDropDownItensSelecao(List lista) {
    List<DropdownMenuItem<SelectComboBox>> items = new List();
    for (SelectComboBox item in lista) {
      items.add(DropdownMenuItem(value: item, child: Text(item.descricao)));
    }
    return items;
  }

  Accordion informacoesEssenciaisAccordion() {
    return Accordion(
      titulo: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("${_locale.locale['InformacoesEssenciais']}"),
          ],
        )
      ],
      // aberto: widget.cliente != null ? false : true,
      aberto: true,
      itens: <Widget>[
        SizedBox(height: 15,),
        TextFormField(
          controller: _razaoSocialController,
          focusNode: _focusRazaoSocial,
          decoration: InputDecoration(
            labelText: "${_locale.locale['NomeRazaoSocial']}",
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
                context, _focusRazaoSocial, _focusNomeFantasia);
          },
          textInputAction: TextInputAction.next,
          onSaved: (input) => _razaoSocial = Validators().fieldFilledValidator(input, _razaoSocial),
        ),
        SizedBox(height: 15,),

        // Nome Fantasia
        TextFormField(
          controller: _nomeFantasiaController,
          focusNode: _focusNomeFantasia,
          decoration: InputDecoration(
            labelText: "${_locale.locale['NomeFantasia']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (term) {
            _fieldFocusChange(
                context, _focusNomeFantasia, _focusCodigo);
          },
          onSaved: (input) => _nomeFantasia = Validators().fieldFilledValidator(input, _nomeFantasia),
        ),
        SizedBox(height: 15,),

        // Código
        TextFormField(
          controller: _codigoController,
          focusNode: _focusCodigo,
          decoration: InputDecoration(
            labelText: "${_locale.locale['Codigo']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.text,
          onSaved: (input) => _codigo = input,
        ),
        SizedBox(height: 15,),

        /*
        // _buildCombo(),
        */

        // _buildComboBox(),

        // _buildComboBoxFuture(),

        // Situação
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: <Widget>[
        //     Text(
        //       "${_locale.locale['Situacao']}",
        //       style: TextStyle(
        //         color: Colors.grey[600]
        //       ),
        //     ),
            
        //     DropdownButton(
        //       focusNode: _focusSituacao,
        //       value: _situacaoClienteSelecionado,
        //       items: _dropDownSituacaoCliente,
        //       onChanged: alteraSituacaoSelecionado,
        //     )
        //   ],
        // ),
        SizedBox(height: 15,),

        // Ramo de Atividade
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                readOnly: true,
                controller: _ramoAtividadeShowUpController,
                focusNode: _focusRamoAtividade,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['RamoAtividade']}",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RamoAtividadeModal())
                  );
                  if (resultado != null) {
                    _ramoAtividadeSelecionado = resultado;
                    _ramoAtividadeShowUpController.text = _ramoAtividadeSelecionado.descricao;
                  }
                },
                onSaved: (_) => _ramoAtividadeId = _ramoAtividadeSelecionado.id,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _adicionaRamoAtividade,
            )
          ],
        ),

        SizedBox(height: 15,),

        // Região
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                readOnly: true,
                controller: _regiaoShowUpController,
                focusNode: _focusRegiao,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Regiao']}",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegiaoModal())
                  );
                  if (resultado != null) {
                    _regiaoSelecionada = resultado;
                    _regiaoShowUpController.text = _regiaoSelecionada.descricao;
                  }
                },
                onSaved: (_) => _regiaoId = _regiaoSelecionada.id,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _adicionaRegiao,
            )
          ],
        ),
        SizedBox(height: 15,),

        // Grupo de Contato
        Row(
          children: <Widget>[
            Flexible(
              child: TextFormField(
                readOnly: true,
                controller: _grupoContatoShowUpController,
                focusNode: _focusGrupoContato,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['GrupoContato']}",
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GrupoContatoModal())
                  );
                  if (resultado != null) {
                    _grupoContatoSelecionado = resultado;
                    _grupoContatoShowUpController.text = _grupoContatoSelecionado.descricao;
                  }
                },
                onSaved: (_) => _grupoContatoId = _grupoContatoSelecionado.id,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _adicionaGrupoContato,
            )
          ],
        ),
        SizedBox(height: 15,),

        // E-mail
        TextFormField(
          controller: _emailController,
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
          onSaved: (input) => _email = input,
        ),
        SizedBox(height: 15,),

        // Telefone 1
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                focusNode: _focusDDITelefone1,
                readOnly: true,
                keyboardType: TextInputType.phone,
                controller: _ddiTelefone1Controller,
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
                    _ddiTelefone1Controller.text = result;
                  }
                  if (result != '55') {
                    _telefone1MaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
                  }
                  else {
                    _telefone1MaskController.updateMask(MascarasConstantes.PHONE_BR);
                  }
                },
                onSaved: (input) => _ddiTelefone1 = Validators().fieldFilledValidator(input, _ddiTelefone1),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 2,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _dddTelefone1Controller,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['DDD']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onSaved: (input) => _dddTelefone1 = Validators().fieldFilledValidator(input, _dddTelefone1),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 7,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _telefone1MaskController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Telefone1']}",
                  border: OutlineInputBorder(),
                ),
                onSaved: (input) {
                  String valor = input;
                  if(input.isNotEmpty) {
                    valor = input.replaceAll("-", "");
                  }
                  _numeroTelefone1 = Validators().fieldFilledValidator(valor, _numeroTelefone1);
                }
              ),
            )
          ],
        ),
        SizedBox(height: 15,),

        // Telefone 2
        Row(
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                readOnly: true,
                focusNode: _focusDDITelefone2,
                keyboardType: TextInputType.phone,
                controller: _ddiTelefone2Controller,
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
                    _ddiTelefone2Controller.text = result;
                  }
                  if (result != '55') {
                    _telefone2MaskController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
                  }
                  else {
                    _telefone2MaskController.updateMask(MascarasConstantes.PHONE_BR);
                  }
                },
                onSaved: (input) => _ddiTelefone2 = Validators().fieldFilledValidator(input, _ddiTelefone2),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 2,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _dddTelefone2Controller,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['DDD']}",
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 3,
                onSaved: (input) => _dddTelefone2 = Validators().fieldFilledValidator(input, _dddTelefone2),
              ),
            ),
            SizedBox(width: 15,),

            Flexible(
              flex: 7,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                controller: _telefone2MaskController,
                decoration: InputDecoration(
                  labelText: "${_locale.locale['Telefone2']}",
                  border: OutlineInputBorder(),
                ),
                onSaved: (input) {
                  String valor = input;
                  if(input.isNotEmpty) {
                    valor = input.replaceAll("-", "");
                  }
                  _numeroTelefone2 = Validators().fieldFilledValidator(valor, _numeroTelefone2);
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
                    _celularMaskController.updateMask(MascarasConstantes.MOBILE_PHONE_BR);
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
                onSaved: (input) => _dddCelular = Validators().fieldFilledValidator(input, _dddCelular),
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
      ]);
  }

  Accordion enderecoPrincipalAccordion() {
    return Accordion(
      titulo: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("${_locale.locale['EnderecoPrincipal']}"),
          ],
        )
      ],
      aberto: true,
      itens: <Widget>[
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
                  _preencheInfoCepDeEndereco();
                  // _showSnackBar("${_locale.locale['BuscaEndereco']}");
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
    ]);
  }

  Accordion enderecoPrincipalEstrangeiroAccordion() {
    return Accordion(
      titulo: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("${_locale.locale['EnderecoPrincipal']}"),
          ],
        )
      ],
      aberto: true,
      itens: <Widget>[
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
          onSaved: (_) => _cidadeEstrangeiraId = _cidadeEstrangeiraSelecionada.id,
        ),
        SizedBox(height: 15,),
    ]);
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

      _enderecoController.text =
        (_enderecoController.text.isEmpty && cepInfo.logradouro.isNotEmpty)
        ? cepInfo.logradouro
        : _enderecoController.text ?? '';

      // if(_enderecoController.text.isEmpty && cepInfo.logradouro.isNotEmpty) {
      //   _enderecoController.text = cepInfo.logradouro;
      // }
      // if(_bairroController.text.isEmpty && cepInfo.bairro.isNotEmpty) {
      //   _bairroController.text = cepInfo.bairro;
      // }
      // if(_complementoController.text.isEmpty && cepInfo.bairro.isNotEmpty) {
      //   _complementoController.text = cepInfo.bairro;
      // }

      _bairroController.text =
        (_bairroController.text.isEmpty && cepInfo.bairro.isNotEmpty)
        ? cepInfo.bairro
        : _bairroController.text ?? '';

      _complementoController.text =
        (_complementoController.text.isEmpty && cepInfo.complemento.isNotEmpty)
        ? cepInfo.complemento
        : _complementoController.text ?? '';
      
      // _bairroController.text = cepInfo.bairro ?? "";
      // _complementoController.text = cepInfo.complemento ?? "";
      _cidadeController.text = cepInfo.localidade ?? "";
      _estadoController.text = cepInfo.uf ?? "";
    });
  }

  _vaiParaOutrosEnderecos() async {
    bool estrangeiro = false;
    if (_tipoClienteSelecionado != null && _tipoClienteSelecionado.codigo == 3) {
      estrangeiro = true;
    }
    else {
      estrangeiro = false;
    }
    if(_submit() == true) {
      if(await _salvar() == true) {
        RotasClientes.vaParaOutrosEnderecos(context, parceiroId: _parceiroId, estrangeiro: estrangeiro);
      }
    }
  }

  _vaiParaContatos() async {
    if(_submit() == true) {
      if(await _salvar() == true) {
        RotasClientes.vaParaContatos(context, parceiroId: _parceiroId,);
      }
    };
  }

  _vaiParaParqueTecnologico() async {
    if(_submit() == true) {
      if(await _salvar() == true) {
        RotasClientes.vaParaParqueTecnologico(context, parceiroId: _parceiroId, empresaId: _empresaId);
      }
    }
  }

  _vaiParaCheckLists() async {
    if(_submit() == true) {
      if (await _salvar() == true) {
        RotasClientes.vaParaCheckLists(context, parceiroId: _parceiroId,);
      }
    }
  }

  _vaiParaCobrancaPagamento() async {
    if(_submit() == true) {
      if(await _salvar() == true) {
        RotasClientes.vaParaCobrancaoPagamento(context, parceiroId: _parceiroId,);
      }
    }
  }

  _vaiParaListaLimitesCredito() async {
    if(_submit() == true) {
      if(await _salvar() == true) {
        RotasClientes.vaParaListaLimitesCredito(context, parceiroId: _parceiroId,);
      }
    }
  }

  Accordion vendaAccordion() {
    return Accordion(
      titulo: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("${_locale.locale['Venda']}"),
          ],
        )
      ],
      aberto: false,
      itens: <Widget>[
        SizedBox(height: 15,),
        TextFormField(
          controller: _vendedorShowUpController,
          readOnly: true,
          focusNode: _focusVendedorResponsavel,
          decoration: InputDecoration(
            labelText: "${_locale.locale['VendedorResponsavel']}",
            border: OutlineInputBorder(),
          ),
          onTap: () async {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VendedorSelecaoComponente())
            );
            if (resultado != null) {
              _vendedorSelecionado = resultado;
              _vendedorShowUpController.text = _vendedorSelecionado.nome;
            }
          },
          onSaved: (_) => _vendedorId = _vendedorSelecionado.id,
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _tabelaPrecoShowUpController,
          readOnly: true,
          focusNode: _focusTabelaPreco,
          decoration: InputDecoration(
            labelText: "${_locale.locale['TabelaPreco']}",
            border: OutlineInputBorder(),
          ),
          onTap: () async {
            final resultado = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TabelaPrecoModal())
            );
            if (resultado != null) {
              _tabelaPrecoSelecionada = resultado;
              _tabelaPrecoShowUpController.text = _tabelaPrecoSelecionada.descricao;
            }
          },
          onSaved: (_) => _tabelaPrecoId = _tabelaPrecoSelecionada.id,
        ),
        SizedBox(height: 15,),
    ],);
  }

  Accordion limiteCreditoAccordion() {
    return Accordion(
      titulo: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("${_locale.locale['LimiteCredito']}"),
          ],
        )
      ],
      aberto: false,
      itens: <Widget>[
        Row(
          children: <Widget>[
            Radio(
              value: 1,
              groupValue: radioGroupLimiteCredito,
              onChanged: (T) {
                setState(() {
                  radioGroupLimiteCredito = T;
                });
              },
            ),
            GestureDetector(
              child: Text("${_locale.locale['PorTotal']}"),
              onTap: () {
                setState(() {
                  radioGroupLimiteCredito = 1;
                });
              },
            )
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: 2,
              groupValue: radioGroupLimiteCredito,
              onChanged: (T) {
                setState(() {
                  radioGroupLimiteCredito = T;
                });
              },
            ),
            GestureDetector(
              child: Text("${_locale.locale['PorFormaPagamento']}"),
              onTap: () {
                setState(() {
                  radioGroupLimiteCredito = 2;
                });
              },
            )
          ],
        ),
        Row(
          children: <Widget>[
            Radio(
              value: 0,
              groupValue: radioGroupLimiteCredito,
              onChanged: (T) {
                setState(() {
                  radioGroupLimiteCredito = T;
                });
              },
            ),
            GestureDetector(
              child: Text("${_locale.locale['NaoControlar']}"),
              onTap: () {
                setState(() {
                  radioGroupLimiteCredito = 0;
                });
              },
            )
          ],
        ),
        SizedBox(height: 15,),

        TextFormField(
          controller: _limiteCreditoController,
          decoration: InputDecoration(
            labelText: "${_locale.locale['ValorLimiteTotal']}",
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onSaved: (_) {
            _limiteCredito = _limiteCreditoController.numberValue;
          },
          enabled: (radioGroupLimiteCredito == 1),
        ),
        SizedBox(height: 15,),

        radioGroupLimiteCredito == 1
        ?Column(
          children: <Widget>[
            TextFormField(
              controller: _limiteConsumidoController,
              decoration: InputDecoration(
                labelText: "${_locale.locale['LimiteConsumido']}",
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            SizedBox(height: 15,),
          ],
        ): Container(),
        radioGroupLimiteCredito == 1
        ?Column(
          children: <Widget>[
            TextFormField(
              controller: _limiteRestanteController,
              decoration: InputDecoration(
                labelText: "${_locale.locale['LimiteRestante']}",
                border: OutlineInputBorder(),
              ),
              enabled: false,
            ),
            SizedBox(height: 15,),
          ],
        ): Container(),
        radioGroupLimiteCredito == 2
        ? RaisedButton(
          child: Text("${_locale.locale['CarregarListaLimites']}".toUpperCase()),
          onPressed: _vaiParaListaLimitesCredito,
        )
        :Container()
    ],);
  }

  void alteraTipoSelecionado(SelectComboBox tipoSelecionado) {
    setState(() {
      _tipoClienteSelecionado = tipoSelecionado;
    });
  }

  void alteraSituacaoSelecionado(SelectComboBox situacaoSelecionado) {
    // if (situacaoSelecionado.codigo != 0 && _dropDownSituacaoCliente.length > 3) {
    //   _dropDownSituacaoCliente.removeRange(0, 1);
    // }
    setState(() {
      _situacaoClienteSelecionado = situacaoSelecionado;
    });
  }

  _fieldFocusChange(BuildContext context, FocusNode currentFocus,FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);  
  }

  _fieldUnfocus(BuildContext context, FocusNode fieldUnfocus) {
    fieldUnfocus.unfocus();
  }

  tilePaginas({@required String texto, @required Function funcao}) {
    return InkWell(
      onTap: funcao,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              texto,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: 24,
              width: 24,
              child: Icon(
                Icons.chevron_right,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _getEmpresaId() async {
    int empresa;
    empresa = await requestUtil.obterIdEmpresaShared();
    _empresaId = empresa;
  }

  bool _submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if(widget.cliente != null || _parceiroId != null) {
        clienteEditar.id = _parceiroId;
      }
      clienteEditar.empresaId = _empresaId;
      clienteEditar.pessoa = _tipoClienteSelecionado.codigo;
      
      clienteEditar.cnpJCPF = _documento;
      clienteEditar.rg = _rg;
      clienteEditar.im = _inscricaoMunicipal;
      clienteEditar.ie = _inscricaoEstadual;

      clienteEditar.nome = _razaoSocialController.text;
      clienteEditar.nomeFantasia = _nomeFantasiaController.text;
      clienteEditar.codigo = _codigoController.text;
      
      /*
      // clienteEditar.situacaoParceiro = _situacaoClienteSelecionado.codigo;
      */

      clienteEditar.ramoAtividadeId = _ramoAtividadeId;
      clienteEditar.regiaoId = _regiaoId;
      clienteEditar.grupoContatoId = _grupoContatoId;

      clienteEditar.contatoPrincipal.email = _emailController.text;

      clienteEditar.contatoPrincipal.telefone.ddi = _ddiTelefone1Controller.text;
      clienteEditar.contatoPrincipal.telefone.ddd = _dddTelefone1Controller.text;
      clienteEditar.contatoPrincipal.telefone.phone = _telefone1MaskController.text.replaceAll("-", "");

      clienteEditar.contatoPrincipal.telefone2.ddi = _ddiTelefone2Controller.text;
      clienteEditar.contatoPrincipal.telefone2.ddd = _dddTelefone2Controller.text;
      clienteEditar.contatoPrincipal.telefone2.phone = _telefone2MaskController.text.replaceAll("-", "");

      clienteEditar.contatoPrincipal.celular.ddi = _ddiCelularController.text;
      clienteEditar.contatoPrincipal.celular.ddd = _dddCelularController.text;
      clienteEditar.contatoPrincipal.celular.phone = _celularMaskController.text.replaceAll("-", "");

      clienteEditar.enderecoPrincipal.cep = _cepMaskController.text.replaceAll("-", "");
      clienteEditar.enderecoPrincipal.codigoIBGE = _codigoIBGEController.text;
      clienteEditar.enderecoPrincipal.endereco = _enderecoController.text;
      clienteEditar.enderecoPrincipal.numero = _numeroController.text;
      clienteEditar.enderecoPrincipal.bairro = _bairroController.text;
      clienteEditar.enderecoPrincipal.complemento = _complementoController.text;
      clienteEditar.enderecoPrincipal.cidade = _cidadeController.text;
      clienteEditar.enderecoPrincipal.uf = _estadoController.text;
      clienteEditar.enderecoPrincipal.cidadeEstrangeiroId = _cidadeEstrangeiraId ?? null;

      clienteEditar.vendedorId = _vendedorId;
      clienteEditar.tabelaPrecoId = _tabelaPrecoId;

      clienteEditar.tipoLimite = radioGroupLimiteCredito;
      clienteEditar.totalLimite = _limiteCredito;
      clienteEditar.tabelaPrecoId = _tabelaPrecoId;

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
    if (clienteEditar.id == null || _parceiroId == null) {
      String clienteJson = json.encode(clienteEditar.novoClienteJson());
      Response request = await ClienteService().adicionarCliente(clienteJson, context: context);
      if (request.statusCode == 200) {
        resultado = true;
        _parceiroId = int.parse(request.data['id']);
      }
      else resultado = false;
      return resultado;
    } else {
      String clienteJson = json.encode(clienteEditar.toJson());
      Response request = await ClienteService().editarCliente(clienteJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
