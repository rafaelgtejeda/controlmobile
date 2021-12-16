import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/telas/ordem-servico/andamento-ordem-servico/andamento-ordem-servico.tela.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:erp/telas/termos/termos.tela.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:erp/splash_screen/splash_screen.dart';
import 'package:erp/telas/clientes/clientes.tela.dart';
import 'package:erp/telas/financeiro/finaceiro.tela.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/telas/autenticacao/autenticacao.tela.dart';
import 'package:erp/telas/lista-empresas/lista-empresas.tela.dart';
import 'package:erp/telas/ordem-servico/reagendar/reagendar.tela.dart';
import 'package:erp/compartilhados/componentes/tabs/tabs.componente.dart';
import 'package:erp/telas/ordem-servico/listagem/ordem-servico-listagem.tela.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/telas/clientes/cadastro-cliente.tela.dart';
import 'package:erp/telas/lista-paises/lista-paises.tela.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/tema.constante.dart';
import 'package:erp/telas/principal/principal.tela.dart';
import 'package:erp/telas/vendas/vendas.tela.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/telas/login/login.tela.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';



bool usuarioStatus = false;
bool bloqueioStatus = false;

void main() async {
  //final bool isInitialized = await MyDbModel().initializeDB();
  runApp(FullControlMobile());
}

// void main() => runApp(
//   DevicePreview(    
//     enabled: !kReleaseMode,
//     builder: (context) => FullControlMobile(),
//   ),
// );


var routes = <String, WidgetBuilder>{
  "/autenticacao": (BuildContext context) => AutenticacaoTela(),
  "/lista-paises": (BuildContext context) => ListaPaisesTela(),
  "/financeiro": (BuildContext context) => FinanceiroTela(),
  "/principal": (BuildContext context) => PrincipalTela(),
  "/tabs": (BuildContext context) => TabsComponente(),
  "/vendas": (BuildContext context) => VendasTela(),
  "/login": (BuildContext context) => LoginTela(),
  "/termos": (BuildContext context) => TermosTela(),
  "/clientes": (BuildContext context) => ClientesTela(),
  "/empresas": (BuildContext context) => ListaEmpresasTela(),
  "clientes/cadastro": (BuildContext context) => CadastroClienteTela(),
  "/ordem-servico/reagendar": (BuildContext context) => ReagendarTela(),
  "/ordem-servico": (BuildContext context) => OrdemServicoListagemTela(),
};

// Config.TemaFullControlEscuro = 1;
// Config.TemaFullControlClaro = 0;
// Config.TemaAtmosEscuro = 3;
// Config.TemaFullControl = 0;
// Config.TemaAtmosClaro = 2;
// Config.TemaAtmos = 1;

int tema = 0;

String app = '', titulo = '', logo = '';

carregaTema() {
  // app = Config.Atmos;
  switch (tema) {
    case 0:
      {
        app = Config.Fullcontrol;
        titulo = carregaTitulo();
        setConfig(tema, app);
        return TemaFullControl;
      }
      break;
    case 1:
      {
        app = Config.Fullcontrol;
        titulo = carregaTitulo();
        setConfig(tema, app);
        return TemaEscuro;
      }
      break;
    case 2:
      {
        app = Config.Atmos;
        titulo = carregaTitulo();
        setConfig(tema, app);
        return TemaAtmos;
      }
      break;
    case 3:
      {
        app = Config.Atmos;
        titulo = carregaTitulo();
        setConfig(tema, app);
        return TemaEscuro;
      }
      break;
  }
}

carregaTitulo() {
  switch (app) {
    case 'Fullcontrol':
      {
        return Config.Fullcontrol;
      }
      break;
    case 'Atmos':
      {
        return Config.Atmos;
      }
      break;
  }
}

