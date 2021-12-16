import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/orcamento/ocamento-save.modelo.dart' as orcamentoSave;
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/models/orcamento/orcamento-grid.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/orcamento/orcamento.servicos.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/dados.tab.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens-produtos.tab.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens.tab.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/pagamento.tab.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/total.tab.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/request.util.dart';
import 'package:provider/provider.dart';

class CadastroOrcamentoTela extends StatefulWidget {
  final OrcamentoModeloGet orcamento;
  final int tipoOrcamento;
  CadastroOrcamentoTela({Key key, this.orcamento, this.tipoOrcamento}) : super(key: key);
  @override
  _CadastroOrcamentoTelaState createState() => _CadastroOrcamentoTelaState();
}

class _CadastroOrcamentoTelaState extends State<CadastroOrcamentoTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  orcamentoSave.OrcamentoModeloSave _orcamentoSave = new orcamentoSave.OrcamentoModeloSave();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  double _total = 0;
  int _empresaId;
  RequestUtil _requestUtil = new RequestUtil();
  String _orcamentoJson;
  MediaQueryData _media = MediaQueryData();

  // Dados
  final GlobalKey<DadosTabBarState> _dadosTabBarStateKey = GlobalKey<DadosTabBarState>();
  DateTime _dataFinal = DateTime.now();
  DateTime _dataInicial = DateTime.now();

  ClienteLookup _clienteSelecionado = new ClienteLookup();
  int _clienteId;

  VendedoresLookUp _vendedorSelecionado = new VendedoresLookUp();
  int _vendedorId;

  String _observacao;

  // Itens
  final GlobalKey<ItensTabBarState> _itensTabBarStateKey = GlobalKey<ItensTabBarState>();
  final GlobalKey<ItensProdutosTabBarState> _itensProdutosTabBarStateKey = GlobalKey<ItensProdutosTabBarState>();
  List<Itens> _listaItens = new List<Itens>();

  // Total
  final GlobalKey<TotalTabBarState> _totalTabBarStateKey = GlobalKey<TotalTabBarState>();
  double _totalProdutos = 0;
  double _frete = 0;
  double _descontoValor = 0;

  // Pagamento
  final GlobalKey<PagamentoTabBarState> _pagamentoTabBarStateKey = GlobalKey<PagamentoTabBarState>();
  List<Vencimentos> _listaVencimentos = new List<Vencimentos>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    if (widget.orcamento != null) {
      _preencheOrcamento();
    }
    _obtemEmpresaId();
    _preencheRestante();
    _calculaTotal(_totalProdutos);
  }

  @override
  void dispose() {
    // _dadosTabBarStateKey.currentState.dispose();
    // _itensTabBarStateKey.currentState.dispose();
    super.dispose();
  }

  _preencheRestante() {
    orcamentoSave.OrcamentoXContrato orcamentoXContrato = new orcamentoSave.OrcamentoXContrato();
    orcamentoSave.OrcamentoXOS orcamentoXOS = new orcamentoSave.OrcamentoXOS();

    _orcamentoSave.orcamentoXContrato = orcamentoXContrato;
    _orcamentoSave.orcamentoXOS = orcamentoXOS;
  }

  _preencheOrcamento() async {
    _dataInicial = DateTime.parse(widget.orcamento.dataLancamento);
    _dataFinal = DateTime.parse(widget.orcamento.dataValidade);
    await _procuraCliente();
    await _procuraVendedor();
    _observacao = widget.orcamento.observacao;
    _dadosTabBarStateKey.currentState.observacaoController.text = _observacao;
    _listaItens = widget.orcamento.itens;
    // _descontoValor = widget.orcamento.vlrDesconto;
    _descontoValor = _somaDescontosValor(_listaItens);
    // _totalProdutos = widget.orcamento.total - widget.orcamento.vlrFrete + widget.orcamento.vlrDesconto;
    // _totalProdutos = widget.orcamento.total - widget.orcamento.vlrFrete + _descontoValor;
    // _totalProdutos = widget.orcamento.total;
    // _totalProdutos = widget.orcamento.total + _descontoValor;
    _totalProdutos = _obtemTotalProdutos(_listaItens);
    _frete = widget.orcamento.vlrFrete;
    // _descontoPorcentagem = widget.orcamento.desconto;
    _listaVencimentos = widget.orcamento.vencimentos;
    _calculo();
  }

  double _somaDescontosValor(List<Itens> itens) {
    double somaDescontoValor = 0;
    itens.forEach((element) {
      // somaDescontoValor += element.vlrDesc * element.quantidade;
      // somaDescontoValor += element.vlrDesc;
      somaDescontoValor += (element.prUnitario - element.prUnitComDesc) * element.quantidade;
    });
    return somaDescontoValor;
  }

  double _obtemTotalProdutos(List<Itens> itens) {
    double somaTotalProdutos = 0;
    itens.forEach((element) {
      if(element.tipo != TiposItensTabBarConstante.RECEITAS) {
        somaTotalProdutos += element.prUnitario * element.quantidade;
      }
    });
    return somaTotalProdutos;
  }

  // Dados

  _procuraCliente() async {
    dynamic _request = await ClienteService().getClienteLookup(id: widget.orcamento.contatoId);
    setState(() {
      _clienteSelecionado = ClienteLookup.fromJson(_request[0]);
    });
    _dadosTabBarStateKey.currentState.clienteController.text = _clienteSelecionado.nome;
  }

  _procuraVendedor() async {
    dynamic _request = await VendedoresService().getVendedor(widget.orcamento.vendedores[0].id);
    setState(() {
      _vendedorSelecionado = VendedoresLookUp.fromJson(_request[0]);
    });
    _dadosTabBarStateKey.currentState.vendedorController.text = _vendedorSelecionado.nome;
  }

  _recebeDataInicial(DateTime dataInicial) {
    setState(() {
      _dataInicial = dataInicial;
    });
  }

  _recebeDataFinal(DateTime dataFinal) {
    setState(() {
      _dataFinal = dataFinal;
    });
  }

  _recebeObservacao(String observacao) {
    setState(() {
      _observacao = observacao;
    });
  }

  _recebeClienteSelecionado(ClienteLookup clienteSelecionado) {
    setState(() {
      _clienteSelecionado = clienteSelecionado;
    });
  }

  _recebeVendedorSelecionado(VendedoresLookUp vendedorSelecionado) {
    setState(() {
      _vendedorSelecionado = vendedorSelecionado;
    });
  }

  // Itens

  _recebeItens(List<Itens> itens) {
    double total = 0;
    double desconto = 0;
    _listaItens = itens;
    if(_listaItens.length != 0) {
      _listaItens.forEach((element) {
        if (element.tipo != TiposItensTabBarConstante.RECEITAS && element.comodato == false) {
          total += element.vlrTotal;
          desconto += element.vlrDesc;
        }
        if(element.comodato &&element.tipo != TiposItensTabBarConstante.RECEITAS) {
          total += element.vlrTotal;
          desconto += element.vlrTotal;
        }
      });
      _total = 0;
      _totalProdutos = total;
      _descontoValor = desconto;
      _calculo();
    }
    else {
      _total = 0;
      _totalProdutos = 0;
      _descontoValor = 0;
      _calculo();
    }
  }

  // Total

  _calculaTotal(double totalProdutos) {
    _total = 0;
    _totalProdutos = totalProdutos;
    _calculo();
  }

  _calculaFrete(double frete) {
    _total = 0;
    _frete = frete;
    _calculo();
  }

  _calculo() {
    setState(() {
      _total = _totalProdutos + _frete - _descontoValor;
    });
  }

  // Pagamento

  _recebePagamentos(List<Vencimentos> pagamentos) {
    setState(() {
      _listaVencimentos = pagamentos;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return DefaultTabController(
            length: 4,
            child: Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: widget.orcamento == null 
                  ? Text(_locate.locale[TraducaoStringsConstante.CadastroOrcamento])
                  : Text(_locate.locale[TraducaoStringsConstante.EditarOrcamento]),
                actions: <Widget>[
                  SaveButtonComponente(
                    funcao: () async {
                      if (_submit() == true) {
                        if(await _salvar() == true) {
                          if(await _requestUtil.verificaOnline()) Navigator.pop(context, true);
                          else {
                            OrcamentoGrid _orcamentoOffline = new OrcamentoGrid();

                            _orcamentoOffline.data = _orcamentoSave.dtLancamento;
                            _orcamentoOffline.numero = _orcamentoSave.numero;
                            _orcamentoOffline.vendedor = _vendedorSelecionado.nome;
                            _orcamentoOffline.cliente = _clienteSelecionado.nomeFantasia;
                            _orcamentoOffline.valor = _orcamentoSave.subtotal;
                            _orcamentoOffline.status = _orcamentoSave.status;
                            _orcamentoOffline.offline = true;
                            _orcamentoOffline.offlineId = 1;

                            Navigator.pop(context, _orcamentoOffline);
                          }
                        }
                      }
                    },
                    tooltip: _locate.locale['SalvarOrcamento'],
                  )
                ],
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(36),
                  child: TabBar(
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                    isScrollable: true,
                    tabs: <Widget> [
                      Tab(text: _locate.locale[TraducaoStringsConstante.Dados],),
                      Tab(text: _locate.locale[TraducaoStringsConstante.Itens],),
                      Tab(text: _locate.locale[TraducaoStringsConstante.Total],),
                      Tab(text: _locate.locale[TraducaoStringsConstante.Pagamento],),
                    ]
                  ),
                ),
              ),
              // bottomNavigationBar: _painel(),
              bottomNavigationBar: _isOnline
                ? _painel()
                : Container(
                  height: (_media.size.height * 0.2) + 40,
                  child: ListView(
                    children: <Widget>[
                      _painel(),
                      OfflineMessageWidget()
                    ],
                  ),
                ),
              body: Container(
                child: TabBarView(
                  // physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    DadosTabBar(
                      key: _dadosTabBarStateKey,
                      mostrarID: widget.orcamento != null,
                      recebeDataInicial: _recebeDataInicial,
                      recebeDataFinal: _recebeDataFinal,
                      recebeClienteSelecionado: _recebeClienteSelecionado,
                      recebeVendedorSelecionado: _recebeVendedorSelecionado,
                      recebeObservacao: _recebeObservacao,
                      numeroOrcamento: widget.orcamento != null ? widget.orcamento.id : null,
                      dataInicial: _dataInicial,
                      dataFinal: _dataFinal,
                      clienteSelecionado: _clienteSelecionado,
                      vendedorSelecionado: _vendedorSelecionado,
                      observacao: _observacao,
                    ),
                    widget.tipoOrcamento == TiposOrcamentos.SERVICO
                    || (widget.orcamento != null && widget.orcamento.tipo == TiposOrcamentos.SERVICO)
                    ? ItensTabBar(
                      key: _itensTabBarStateKey,
                      itens: _listaItens,
                      recebeItens: _recebeItens,
                    )
                    : ItensProdutosTabBar(
                      key: _itensProdutosTabBarStateKey,
                      itens: _listaItens,
                      recebeItens: _recebeItens,
                    ),
                    TotalTabBar(
                      key: _totalTabBarStateKey,
                      retornaFrete: _calculaFrete,
                      totalProdutos: _totalProdutos,
                      frete: _frete,
                      descontoValor: _descontoValor,
                      numeroParcelas: _listaVencimentos.length,
                    ),
                    PagamentoTabBar(
                      key: _pagamentoTabBarStateKey,
                      vencimentos: _listaVencimentos,
                      recebeVencimentos: _recebePagamentos,
                      total: _total,
                      parceiroId: _clienteSelecionado.id,
                    ),
                  ]
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _painel() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 2
          )
        )
      ),
      // height: 120,
      height: _media.size.height * 0.2,
      // height: _media.size.height > 350 ? _media.size.height * 0.2 : _media.size.height * 0.15,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Texto(
                  _locate.locale[TraducaoStringsConstante.Total] + ':',
                  // fontSize: 18,
                  fontSize: _media.size.height > 350 ? 16 : 8,
                  bold: true
                ),
                Texto(
                  Helper().dinheiroFormatter(_total),
                  // fontSize: 18,
                  fontSize: _media.size.height > 350 ? 16 : 8,
                  bold: true
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                // height: 48,
                height: (_media.size.height * 0.2) * 0.35,
                child: SizedBox.expand(
                  child: FlatButton(
                    onPressed: () async {
                      if (_submit() == true) {
                        if(await _salvar() == true) {
                          if(await _requestUtil.verificaOnline()) Navigator.pop(context, true);
                          else {
                            OrcamentoGrid _orcamentoOffline = new OrcamentoGrid();
                            String orcamentoOffJson;

                            _orcamentoOffline.data = _orcamentoSave.dtLancamento;
                            _orcamentoOffline.numero = _orcamentoSave.numero;
                            _orcamentoOffline.vendedor = _vendedorSelecionado.nome;
                            _orcamentoOffline.cliente = _clienteSelecionado.nomeFantasia;
                            _orcamentoOffline.valor = _orcamentoSave.subtotal;
                            _orcamentoOffline.status = _orcamentoSave.status;
                            _orcamentoOffline.offline = true;
                            _orcamentoOffline.offlineId = await DBProvider.db.getOfflineId();

                            orcamentoOffJson = json.encode(_orcamentoOffline.toJsonOffline());

                            await DBProvider.db.salvarEmOfflineExibicao(Endpoints.ORCAMENTO_INCLUIR, orcamentoOffJson);

                            Navigator.pop(context, true);
                          }
                        }
                      }
                    },
                    color: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    child: Texto(
                      _locate.locale[TraducaoStringsConstante.SalvarOrcamento].toUpperCase(),
                      color: Colors.white,
                      bold: true,
                      // fontSize: 18
                      fontSize: _media.size.height > 350 ? 16 : 8,
                    )
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text), duration: Duration(seconds: 1),));
  }

  _obtemEmpresaId() async {
    int empresa;
    empresa = await _requestUtil.obterIdEmpresaShared();
    _empresaId = empresa;
  }

  bool _submit() {
    int tipoDesconto = 0;
    int statusOrcamento = 0;

    if(_dadosTabBarStateKey.currentState != null) {
      _dadosTabBarStateKey.currentState.submit();
    }

    if(_clienteSelecionado.id == null) {
      setState(() {
        _showSnackBar(_locate.locale[TraducaoStringsConstante.SelecioneClienteValidacao]);
      });
      return false;
    }
    else if(_vendedorSelecionado.id == null) {
      setState(() {
        _showSnackBar(_locate.locale[TraducaoStringsConstante.SelecioneVendedorValidacao]);
      });
      return false;
    }
    else {
      if (widget.orcamento != null) {
        _orcamentoSave.orcamentoId = widget.orcamento.id;
      }
      _orcamentoSave.contatoId = _clienteSelecionado.id;
      _orcamentoSave.empresaId = _empresaId;
      _orcamentoSave.gerarFinanceiro = false;
      _orcamentoSave.observacao = _observacao;

      _orcamentoSave.dtLancamento = _dataInicial.toString();
      _orcamentoSave.dtValidade = _dataFinal.toString();

      _orcamentoSave.total = _total;
      _orcamentoSave.vlrFrete = _frete;
      // _orcamentoSave.vlrDesconto = _descontoValor;
      _orcamentoSave.vlrDesconto = 0;
      if (widget.orcamento != null) {
        switch (widget.orcamento.tipoDesconto) {
          case 'Valor':
            tipoDesconto = 0;
            break;
          case 'Percentual':
            tipoDesconto = 1;
            break;
          default:
            tipoDesconto = 0;
            break;
        }
      }
      else {
        tipoDesconto = 0;
      }
      // _orcamentoSave.tipoDesconto = widget.orcamento != null ? widget.orcamento.tipoDesconto : 0;
      _orcamentoSave.tipoDesconto = tipoDesconto;
      // _orcamentoSave.desconto = _descontoValor;
      _orcamentoSave.desconto = 0;
      _orcamentoSave.subtotal = _totalProdutos;

      // _orcamentoSave.itens = _listaItens.cast();
      _orcamentoSave.itens = _converteItens();
      // _orcamentoSave.vencimentos = _listaVencimentos.cast();
      _orcamentoSave.vencimentos = _convertePagamentos();
      _orcamentoSave.vendedores = [_vendedorSelecionado.id];

      if (widget.orcamento != null) {
        _orcamentoSave.tipo = widget.orcamento.tipo;
      }
      else {
      // if (widget.orcamento == null) {
        _orcamentoSave.tipo = widget.tipoOrcamento;
      }

      // _orcamentoSave.tipo = 0;
      if (widget.orcamento != null) {
        switch (widget.orcamento.status) {
          case 'Pendente':
            statusOrcamento = 0;
            break;
          case 'Concluido':
            statusOrcamento = 1;
            break;
          case 'Rejeitado':
            statusOrcamento = 2;
            break;
          case 'Assinado':
            statusOrcamento = 3;
            break;
          // case 'Vinculado':
          //   statusOrcamento = 3;
          //   break;
          case 'Vinculado':
            statusOrcamento = 4;
            break;
          default:
            statusOrcamento = 0;
            break;
        }
      }
      // _orcamentoSave.status = widget.orcamento != null ? widget.orcamento.status : 0;
      _orcamentoSave.status = statusOrcamento;

      print(_orcamentoSave.toJson().toString());

      // int orcamentoId;
      // int numero;
      // int status;

      return true;
    }
  }

  List<orcamentoSave.Vencimentos> _convertePagamentos() {
    List<orcamentoSave.Vencimentos> novaListaPagamento = new List<orcamentoSave.Vencimentos>();
    
    _listaVencimentos.forEach((element) {
      orcamentoSave.Vencimentos novoPagamento = new orcamentoSave.Vencimentos();
      novoPagamento.condicaoId = element.condicaoPagamentoId;
      novoPagamento.formaPagamentoId = element.formaPagamentoId;
      novoPagamento.parcela = element.parcela;
      novoPagamento.valor = element.valor;
      novoPagamento.vencimento = element.vencimento;

      novaListaPagamento.add(novoPagamento);
    });

    return novaListaPagamento;
  }

  List<orcamentoSave.Itens> _converteItens() {
    List<orcamentoSave.Itens> novaListaItens = new List<orcamentoSave.Itens>();
    
    _listaItens.forEach((element) {
      orcamentoSave.Itens novoItem = new orcamentoSave.Itens();

      novoItem.comodato = element.comodato;
      novoItem.percDesc = element.percDesc;
      novoItem.prUnitComDesc = element.prUnitComDesc;
      novoItem.prUnitario = element.prUnitario;
      novoItem.produtoId = element.produtoId;
      novoItem.quantidade = element.quantidade;
      novoItem.tipo = element.tipo;
      novoItem.vlrDesc = element.vlrDesc;
      novoItem.vlrTotComDesc = element.vlrTotComDesc;
      novoItem.vlrTotal = element.vlrTotal;
      novoItem.locacaoBens = element.locacaoBens;

      novaListaItens.add(novoItem);
    });

    return novaListaItens;
  }

  Future<bool> _salvar() async {
    bool resultado;

    if (_orcamentoSave.orcamentoId == null) {
      _orcamentoJson = json.encode(_orcamentoSave.novoOrcamentoJson());
      if(!await _requestUtil.verificaOnline()) {
        bool request = await OrcamentoService().adicionarOrcamento(_orcamentoJson, context: context);
        resultado = request;
      }
      else {
        Response request = await OrcamentoService().adicionarOrcamento(_orcamentoJson, context: context);
        if (request.statusCode == 200) resultado = true;
        else resultado = false;
      }
      return resultado;
    }
    
    else {
      _orcamentoJson = json.encode(_orcamentoSave.toJson());
      if(!await _requestUtil.verificaOnline()) {
        bool request = await OrcamentoService().editarOrcamento(_orcamentoJson, context: context);
        resultado = request;
      }
      else {
        Response request = await OrcamentoService().editarOrcamento(_orcamentoJson, context: context);
        if (request.statusCode == 200) resultado = true;
        else resultado = false;
      }
      return resultado;
    }
  }
}
