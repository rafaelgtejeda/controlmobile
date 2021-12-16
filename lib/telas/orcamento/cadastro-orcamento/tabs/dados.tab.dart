import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/cliente-selecao/cliente-selecao.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/vendedor-selecao/vendedor-selecao.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:intl/intl.dart';

class DadosTabBar extends StatefulWidget {
  final bool mostrarID;
  final Function(DateTime) recebeDataInicial;
  final Function(DateTime) recebeDataFinal;
  final Function(ClienteLookup) recebeClienteSelecionado;
  final Function(VendedoresLookUp) recebeVendedorSelecionado;
  final Function(String) recebeObservacao;
  final int numeroOrcamento;
  final DateTime dataInicial;
  final DateTime dataFinal;
  final ClienteLookup clienteSelecionado;
  final VendedoresLookUp vendedorSelecionado;
  final String observacao;
  DadosTabBar({
    Key key, this.mostrarID, this.recebeDataFinal, this.recebeDataInicial, this.recebeClienteSelecionado,
    this.recebeVendedorSelecionado, this.recebeObservacao, this.numeroOrcamento, this.dataInicial, this.dataFinal,
    this.clienteSelecionado, this.vendedorSelecionado, this.observacao
  }) : super(key: key);
  @override
  DadosTabBarState createState() => DadosTabBarState();
}

class DadosTabBarState extends State<DadosTabBar> {
  final formKey = GlobalKey<FormState>();
  bool _autoValidacao = false;
  LocalizacaoServico _locate = new LocalizacaoServico();

  DateTime _dataFinal = DateTime.now();
  DateTime _dataInicial = DateTime.now();

  TextEditingController clienteController = new TextEditingController();
  ClienteLookup _clienteSelecionado = new ClienteLookup();
  int _clienteId;

  TextEditingController vendedorController = new TextEditingController();
  VendedoresLookUp _vendedorSelecionado = new VendedoresLookUp();
  int _vendedorId;

  TextEditingController observacaoController = new TextEditingController();
  String _observacao;

  MediaQueryData _media = MediaQueryData();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _dataInicial = widget.dataInicial;
    _dataFinal = widget.dataFinal;
    _clienteSelecionado = widget.clienteSelecionado;
    clienteController.text = widget.clienteSelecionado.nome;
    _vendedorSelecionado = widget.vendedorSelecionado;
    vendedorController.text = widget.vendedorSelecionado.nome;
    observacaoController.text = widget.observacao;
  }

  @override
  Widget build(BuildContext context) {
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return _tabBarDados();
        }
      ),
    );
  }

  Widget _tabBarDados() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            // (widget.mostrarID != null && widget.mostrarID == true)
            //   ? Texto(_locate.locale[TraducaoStringsConstante.ORCAMENTO_NUMERO_DESCRICAO])
            //   : Container(),
            // (widget.mostrarID != null && widget.mostrarID == true)
            //   ? Texto(widget.numeroOrcamento.toString())
            //   : Container(),
            // (widget.mostrarID != null && widget.mostrarID == true)
            //   ? Divisor()
            //   : Container(),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _datasOrcamento(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _selecaoCliente(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _selecaoVendedor(),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _observacaoBox(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datasOrcamento() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Flexible(
          flex: 1,
          child: _dataOrcamentoComponente(
            texto: _locate.locale[TraducaoStringsConstante.DataOrcamento],
            data: DateFormat.yMd().format(DateTime.parse(_dataInicial.toString())),
            funcao: () {_selecionaDataInicial();}
          ),
        ),
        Flexible(
          flex: 1,
          child: _dataOrcamentoComponente(
            texto: _locate.locale[TraducaoStringsConstante.DataVencOrcamento],
            data: DateFormat.yMd().format(DateTime.parse(_dataFinal.toString())),
            funcao: () {selecionaDataFinal();}
          ),
        ),
      ],
    );
  }

  Widget _selecaoCliente() {
    return TextFormField(
      readOnly: true,
      controller: clienteController,
      decoration: InputDecoration(
        labelText: _locate.locale[TraducaoStringsConstante.SelecioneCliente],
        border: OutlineInputBorder(),
      ),
      validator: (input) {
        if (input.isEmpty) {
          return _locate.locale[TraducaoStringsConstante.SelecioneClienteValidacao];
        }
        else {
          return null;
        }
      },
      onTap: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClienteSelecaoComponente())
        );

        if (resultado != null) {
          if (resultado is int) {
            dynamic _request = await ClienteService().getClienteLookup(id: resultado);
            _clienteSelecionado = ClienteLookup.fromJson(_request[0]);
            clienteController.text = _clienteSelecionado.nome;
            widget.recebeClienteSelecionado(_clienteSelecionado);
          }
          else {
            _clienteSelecionado = resultado;
            clienteController.text = _clienteSelecionado.nome;
            widget.recebeClienteSelecionado(_clienteSelecionado);
          }
        }
      },
      onSaved: (_) => _clienteId = _clienteSelecionado.id,
    );
  }

  Widget _selecaoVendedor() {
    return TextFormField(
      readOnly: true,
      controller: vendedorController,
      decoration: InputDecoration(
        labelText: _locate.locale[TraducaoStringsConstante.SelecioneVendedor],
        border: OutlineInputBorder(),
      ),
      validator: (input) {
        if(input.isEmpty) {
          return _locate.locale[TraducaoStringsConstante.SelecioneVendedorValidacao];
        }
        else {
          return null;
        }
      },
      onTap: () async {
        final resultado = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VendedorSelecaoComponente())
        );

        if (resultado != null) {
          _vendedorSelecionado = resultado;
          vendedorController.text = _vendedorSelecionado.nome;
          widget.recebeVendedorSelecionado(_vendedorSelecionado);
        }
      },
      onSaved: (_) => _vendedorId = _vendedorSelecionado.id,
    );
  }

  Widget _observacaoBox() {
    return TextFormField(
      maxLines: 4,
      controller: observacaoController,
      decoration: InputDecoration(
        labelText: _locate.locale[TraducaoStringsConstante.Observacao],
        border: OutlineInputBorder(),
      ),
      onSaved: (input) => _observacao = observacaoController.text,
      onChanged: (input) {
        widget.recebeObservacao(input);
      },
    );
  }

  Future<Null>_selecionaDataInicial() async {
    final DateTime selecionadoInicial = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataInicial
    );

    if (selecionadoInicial != null && selecionadoInicial != _dataInicial) {
      setState(() {
        _dataInicial = selecionadoInicial;
      });
      widget.recebeDataInicial(selecionadoInicial);
    }
  }

  Future<Null>selecionaDataFinal() async {
    final DateTime selecionadoFinal = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataFinal
    );

    if (selecionadoFinal != null && selecionadoFinal != _dataFinal) {
      setState(() {
        _dataFinal = selecionadoFinal;
      });
      widget.recebeDataFinal(selecionadoFinal);
    }
  }

  Widget _dataOrcamentoComponente({String texto, String data, Function funcao}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: funcao,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10)
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(6),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12,),
                    Flexible(
                      flex: 1,
                      child: Texto(
                        texto,
                        fontSize: 14,
                        // fontSize: _media.size.width > 350 ? 14 : 9,
                        // fontSize: 14 * MediaQuery.of(context).textScaleFactor,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                child: Texto(
                  data,
                  bold: true,
                  underline: true,
                  fontSize: 16,
                  // fontSize: _media.size.width > 350 ? 16 : 10,
                  // fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  bool submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      return true;
    } else {
      setState(() {
        _autoValidacao = true;
      });
      return false;
    }
  }
}
