import 'dart:convert';
import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/assinatura/assinatura.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/orcamento/assinar-orcamento.modelo.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/orcamento/orcamento.servicos.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens.tab.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/request.util.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';

class OrcamentoDetalhesTela extends StatefulWidget {
  final OrcamentoModeloGet orcamento;
  // final ClienteLookup cliente;
  // final VendedoresLookUp vendedor;
  final int numeroOrcamento;

  OrcamentoDetalhesTela({
    Key key,
    this.orcamento,
    // this.cliente,
    // this.vendedor,
    this.numeroOrcamento
  }) : super(key: key);

  @override
  _OrcamentoDetalhesTelaState createState() => _OrcamentoDetalhesTelaState();
}

class _OrcamentoDetalhesTelaState extends State<OrcamentoDetalhesTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  RequestUtil _requestUtil = new RequestUtil();
  int _empresaId;
  double _totalProdutos = 0;
  double _totalPagamentos = 0;
  double _totalDescontosValor = 0;
  double _totalDescontosPorcentagem = 0;

  File _pdfArquivoTemporario = new File('');
  File _pdfArquivoFixo = new File('');

  File _assinatura = new File('');
  AssinarOrcamentoModelo _arquivoAssinatura = new AssinarOrcamentoModelo();
  bool _habilitaAssinatura = false;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    if (widget.orcamento.status == ListagemOrcamentoConstanteString.PENDENTE) _habilitaAssinatura = true;
    _getEmpresaId();
    _calculaTotalPagamentos();
    _calculaTotalProdutos();
    _calculaTotalDescontos();
  }

  @override
  void dispose() { 
    _deletarArquivosTemporarios();
    super.dispose();
  }

  _deletarArquivosTemporarios() async {
    final Directory tempDirDeletar = await getTemporaryDirectory();
    tempDirDeletar.deleteSync(recursive: true);
  }

  _calculaTotalPagamentos() {
    double total = 0;
    widget.orcamento.vencimentos.forEach((data) {
      total += data.valor;
    });
    setState(() {
      _totalPagamentos = total;
    });
  }

  _calculaTotalProdutos() {
    double total = 0;
    widget.orcamento.itens.forEach((data) {
      if(data.tipo != TiposItensTabBarConstante.RECEITAS) {
        total += data.prUnitario * data.quantidade;
      }
    });
    setState(() {
      _totalProdutos = total;
    });
  }

  _calculaTotalDescontos() {
    double total = 0;
    widget.orcamento.itens.forEach((data) {
      total += data.vlrDesc * data.quantidade;
    });
    setState(() {
      _totalDescontosValor = total;
      _totalDescontosPorcentagem = (total * 100) / _totalProdutos;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, true);
        return new Future(() => true);
      },
      child: LocalizacaoWidget(
        child: StreamBuilder(
          builder: (context, snapshot) {
            return Scaffold(
              appBar: AppBar(
                title: Text(_locate.locale[TraducaoStringsConstante.OrcamentoDetalhes]),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () => _compartilhaPDF(),
                  ),
                  IconButton(
                    icon: Icon(Icons.print),
                    onPressed: () => _armazenaPDFTemporario()
                  ),
                ],
              ),
              body: _detalhesOrcamento(),
              bottomNavigationBar: _habilitaAssinatura
                ? _isOnline
                  ? _botaoAssinatura()
                  : Container(
                    height: 80,
                    child: ListView(
                      children: <Widget>[
                        _botaoAssinatura(),
                        OfflineMessageWidget()
                      ],
                    ),
                  )
                : null,
            );
          }
        ),
      ),
    );
  }

  Widget _botaoAssinatura() {
    return RaisedButton(
      child: Texto(
        _locate.locale[TraducaoStringsConstante.AssinarOrcamento].toUpperCase(),
        bold: true,
        color: Colors.white
      ),
      color: Theme.of(context).primaryColor,
      onPressed: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssinaturaComponente(
            idObjetoAssinatura: widget.orcamento.id, numero: 01,
          ))
        );

        if (resultado != null) {
          _assinatura = resultado;
          bool confirmacao = await AlertaComponente().showAlertaConfirmacao(
            context: context,
            mensagem: _locate.locale[TraducaoStringsConstante.AdicionarAssinaturaConfirmacao]
          );
          if (confirmacao == true) {
            _converteArquivo();
            String arquivoJson = json.encode(_arquivoAssinatura.toJson());
            if(!await _requestUtil.verificaOnline()) {
              bool retorno = await OrcamentoService().assinarOrcamento(arquivoJson, context: context);
              if(retorno == true) {
                setState(() {
                  _habilitaAssinatura = false;
                });
              }
            }
            else {
              Response retorno = await OrcamentoService().assinarOrcamento(arquivoJson, context: context);
              if(retorno.statusCode == 200) {
                setState(() {
                  _habilitaAssinatura = false;
                });
              }

            }
          }
        }
      }
    );
  }

  AssinarOrcamentoModelo _converteArquivo() {
    final encoded = base64.encode(_assinatura.readAsBytesSync());
    _arquivoAssinatura.arquivo = encoded;
    _arquivoAssinatura.fileName = 'assinatura_1_orcamento${widget.orcamento.id}.png';
    _arquivoAssinatura.contentType = 'image/png';
    _arquivoAssinatura.size = ((encoded.replaceAll('=', '').length / 4) * 3);
    _arquivoAssinatura.orcamentoId = widget.orcamento.id;
    _arquivoAssinatura.empresaId = _empresaId;
    return _arquivoAssinatura;
  }

  Future<void> _getEmpresaId() async {
    int empresa;
    empresa = await _requestUtil.obterIdEmpresaShared();
    _empresaId = empresa;
  }



  _armazenaPDFTemporario() async {
    dynamic requestPdf = await OrcamentoService().obterOrcamentoPDF(orcamentoId: widget.orcamento.id, context: context);
    var _pdf = base64Decode(requestPdf.replaceAll('\n', ''));
    final Directory saida = await getTemporaryDirectory();
    _pdfArquivoTemporario = File("${saida.path}/Orcamento_${widget.numeroOrcamento}.pdf");
    await _pdfArquivoTemporario.writeAsBytes(_pdf.buffer.asUint8List());
    await OpenFile.open("${saida.path}/Orcamento_${widget.numeroOrcamento}.pdf");
    setState(() {});
  }

  _compartilhaPDF() async {
    dynamic requestPdf = await OrcamentoService().obterOrcamentoPDF(orcamentoId: widget.orcamento.id, context: context);
    var _pdf = base64Decode(requestPdf.replaceAll('\n', ''));
    final Directory saida = await getApplicationDocumentsDirectory();
    _pdfArquivoFixo = File("${saida.path}/Orcamento_${widget.numeroOrcamento}.pdf");
    await _pdfArquivoFixo.writeAsBytes(_pdf.buffer.asUint8List());
    await OpenFile.open("${saida.path}/Orcamento_${widget.numeroOrcamento}.pdf");
    ShareExtend.share(_pdfArquivoFixo.path, "file");
    setState(() {});
  }

  Widget _detalhesOrcamento() {
    // Solução temporária até a resolução do RichText
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _clienteDataDetalhe(context),
              _dividerPersonalizadoBuilder(),
              _detalhesContainerBuilder(
                context,
                children: [
                  _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Observacao], valor: widget.orcamento.observacao),
                ]
              ),
              _dividerPersonalizadoBuilder(),
              _vendedoresDetalhe(context),
              _dividerPersonalizadoBuilder(),
              _produtosDetalhe(context),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Texto('* ' + _locate.locale[TraducaoStringsConstante.ItemComComodato]),
                    Texto('** ' + _locate.locale[TraducaoStringsConstante.ItemTipoReceita])
                  ],
                ),
              ),
              _dividerPersonalizadoBuilder(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.TotalProdutos] + ':'),
                    Texto(Helper().dinheiroFormatter(_totalProdutos), bold: true, color: Colors.green),
                  ],
                ),
              ),
              _dividerPersonalizadoBuilder(),
              _pagamentosDetalhe(context),
              _dividerPersonalizadoBuilder(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.TotalPagamentos] + ':'),
                    Texto(Helper().dinheiroFormatter(_totalPagamentos), bold: true, color: Colors.green),
                  ],
                ),
              ),
              _dividerPersonalizadoBuilder(),
              _descontosDetalhe(context),
              _dividerPersonalizadoBuilder(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.TotalComDesconto] + ':'),
                    Texto(Helper().dinheiroFormatter(widget.orcamento.subTotal), bold: true, color: Colors.green),
                  ],
                ),
              ),
              _dividerPersonalizadoBuilder(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.Total] + ':'),
                    Texto(Helper().dinheiroFormatter(widget.orcamento.total), bold: true, color: Colors.green),
                  ],
                ),
              ),
              _dividerPersonalizadoBuilder(),
            ],
          );
        },
        itemCount: 1,
      ),
    );
    // return ListView(
    //   children: <Widget>[
    //     _myDetalhesText(context, propriedade: _locate.locale[TraducaoStringsConstante.DATA], valor: widget.orcamento.dataLancamento + widget.orcamento.dataConcluido),
    //     _myDetalhesText(context, propriedade: _locate.locale[TraducaoStringsConstante.CLIENTE], valor: widget.orcamento.cliente),
    //     _myDivider(),
    //   ],
    // );
  }

  Widget _clienteDataDetalhe(BuildContext context) {
    DateTime dataInicial = DateTime.parse(widget.orcamento.dataLancamento);
    String dataInicialFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(dataInicial);
    DateTime dataFinal = DateTime.parse(widget.orcamento.dataValidade);
    String dataFinalFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(dataFinal);
    return _detalhesContainerBuilder(
      context,
      children: [
        _detalhesLinhaBuilder(
          context,
          propriedade: _locate.locale[TraducaoStringsConstante.Data],
          valor: dataInicialFormatada + (dataFinal.isAfter(dataInicial) ? (' - ' + dataFinalFormatada) : '')
        ),
        _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Cliente], valor: widget.orcamento.contato),
      ]
    );
  }

  Widget _vendedoresDetalhe(BuildContext context) {
    return _detalhesContainerBuilder(
      context,
      children: [
        _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Vendedores]),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.maxFinite,
            height: (widget.orcamento.vendedores.length * 20).toDouble(),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Texto(
                    widget.orcamento.vendedores[index].nome,
                  ),
                );
              },
              itemCount: widget.orcamento.vendedores.length,
            ),
          ),
        )
      ]
    );
  }

  Widget _produtosDetalhe(BuildContext context) {
    return _detalhesContainerBuilder(
      context,
      children: [
        _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Produtos]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Texto(
                _locate.locale[TraducaoStringsConstante.Nome],
                bold: true
              ),
              Texto(
                _locate.locale[TraducaoStringsConstante.Total],
                bold: true
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.maxFinite,
            height: (widget.orcamento.itens.length * 40).toDouble(),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: Texto(
                          widget.orcamento.itens[index].produto + ' x ${widget.orcamento.itens[index].quantidade.toInt()}',
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Texto(
                          Helper().dinheiroFormatter(widget.orcamento.itens[index].prUnitario) + (widget.orcamento.itens[index].tipo == TiposItensTabBarConstante.RECEITAS ? '**' : widget.orcamento.itens[index].comodato == true ? '*' : ''),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: widget.orcamento.itens.length,
            ),
          ),
        )
      ]
    );
  }

  Widget _pagamentosDetalhe(BuildContext context) {
    return _detalhesContainerBuilder(
      context,
      children: [
        _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Pagamentos]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Texto(
                _locate.locale[TraducaoStringsConstante.DataVencimento],
                bold: true
              ),
              Texto(
                _locate.locale[TraducaoStringsConstante.Valor],
                bold: true
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: double.maxFinite,
            height: (widget.orcamento.vencimentos.length * 20).toDouble(),
            child: ListView.builder(
              itemBuilder: (context, index) {
                DateTime data = DateTime.parse(widget.orcamento.vencimentos[index].vencimento);
                String dataFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(data);
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Texto(
                        dataFormatada,
                      ),
                      Texto(
                        Helper().dinheiroFormatter(widget.orcamento.vencimentos[index].valor),
                      ),
                    ],
                  ),
                );
              },
              itemCount: widget.orcamento.vencimentos.length,
            ),
          ),
        )
      ]
    );
  }

  Widget _descontosDetalhe(BuildContext context) {
    return _detalhesContainerBuilder(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Texto(
                _locate.locale[TraducaoStringsConstante.DescontoPorcentagem],
                bold: true
              ),
              Texto(
                _locate.locale[TraducaoStringsConstante.DescontoMoeda],
                bold: true
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Texto(
                _totalDescontosPorcentagem.toStringAsFixed(2) + ' %',
              ),
              Texto(
                Helper().dinheiroFormatter(_totalDescontosValor),
              ),
            ],
          ),
        ),
      ]
    );
  }

  Divider _dividerPersonalizadoBuilder() {
    return Divider(
      height: 0,
      thickness: 2,
    );
  }

  Padding _detalhesContainerBuilder(BuildContext context, {List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Padding _detalhesLinhaBuilder(BuildContext context, {String propriedade = '', String valor = ''}) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan> [
            TextSpan(
              text: "$propriedade: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            TextSpan(
              text: valor,
              style: TextStyle(
                fontSize: 16
              ),
            )
          ]
        )
      ),
    );
  }
}
