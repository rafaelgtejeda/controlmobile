import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/contas-selecao/contas-selecao.tela.dart';
import 'package:erp/compartilhados/componentes/tabs/tabs.componente.dart';
import 'package:erp/menu/bloquear-aplicativo.tela.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/telas/lista-empresas/lista-empresas.tela.dart';
import 'package:erp/telas/principal/principal.tela.dart';
import 'package:erp/telas/termos/termos.tela.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Rotas {
  // static void vaParaPrincipal(BuildContext context) {
  //   Navigator.pushNamed(context, "/principal");
  // }

  static void vaParaPrincipal(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => PrincipalTela()));
  }

  static void vaParaEmpresaPrincipal(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/principal");
  }

  // static void vaParaEmpresas(BuildContext context) {
  //   Navigator.pushReplacementNamed(context, "/empresas");
  // }

  static void vaParaEmpresas(BuildContext context, {List<Empresa> empresas}) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ListaEmpresasTela(empresas: empresas)));
  }

  static void vaParaTermos(BuildContext context, {List<Empresa> empresas}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TermosTela(empresas: empresas)));
  }

  static void vaParaFinanceiro(BuildContext context) {
    Navigator.pushNamed(context, "/financeiro");
  }

  static void vaParaTabs(BuildContext context, args) async {
    DateTime agora = DateTime.now().toUtc();
    DateTime dataInicial = DateTime(agora.year, agora.month, 1);
    DateTime dataFinal =
        DateTime(agora.year, agora.month + 1, 0, 23, 59, 59, 999, 999);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SharedPreference.DATA_INICIAL, dataInicial.toString());
    prefs.setString(SharedPreference.DATA_FINAL, dataFinal.toString());

    Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => TabsComponente(
                  args: args,
                )));
  }

  static Future<bool> vaParaConfigurarBloqueio(BuildContext context,
      {bool removerBloqueio, bool desbloquearApp}) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BloquearAplicativoTela(
                  removerBloqueio: removerBloqueio,
                  desbloquearApp: desbloquearApp,
                )));
  }

  static Future<bool> vaParaSelecaoContas(BuildContext context,
      {int args}) async {
    return await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (BuildContext context) => ContasSelecao(
                  args: args,
                )));
  }
}
