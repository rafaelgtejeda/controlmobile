import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/models/venda/detalhes-venda.modelo.dart';
import 'package:erp/telas/vendas/comparativo-venda.tela.dart';
import 'package:erp/telas/vendas/pedido-venda-detalhes.tela.dart';
import 'package:erp/telas/vendas/pedido-venda.tela.dart';
import 'package:erp/telas/orcamento/orcamento-lista.tela.dart';

class RotasVendas {
  static vaParaPedidoVenda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PedidoVendaTela())
    );
  }

  static vaParaPedidoVendaDetalhes(BuildContext context, {@required DetalhesVendaModelo detalhesVenda, int numeroVenda}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PedidoVendaDetalhesTela(detalhesVenda: detalhesVenda, numeroVenda: numeroVenda,))
    );
  }

  static vaParaComparativoVenda(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ComparativoVendaTela())
    );
  }

  static vaParaOrcamentos(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrcamentoListaTela())
    );
  }
}
