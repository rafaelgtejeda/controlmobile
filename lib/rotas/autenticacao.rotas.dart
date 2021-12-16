import 'package:flutter/material.dart';
import 'package:erp/telas/login/login.tela.dart';

class AutenticacaoRotas {
  

  static void vaParaAutenticacaoSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/autenticacao");
  }

  static void vaParaAutenticacao(BuildContext context) {
    Navigator.pushNamed(context, "/autenticacao");
  } 
  
  // static void vaParaLogin(BuildContext context) {
  //   Navigator.pushNamed(context, "/login");
  // }
  
  static void vaParaLogin(BuildContext context, {String idioma}) {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginTela(idioma: idioma)));
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginTela()));
  }

  static void vaParaBloqueio(BuildContext context) {
    Navigator.pushNamed(context, "/bloqueio");
  }
  
  static void vaParaListaPaises(BuildContext context) {
    Navigator.pushNamed(context, "/lista-paises");
  }

}
