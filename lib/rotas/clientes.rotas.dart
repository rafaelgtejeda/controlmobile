import 'package:erp/compartilhados/componentes/cliente-selecao/cliente-prospect-cadastro.componente.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/select-busca/select-busca-modal.componente.dart';
import 'package:erp/models/cliente/checklist/checklist-editar.modelo.dart';
import 'package:erp/models/cliente/cliente-editar.modelo.dart';
import 'package:erp/models/cliente/cobranca-pagamento/cartao-editar.modelo.dart';
import 'package:erp/models/cliente/contato/contato-editar.modelo.dart';
import 'package:erp/models/cliente/limite-credito/limite-credito-editar.modelo.dart';
import 'package:erp/models/cliente/outros-enderecos/endereco-editar.modelo.dart';
import 'package:erp/models/cliente/parque-tecnologico/parque-tecnologico-editar.modelo.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/checklist/checklists-cadastro.modal.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/checklist/checklists-lista.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/cobranca-pagamento/cartao-cadastro-link.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/cobranca-pagamento/cartao-cadastro-whatsapp.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/cobranca-pagamento/cartao-cadastro.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/cobranca-pagamento/cartoes-lista.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/contato/contato-cadastro.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/contato/contato-lista.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/limite-credito/limite-credito-cadastro.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/limite-credito/limite-credito-lista.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/outros-enderecos/endereco-cadastro.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/outros-enderecos/outros-enderecos.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/parque-tecnologico/parque-tecnologico-cadastro.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente-telas/parque-tecnologico/parque-tecnologico-lista.tela.dart';
import 'package:erp/telas/clientes/cadastro-cliente.tela.dart';

class RotasClientes {

  // Cliente
  // static Future<bool> vaParaCadastroCliente(BuildContext context, {ClienteEditar cliente, bool clienteRapido}) async {
  static Future<bool> vaParaCadastroCliente(BuildContext context, {Cliente cliente, bool clienteRapido}) async {
    return await Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => CadastroClienteTela(cliente: cliente,))
      MaterialPageRoute(builder: (context) => ClienteProspectCadastroComponente(cliente: cliente, clienteRapido: clienteRapido,))
    );
  }

  static vaParaSelecaoItemRetorno(BuildContext context, String titulo, Future endpoint, List<List<Map<String, String>>> elementos) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelectBuscaModal(titulo: titulo, servico: endpoint, elementos: elementos,))
    );
  }

  // Outros Endereços
  static vaParaOutrosEnderecos(BuildContext context, {int parceiroId, bool estrangeiro}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OutrosEnderecosTela(parceiroId: parceiroId, estrangeiro: estrangeiro,))
    );
  }

  static Future<bool> vaParaCadastroEndereco(
    BuildContext context,
    {EnderecoEditar endereco,
    int parceiroId,
    bool estrangeiro}
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroEnderecoTela(
        endereco: endereco,
        parceiroId: parceiroId,
        estrangeiro: estrangeiro
      ))
    );
  }

  // Contatos
  static vaParaContatos(BuildContext context, {int parceiroId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContatoListaTela(parceiroId: parceiroId,))
    );
  }

  static Future<bool> vaParaCadastroContato(
    BuildContext context,
    {ContatoEditar contato,
    int parceiroId}
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroContatoTela(
        contato: contato,
        parceiroId: parceiroId
      ))
    );
  }

  // Parque Tecnológico
  static vaParaParqueTecnologico(BuildContext context, {int parceiroId, int empresaId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ParqueTecnologicoListaTela(parceiroId: parceiroId, empresaId: empresaId,))
    );
  }

  static Future<bool> vaParaCadastroParqueTecnologico(
    BuildContext context,
    {
      int empresaId,
      int parceiroId,
      ParqueEditar parqueTecnologico,
    }
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroParqueTecnologicoTela(
        empresaId: empresaId,
        parceiroId: parceiroId,
        parqueTecnologico: parqueTecnologico,
      ))
    );
  }

  // CheckLists
  static vaParaCheckLists(BuildContext context, {int parceiroId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChecklistListaTela(parceiroId: parceiroId,))
    );
  }

  static Future<bool> vaParaCadastroCheckList(
    BuildContext context,
    {
      CheckListEditar checkList,
      int parceiroId
    }
  ) async {
    return await Navigator.push(
      context,
      // PageRouteBuilder(
      //   opaque: false,
      //   pageBuilder: (BuildContext context, _, __) => CheckListsCadastroModal(
      //     checkList: checkList,
      //     parceiroId: parceiroId,
      //   )
      // ),
      MaterialPageRoute(
        builder: (context) => CheckListsCadastroModal(checkList: checkList, parceiroId: parceiroId,),
      ),
    );
  }

  // Cobrança e Pagamento
  static vaParaCobrancaoPagamento(BuildContext context, {int parceiroId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartoesListaTela(parceiroId: parceiroId,))
    );
  }

  static Future<bool> vaParaCadastroCartao(
    BuildContext context,
    {
      CartaoCreditoEditar cartao,
      int parceiroId
    }
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartaoCadastroTela(cartao: cartao, parceiroId: parceiroId,),
      ),
    );
  }

  static void vaParaCadastroCartaoLink(BuildContext context,{String link}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroCartaoLinkTela(link: link),),
    );
  }

  static void vaParaCadastroCartaoWhatsApp(BuildContext context,{String link}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroCartaoWhatsAppTela(link: link),),
    );
  }

  // Limite de Crédito
  static vaParaListaLimitesCredito(BuildContext context, {int parceiroId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LimiteCreditoListaTela(parceiroId: parceiroId,))
    );
  }

  static Future<bool> vaParaCadastroLimiteCredito(
    BuildContext context,
    {
      LimiteCreditoEditarGet limite,
      int parceiroId
    }
  ) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroLimiteCreditoTela(limiteCredito: limite, parceiroId: parceiroId,),
      ),
    );
  }
}
