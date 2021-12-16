import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class TotalTabBar extends StatefulWidget {
  final Function(double) retornaFrete;
  final double totalProdutos;
  final double frete;
  final double descontoValor;
  final int numeroParcelas;
  TotalTabBar({
    Key key,
    this.retornaFrete,
    this.totalProdutos,
    this.frete,
    this.descontoValor,
    this.numeroParcelas
  }) : super(key: key);
  @override
  TotalTabBarState createState() => TotalTabBarState();
}

class TotalTabBarState extends State<TotalTabBar> {
  LocalizacaoServico _locate = new LocalizacaoServico();

  int _numeroDeParcelas = 0;
  double _valorParcelas = 0;
  double descontoMoeda = 0;
  double frete = 0;

  var _descontoMoedaController = new MoneyMaskedTextController();
  var _freteController = new MoneyMaskedTextController();

  Timer _debounce;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    frete = widget.frete;
    descontoMoeda = widget.descontoValor;
    _numeroDeParcelas = widget.numeroParcelas;
    _freteController.updateValue(frete);
    _descontoMoedaController.updateValue(descontoMoeda);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return _tabBarTotal();
        }
      ),
    );
  }

  Widget _tabBarTotal() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _linhaInformacao(
              _locate.locale[TraducaoStringsConstante.TotalDeProdutos],
              Helper().dinheiroFormatter(widget.totalProdutos)
            ),
          ),

          Divisor(),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _linhaInformacao(
              _locate.locale[TraducaoStringsConstante.TotalDeParcelas],
              _numeroDeParcelas.toString()
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: _linhaInformacao(
          //     _locate.locale[TraducaoStringsConstante.VALOR_DAS_PARCELAS],
          //     Helper().dinheiroFormatter(_valorParcelas)
          //   ),
          // ),

          Divisor(),

          _descontoMoedaTextField(),

          _freteTextField(),
        ],
      ),
    );
  }

  Widget _descontoMoedaTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _descontoMoedaController,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true
        ),
        decoration: InputDecoration(
          labelText: _locate.locale[TraducaoStringsConstante.DescontoMoeda],
          prefixText: _locate.locale[TraducaoStringsConstante.MoedaLocal] + ' '
        ),
        enabled: false,
      ),
    );
  }

  Widget _freteTextField() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _freteController,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true
        ),
        decoration: InputDecoration(
          labelText: _locate.locale[TraducaoStringsConstante.Frete],
          prefixText: _locate.locale[TraducaoStringsConstante.MoedaLocal] + ' '
        ),
        onChanged: (input) {
          widget.retornaFrete(_freteController.numberValue);
        },
      ),
    );
  }

  Widget _linhaInformacao(String chave, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Texto(chave),
        Texto(valor, bold: true),
      ],
    );
  }
}
