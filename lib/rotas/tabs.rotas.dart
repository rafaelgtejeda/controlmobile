import 'package:flutter/material.dart';

class TabsRotas {

  static void vaParaTabsServico(BuildContext context) {
    Navigator.pushNamed(context, "/servicos");
  }

  static void vaParaTabsClientes(BuildContext context) {    
    Navigator.pushNamed(context, "/clientes");
  }

  static void vaParaTabsVendas(BuildContext context) {
    Navigator.pushNamed(context, "/vendas");
  }

  static void vaParaTabsFinanceiro(BuildContext context) {
    Navigator.pushNamed(context, "/financeiro");
  }
}
