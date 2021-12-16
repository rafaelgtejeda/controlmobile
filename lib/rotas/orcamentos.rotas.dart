import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/orcamento/informacao-parcela-get.modelo.dart';
import 'package:erp/models/orcamento/orcamento-get.modelo.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/cadastro-orcamento.tela.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/itens/cadastro-itens.modal.dart';
import 'package:erp/telas/orcamento/cadastro-orcamento/tabs/pagamento/cadastro-pagamento.modal.dart';
import 'package:erp/telas/orcamento/orcamento-detalhes.tela.dart';

class RotasOrcamentos {
  static Future<T> vaParaCadastroOrcamento<T extends Object>(BuildContext context, {OrcamentoModeloGet orcamento, int tipoOrcamento}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroOrcamentoTela(orcamento: orcamento, tipoOrcamento: tipoOrcamento,))
    );
  }

  static Future<bool> vaParaVisualizacaoDetalhesAssinaturaOrcamento(
    BuildContext context, {
      @required OrcamentoModeloGet orcamento,
      // ClienteLookup cliente,
      // VendedoresLookUp vendedor,
      int numeroOrcamento
    }
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrcamentoDetalhesTela(
        orcamento: orcamento,
        // cliente: cliente,
        // vendedor: vendedor,
        numeroOrcamento: numeroOrcamento
      ))
    );
  }
  
  static Future<Itens> vaParaCadastroItem(BuildContext context, {@required int tipo, Itens item, bool poussuiComodato, bool possuiLocacao}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroItensModal(
        tipo: tipo, item: item, possuiComodato: poussuiComodato, possuiLocacao: possuiLocacao,
      ))
    );
  }

  static Future<List<InformacaoParcelaRetorno>> vaParaCadastroPagamento(BuildContext context, {double valor, int parceiroId}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroPagamentoModal(valor: valor, parceiroId: parceiroId))
    );
  }
}
