import 'package:erp/compartilhados/componentes/produtos-modal/lista-produtos-modal.componente.dart';
import 'package:erp/compartilhados/componentes/servicos-modal/lista-servicos-modal.componente.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/telas/ordem-servico/andamento-mapa-ordem-servico/andamento-mapa-ordem-servico.tela.dart';
import 'package:erp/telas/ordem-servico/andamento-ordem-servico/andamento-ordem-servico.tela.dart';
import 'package:erp/telas/ordem-servico/checklist/checklist.tela.dart';
import 'package:erp/telas/ordem-servico/finalizar/finalizarOS.tela.dart';
import 'package:erp/telas/ordem-servico/materiais-servicos/cadastro-materiais.tela.dart';
import 'package:erp/telas/ordem-servico/materiais-servicos/materiais-servicos.tela.dart';
import 'package:erp/telas/ordem-servico/materiais-servicos/seleciona-materiais.tela.dart';
import 'package:erp/telas/ordem-servico/proximosChamados/grid-proximos-chamados.tela.dart';
import 'package:erp/telas/ordem-servico/reagendar/reagendar.tela.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:flutter/material.dart';

class OrdemServicoRotas {

  static Future<bool> vaParaGridOSProximosChamados(BuildContext context, {DateTime gridOSProximosChamadosData}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GridProximosChamadosTela(gridOSProximosChamadosData: gridOSProximosChamadosData))
    );
  }
  
  static void vaParaOrdemServicoListagem(BuildContext context) {
    Navigator.pushNamed(context, "/ordem-servico");
  }

  static void vaParaOrdemServicoDetalhes(BuildContext context) {
    Navigator.pushNamed(context, "/ordem-servico/detalhes");
  }

  static Future<bool> vaParaOrdemServicoReagendar(BuildContext context, GridOSAgendadaModelo gridOS) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReagendarTela(gridOS: gridOS ))
    );

  }

  static Future<bool> vaParaAndamentoOrdemServico(BuildContext context, int idOS, {bool exibeAssistenteNavegacao}) async {

    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AndamentoOrdemServico(idOS: idOS, exibeAssistenteNavegacao: exibeAssistenteNavegacao,))
    );

  }

  static void vaParaAndamentoMapaOrdemServico(BuildContext context, double latitude, double longitude, String endereco) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AndamentoMapaOrdemServicoTela(
          latitude: latitude, 
          longitude: longitude, 
          endereco: endereco
        )
      )
    );

  }

  static void vaParaMateriaisServicos(BuildContext context, {int osId, int empresaIdOS}) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MateriaisServicosTela(osId: osId, empresaIdOS: empresaIdOS,))
    );

  }

  static void vaParaCadastroMateriaisServicos(BuildContext context, int osId) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroMateriaisServicosTela(osId: osId))
    );

  }

  // static void vaParaSelecionMateriaisServicos(BuildContext context) {

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => SelecionaMateriaisServicosTela())
  //   );

  // }

  static Future<bool> vaParaSelecionMateriaisServicos(BuildContext context, {
    int osId, MaterialServicoSave materialServico, int empresaIdOS
  }) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SelecionaMateriaisServicosTela(
        osId: osId, materialServico: materialServico, empresaIdOS: empresaIdOS,
      ))
    );
  }

  static void vaParaSelecionarLookout(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListaProdutosModalComponente())
    );

  }

  static void vaParaSelecionarServicos(BuildContext context) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListaServicosModalComponente())
    );

  }

  static void vaParaChecklistsOS(BuildContext context, int osId, {int osXTecId}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChecklistOSTela(osId: osId, osXTecId: osXTecId))
    );
  }

  static void vaParaFinalizacaoOS({BuildContext context, int osId, int status, int osXTecId, OSConfig osConfig}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinalizarOSTela(
        osId: osId, status: status, osXTecId: osXTecId, osConfig: osConfig
      ))
    );
  }

}
