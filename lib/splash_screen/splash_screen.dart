import 'dart:async';
import 'package:erp/offline/Agendador/agendador.dart';
import 'package:erp/offline/controlador/controlador.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/rotas/rotas.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String app = "";
  String logo = "";
  String tema = "";
  String titulo = "";

  bool usuarioStatus = false;
  bool bloqueioStatus = false;

  @override
  void initState() {
    getTema();

    super.initState();

    _initDB();

    _verificaUsuarioAutenticado().then((resultado) {
      usuarioStatus = resultado;
    });

    _verificaAplictivoBloqueado().then((resultado) {
      bloqueioStatus = resultado;
    });

    Controlador().adicionaControlador();
    AgendadorCron().adicionaAgendador();
    
    AgendadorCron().initCron();
    
    Timer(Duration(seconds: 7), () async {

      List<String> listaContasEsvaziada = new List<String>();
      SharedPreferences _prefs = await SharedPreferences.getInstance();

      _prefs.setStringList(SharedPreference.CONTAS_SELECIONADAS, listaContasEsvaziada);
      
      var empresaID = _prefs.get(SharedPreference.EMPRESA_ID);

      if (usuarioStatus == true) {

        _prefs.setString(SharedPreference.TOKEN, '');

        if (bloqueioStatus == true) {

          final resultado = await Rotas.vaParaConfigurarBloqueio(context, desbloquearApp: true);
          
          if (resultado == true) {

            Rotas.vaParaEmpresas(context);

          }

        } else {

          Rotas.vaParaEmpresas(context);

        }
      } else {

        AutenticacaoRotas.vaParaAutenticacaoSplash(context);

      }
    });

   
  }

  _initDB() async {
    final bool isInitialized = await OfflineDbModel().initializeDB();
  }

  Future<bool> _verificaUsuarioAutenticado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuario = prefs.getString(SharedPreference.USUARIO_AUTENTICADO);
    if (usuario == 'false' || usuario == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> _verificaAplictivoBloqueado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String bloqueio = prefs.getString(SharedPreference.BLOQUEAR_APLICATIVO);
    if (bloqueio == 'false' || bloqueio == null) {
      return false;
    } else {
      return true;
    }
  }

  getTema() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    tema = prefs.getString('tema');
    logo = prefs.getString(SharedPreference.LOGOSPLASH);
    app = prefs.getString('app');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: FadeInUp(3, _logo()),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: FadeInUp(4, _textoLogo()),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FadeInUp(1, _carregando()),
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: FadeInUp(5, _versao()),
            // )
          ],
        ),
      ),
    );
  }

  Widget _logo() {
    return Container(
      child:
          // --> Inicio logo
          Padding(
              padding: EdgeInsets.only(top: 51, left: 0, bottom: 41, right: 0),
              child: Image.asset('images/logo/logo.png', width: 201)),
      // --> Fim logo,
    );
  }

  Widget _textoLogo() {
    return Padding(
      padding: EdgeInsets.only(top: 0, left: 0, bottom: 0, right: 0),
      child: Text(
        'Fullcontrol'.toUpperCase(),
        style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.normal,
            fontFamily: 'Lato Black',
            fontSize: 31),
      ),
    );
  }

  Widget _carregando() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 81, left: 0, bottom: 50, right: 0),
        child: SpinKitCircle(
          color: Theme.of(context).primaryColorLight,
          size: 51.0,
        ),
      ),
    );
  }

  Widget _versao() {
    return Padding(
      padding: EdgeInsets.only(top: 40, left: 0, bottom: 0, right: 0),
      child: Text(
        Config.Versao,
        style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontFamily: 'Lato Thin',
            fontSize: 18),
      ),
    );
  }

  Future<Map<String, dynamic>> configOneSignal(BuildContext context) async {
    // Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    var additionalData;
    
    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      additionalData = result.notification.payload.additionalData;
    });

    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received
      var data = notification.payload.additionalData;
      print(' splash data: $data');
    
    });

    OneSignal.shared
             .setInFocusDisplayType(OSNotificationDisplayType.notification);

    print(additionalData);

    return additionalData;

  }
}
