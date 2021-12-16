import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/telas/financeiro/financeiro-contas-pagar.tela.dart';
import 'package:erp/telas/financeiro/financeiro-contas-receber.tela.dart';
import 'package:erp/telas/financeiro/financeiro-despesas.tela.dart';
import 'package:erp/telas/financeiro/financeiro-dre.tela.dart';
import 'package:erp/telas/financeiro/financeiro-previsto-realizado.tela.dart';
import 'package:erp/telas/financeiro/fnanceiro-comparar.tela.dart';

class RotasFinanceiro {
  static vaParaDRE(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroDRETela())
    );
  }

  static vaParaPrevistoRealizado(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroPrevistoRealizadoTela())
    );
  }

  static vaParaContasPagar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroContasPagarTela())
    );
  }

  static vaParaContasReceber(BuildContext context, {String titulo, bool receita}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroContasReceberTela(titulo: titulo, receita: receita,))
    );
  }

  static vaParaComparativo(BuildContext context, {String titulo}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroCompararTela())
    );
  }

  static vaParaDespesas(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroDespesasTela())
    );
  }

  static vaParaDespesasDetalhes(BuildContext context, {int categoria, String titulo}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinanceiroContasPagarTela(categoria: categoria, titulo: titulo,))
    );
  }
}
