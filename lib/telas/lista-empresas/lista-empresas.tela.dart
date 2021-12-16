import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/telas/ordem-servico/andamento-ordem-servico/andamento-ordem-servico.tela.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/diretivas-acesso/diretivas-acesso.modelo.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/servicos/empresa/empresa.servicos.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaEmpresasTela extends StatefulWidget {
  final List<Empresa> empresas;
  ListaEmpresasTela({Key key, this.empresas}) : super(key: key);
  @override
  _ListaEmpresasTelaState createState() => _ListaEmpresasTelaState();
  
}

class _ListaEmpresasTelaState extends State<ListaEmpresasTela> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  var subscription;
   
  Stream<dynamic> _streamEmpresas;
  LocalizacaoServico _locate = new LocalizacaoServico();

  List<Empresa> empresasList = new List<Empresa>();
  File _fotoPerfil = new File('');

  _ListaEmpresasTelaState() {}

  bool usuarioStatus = false;
  bool bloqueioStatus = false;

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamEmpresas = Stream.fromFuture(_fazRequest());
    // subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    // // Got a new connectivity status!
    // _connect();
    // });
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
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  _connect() async{
    var wifiBSSID = await (Connectivity().getWifiBSSID());
    var wifiIP = await (Connectivity().getWifiIP());
    var wifiName = await (Connectivity().getWifiName());

    print('wifiBSSID: $wifiBSSID');
    print('wifiIP $wifiIP');
    print('$wifiName');

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      print('mobile');
    } else if (connectivityResult == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      print('wifi');
      _streamEmpresas = Stream.fromFuture(_fazRequest());
    }
  }

  Future<void> _handleRefresh() {
    
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    _streamEmpresas = Stream.fromFuture(_fazRequest());
   
    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: const Text('Refresh complete'),
        action: SnackBarAction(
          label: 'RETRY',
          onPressed: () {
            _refreshIndicatorKey.currentState.show();
          }
        )
      ));
    });
  }

  Future<dynamic> _fazRequest() async {
    if(widget.empresas == null) {
      
      // dynamic requestEmpresa = await EmpresaService().listaEmpresas();
      // List<Empresa> listaEmpresa = new List<Empresa>();
      // requestEmpresa.forEach((data) {
      //   listaEmpresa.add(Empresa.fromJson(data));
      // });
      // if (listaEmpresa != empresasList) {
      //   setState(() {
      //     empresasList.clear();
      //   });
      //   empresasList.addAll(listaEmpresa);
      // }
      // return empresasList;

      // dynamic requestLogin = await EmpresaService().refazLogin();
      dynamic requestLogin = await EmpresaService().listaEmpresas();
      EmpresaEUsuario relogin = new EmpresaEUsuario.fromJson(requestLogin);
      List<Empresa> listaEmpresa = new List<Empresa>();
      listaEmpresa.addAll(relogin.empresas);
      if (listaEmpresa != empresasList) {
        setState(() {
          empresasList.clear();
        });
        empresasList.addAll(listaEmpresa);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String caminhoFoto = '';
      
      prefs.setString(SharedPreference.IDIOMA, relogin.usuario.idioma);
      prefs.setString(SharedPreference.NOME_USUARIO, relogin.usuario.nomeUsuario);
      caminhoFoto = await _armazenaFotoPerfil(relogin.usuario.fotoPerfil);
      prefs.setString(SharedPreference.FOTO_PERFIL, caminhoFoto);
      return empresasList;
    }
    else {
      setState(() {
        empresasList = widget.empresas;
      });
      return empresasList;
    }
  }

  Future<String> _armazenaFotoPerfil(String foto) async {
    if (foto == 'data:image/png;base64,') {
      return '';
    } else {
      foto = foto.replaceFirst('data:image/png;base64,', '');
      foto = foto.replaceAll('\n', '');
      foto = foto.replaceAll('\r', '');
      var _fotoBase64 = base64Decode(foto);
      final Directory saida = await getApplicationDocumentsDirectory();
      _fotoPerfil = File("${saida.path}/foto_perfil.png");
      await _fotoPerfil.writeAsBytes(_fotoBase64.buffer.asUint8List());
      return _fotoPerfil.path;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: LocalizacaoWidget(
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  _locate.locale['TituloSelecionaEmpresa'],
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                ),
                centerTitle: true,
                automaticallyImplyLeading: false,
              ),
              body: _listaEmpresa(),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            );
          }
        ),
      ),
    );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [SemInformacao()]
      );
    }

    else if (empresasList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }

    else if (empresasList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [SemInformacao()]
      );
    }

    else {
      return Scrollbar(
        child: ListView.separated(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) =>
          Divider(
            thickness: 2,
            height: 0,
          ),
          itemBuilder: (context, index) {
            return _empresaItem(context, index, empresasList);
          },
          itemCount:  empresasList.length,
        ),
      );
    }
  }

  Widget _listaEmpresa() {
    return StreamBuilder(
      stream: _streamEmpresas,
      builder: (context, snapshot) {
        return LiquidPullToRefresh(
          key: _refreshIndicatorKey,
          onRefresh: _handleRefresh,
          showChildOpacityTransition: false,
          springAnimationDurationInMilliseconds: 81,
          child: _childStreamConexao(context: context, snapshot: snapshot)
        );
      },
    );
  }

  Widget _empresaItem(BuildContext context, int index, List<Empresa> lista) {
    return FadeInUp(1, InkWell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 21.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              lista[index].nomeFantasia,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              lista[index].nome,
              //snapshot.data.nomeFantasia,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
      onTap: () async {
        List<String> diretivasAcesso = new List<String>();
        dynamic requestDiretivas = await EmpresaService().obterDiretivasAcessoEmpresa(
          empresaId: lista[index].id,
          context: context
        );
        DiretivasAcessoModelo diretivasRetorno = DiretivasAcessoModelo.fromJson(requestDiretivas);
        diretivasAcesso = diretivasRetorno.diretivas.map((e) => e.toString()).toList();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setInt(SharedPreference.EMPRESA_ID, lista[index].id);
        prefs.setString(SharedPreference.EMPRESA_NOME_FANTASIA, lista[index].nomeFantasia);
        prefs.setStringList(SharedPreference.DIRETIVAS_ACESSO, diretivasAcesso);

        _selecionaEmpresa(lista[index].id);
      },
    ));
  }

  void _selecionaEmpresa(int id) {
    Rotas.vaParaPrincipal(context);
  }

  void configOneSignal(BuildContext context) async {
    // Remove this method to stop OneSignal Debugging
    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    
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
        _prefs.setStringList(
            SharedPreference.CONTAS_SELECIONADAS, listaContasEsvaziada);
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
                context,
                  MaterialPageRoute(builder: (context) => AndamentoOrdemServico(idOS: additionalData['entidade']['IdOSXTec'], exibeAssistenteNavegacao: false,))
              );
          }
        } else {
          AutenticacaoRotas.vaParaAutenticacaoSplash(context);
        }
      });
      
    });

    OneSignal.shared
             .setInFocusDisplayType(OSNotificationDisplayType.notification);
  }
  
}