setConfig(tema, app) async {

  SharedPreferences prefs = await SharedPreferences.getInstance();

  int fullcontrolClaro = Config.TemaFullControlClaro;
  int fullcontrolEscuro = Config.TemaFullControlEscuro;
  int atmosEscuro = Config.TemaAtmosEscuro;
  String fullcontrolTitulo = Config.Fullcontrol;
  String atmosTitulo = Config.Atmos;

  if (tema == fullcontrolClaro || tema == fullcontrolEscuro) {
    if (tema == fullcontrolEscuro && app == fullcontrolTitulo) {
      prefs.setString(
          SharedPreference.LOGOSPLASH, AssetsImagens.LOGO_ATMOS_DARK_SPLASH);
      prefs.setString(
          SharedPreference.LOGO, AssetsImagens.LOGO_FULLCONTROL_DARK);
      prefs.setString(SharedPreference.TEMA, Config.TemaEscuro);
      prefs.setString(SharedPreference.APP, Config.Fullcontrol);
    } else {
      prefs.setString(SharedPreference.TEMA, Config.TemaClaro);
      prefs.setString(SharedPreference.APP, Config.Fullcontrol);
      prefs.setString(
          SharedPreference.LOGO, AssetsImagens.LOGO_FULLCONTROL_LIGHT);
      prefs.setString(SharedPreference.LOGOSPLASH,
          AssetsImagens.LOGO_FULLCONTROL_LIGHT_SPLASH);
    }
  } else {
    if (tema == atmosEscuro && app == atmosTitulo) {
      prefs.setString(SharedPreference.LOGO, AssetsImagens.LOGO_ATMOS_DARK);
      prefs.setString(SharedPreference.TEMA, Config.TemaEscuro);
      prefs.setString(SharedPreference.APP, Config.Atmos);
    } else {
      prefs.setString(SharedPreference.LOGO, AssetsImagens.LOGO_ATMOS_LIGHT);
      prefs.setString(SharedPreference.TEMA, Config.TemaClaro);
      prefs.setString(SharedPreference.APP, Config.Atmos);
    }
  }
}

class FullControlMobile extends StatefulWidget {
  
  @override
  _FullControlMobileState createState() => _FullControlMobileState();
}

class _FullControlMobileState extends State<FullControlMobile> {

  @override
  void initState() { 

    super.initState();
    configOneSignal();
      
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
  @override
  Widget build(BuildContext context) {
           
    Intl.defaultLocale = 'pt';

    return ConnectivityAppWrapper(
      
      app: MaterialApp(
        debugShowCheckedModeBanner: false,
        // locale: DevicePreview.of(context).locale, 
        // builder: DevicePreview.appBuilder, 
        title: 'Fullcontrol',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('pt', 'PT'), // Português PT
          const Locale('en', 'EN'), // English EN
          const Locale('es', 'ES'), // Espanhol ES
        ],
        theme: carregaTema(),
        // darkTheme: carregaTemaEscuro(),
        home: SplashScreen(),
        routes: routes,
      ),
    );
  }

  void configOneSignal() async {
     // Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.init('ba330a39-80d6-47d2-85d3-181ccc402784', iOSSettings: {
      OSiOSSettings.autoPrompt: true,
      OSiOSSettings.inAppLaunchUrl: false
    });
    
    OneSignal.shared.setNotificationReceivedHandler((OSNotification notification) {
      // will be called whenever a notification is received

      var data = notification.payload.additionalData;
      print('data main: $data');
    
    });

    OneSignal.shared.setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      
      var additionalData = result.notification.payload.additionalData;
       // var detalheOS = OSnotificationOS.fromJson(additionalData);

      _verificaUsuarioAutenticado().then((resultado) {
        usuarioStatus = resultado;
      });

      _verificaAplictivoBloqueado().then((resultado) {
        bloqueioStatus = resultado;
      });

      Timer(Duration(seconds: 7), () async {

        List<String> listaContasEsvaziada = new List<String>();

        SharedPreferences _prefs = await SharedPreferences.getInstance();

        _prefs.setStringList(SharedPreference.CONTAS_SELECIONADAS, listaContasEsvaziada);
        
        if (usuarioStatus == true) {

          _prefs.setString(SharedPreference.TOKEN, '');

          if (bloqueioStatus == true) {

            final resultado = await Rotas.vaParaConfigurarBloqueio(context, desbloquearApp: true);

            if (resultado == true) {
              
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => AndamentoOrdemServico(idOS: additionalData['entidade']['IdOSXTec'], exibeAssistenteNavegacao: false,))
              );

            }
          } else {

            Navigator.push(
              context,  MaterialPageRoute(builder: (context) => 
                       AndamentoOrdemServico(idOS: additionalData['entidade']['IdOSXTec'], 
                                                   exibeAssistenteNavegacao: false,))
            );

          }
        } else {

          AutenticacaoRotas.vaParaAutenticacaoSplash(context);

        }
        
      });

    });

    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

    // The promptForPushNotgitificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    // await OneSignal.shared.promptUserForPushNotificationPermission(fallbackToSettings: true);

  }
}
