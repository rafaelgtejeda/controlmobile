import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
// import 'package:flutter_share/flutter_share.dart';
// import 'package:flutter_share_file/flutter_share_file.dart';
import 'package:erp/models/venda/detalhes-venda.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/venda/venda.servicos.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
// import 'package:share/share.dart';

class PedidoVendaDetalhesTela extends StatefulWidget {
  final DetalhesVendaModelo detalhesVenda;
  final int numeroVenda;
  PedidoVendaDetalhesTela({@required this.detalhesVenda, this.numeroVenda});
  @override
  _PedidoVendaDetalhesTelaState createState() => _PedidoVendaDetalhesTelaState();
}

class _PedidoVendaDetalhesTelaState extends State<PedidoVendaDetalhesTela> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  double _totalProdutos = 0;
  double _totalPagamentos = 0;
  double _totalDescontosValor = 0;
  double _totalDescontosPorcentagem = 0;

  File _pdfArquivoTemporario = new File('');
  File _pdfArquivoFixo = new File('');

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
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
    widget.detalhesVenda.vencimentos.forEach((data) {
      total += data.valor;
    });
    setState(() {
      _totalPagamentos = total;
    });
  }

  _calculaTotalProdutos() {
    double total = 0;
    widget.detalhesVenda.itens.forEach((data) {
      total += data.prUnitario * data.quantidade;
    });
    setState(() {
      _totalProdutos = total;
    });
  }

  _calculaTotalDescontos() {
    double total = 0;
    widget.detalhesVenda.itens.forEach((data) {
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
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.PedidoVendaDetalhes]),
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
            body: _detalhesPedidoVenda(),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }



  _armazenaPDFTemporario() async {
    dynamic requestPdf = await VendaService().obterVendaPDF(vendaId: widget.detalhesVenda.id, context: context);
    var _pdf = base64Decode(requestPdf.replaceAll('\n', ''));
    final Directory saida = await getTemporaryDirectory();
    _pdfArquivoTemporario = File("${saida.path}/Venda_${widget.numeroVenda}.pdf");
    await _pdfArquivoTemporario.writeAsBytes(_pdf.buffer.asUint8List());
    await OpenFile.open("${saida.path}/Venda_${widget.numeroVenda}.pdf");
    setState(() {});
  }

  _compartilhaPDF() async {
    dynamic requestPdf = await VendaService().obterVendaPDF(vendaId: widget.detalhesVenda.id, context: context);
    var _pdf = base64Decode(requestPdf.replaceAll('\n', ''));
    final Directory saida = await getApplicationDocumentsDirectory();
    _pdfArquivoFixo = File("${saida.path}/Venda_${widget.numeroVenda}.pdf");
    await _pdfArquivoFixo.writeAsBytes(_pdf.buffer.asUint8List());
    await OpenFile.open("${saida.path}/Venda_${widget.numeroVenda}.pdf");
    ShareExtend.share(_pdfArquivoFixo.path, "file");
    setState(() {});
  }

  Widget _detalhesPedidoVenda() {
    // Solução temporária até a resolução do RichText
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _clienteDataDetalhe(context),
              Divisor(),
              _detalhesContainerBuilder(
                context,
                children: [
                  _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Observacao], valor: widget.detalhesVenda.observacao),
                ]
              ),
              Divisor(),
              _vendedoresDetalhe(context),
              Divisor(),
              _produtosDetalhe(context),
              Divisor(),
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
              Divisor(),
              _pagamentosDetalhe(context),
              Divisor(),
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
              Divisor(),
              _descontosDetalhe(context),
              Divisor(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.TotalComDesconto] + ':'),
                    Texto(Helper().dinheiroFormatter(widget.detalhesVenda.subtotal), bold: true, color: Colors.green),
                  ],
                ),
              ),
              Divisor(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Texto(_locate.locale[TraducaoStringsConstante.Total] + ':'),
                    Texto(Helper().dinheiroFormatter(widget.detalhesVenda.total), bold: true, color: Colors.green),
                  ],
                ),
              ),
              Divisor(),
            ],
          );
        },
        itemCount: 1,
      ),
    );
    // return ListView(
    //   children: <Widget>[
    //     _myDetalhesText(context, propriedade: _locate.locale[TraducaoStringsConstante.DATA], valor: widget.detalhesVenda.dataLancamento + widget.detalhesVenda.dataConcluido),
    //     _myDetalhesText(context, propriedade: _locate.locale[TraducaoStringsConstante.CLIENTE], valor: widget.detalhesVenda.cliente),
    //     _myDivider(),
    //   ],
    // );
  }

  Widget _clienteDataDetalhe(BuildContext context) {
    DateTime dataInicial = DateTime.parse(widget.detalhesVenda.dataLancamento);
    String dataInicialFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(dataInicial);
    DateTime dataFinal = DateTime.parse(widget.detalhesVenda.dataConcluido);
    String dataFinalFormatada = DateFormat.yMd(SharedPreference.IDIOMA).format(dataFinal);
    return _detalhesContainerBuilder(
      context,
      children: [
        _detalhesLinhaBuilder(
          context,
          propriedade: _locate.locale[TraducaoStringsConstante.Data],
          valor: dataInicialFormatada + (dataFinal.isAfter(dataInicial) ? (' - ' + dataFinalFormatada) : '')
        ),
        _detalhesLinhaBuilder(context, propriedade: _locate.locale[TraducaoStringsConstante.Cliente], valor: widget.detalhesVenda.cliente),
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
            height: (widget.detalhesVenda.vendedores.length * 20).toDouble(),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Texto(
                    widget.detalhesVenda.vendedores[index].nome,
                  ),
                );
              },
              itemCount: widget.detalhesVenda.vendedores.length,
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
            height: (widget.detalhesVenda.itens.length * 40).toDouble(),
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
                          widget.detalhesVenda.itens[index].produto + ' x ${widget.detalhesVenda.itens[index].quantidade.toInt()}',
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Texto(
                          Helper().dinheiroFormatter(widget.detalhesVenda.itens[index].prUnitario),
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemCount: widget.detalhesVenda.itens.length,
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
            height: ((widget.detalhesVenda.vencimentos.length + 1) * 20).toDouble(),
            child: ListView.builder(
              itemBuilder: (context, index) {
                DateTime data = DateTime.parse(widget.detalhesVenda.vencimentos[index].vencimento);
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
                        Helper().dinheiroFormatter(widget.detalhesVenda.vencimentos[index].valor),
                      ),
                    ],
                  ),
                );
              },
              itemCount: widget.detalhesVenda.vencimentos.length,
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
