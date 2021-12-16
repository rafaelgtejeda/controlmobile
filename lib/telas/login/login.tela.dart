import 'dart:convert';
import 'dart:io';

import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:erp/servicos/autenticacao/autenticacao.presenter.dart';
import 'package:erp/models/autenticacao.modelo.dart';
import 'package:erp/models/autenticacao.listener.dart';

import 'package:erp/rotas/rotas.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';

import 'package:erp/utils/fullcontrol.dart';
import 'package:erp/utils/constantes/config.constante.dart';

import 'package:erp/servicos/login/login.presenter.dart';
import 'package:erp/models/login.modelo.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/utils/screen_util.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class LoginTela extends StatefulWidget {
  @override
  _LoginTelaState createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela>
    implements AutenticacaoContract, LoginContract, AuthStateListener {
  RequestUtil _request = new RequestUtil();

  List<Empresa> _listaEmpresas = new List<Empresa>();

  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final FocusNode _codigoFocus = FocusNode();

  TextEditingController codigoController = TextEditingController();
  LocalizacaoServico _locate = new LocalizacaoServico();

  var uuid = Uuid();

  bool _carregandoEnviar = false;
  bool _carregandoSMS = false;
  bool _carregandoEMAIL = false;

  String ddi = "";
  String telefone = "";
  String codigo = "";
  String idioma = "";

  String deviceModel;
  String uuidV4;

  String app = "";
  String logo = "";
  String tema = "";

  File _fotoPerfil = new File('');

  bool _onPressed = false;

  AutenticacaoPresenter _autenticacaoPresenter;
  LoginPresenter _loginPresenter;

  _LoginTelaState() {
    _autenticacaoPresenter = new AutenticacaoPresenter(this);
    _loginPresenter = new LoginPresenter(this);

    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);

    getTema();
  }

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
  }

  void _submit() {
    final form = formKey.currentState;

    if (codigoController.text != "") {
      setState(() => _carregandoEnviar = true);
      form.save();
      _loginPresenter.doLogin(codigo);
    } else {
      _showSnackBar("Preencha os campos obrigatórios.");
      setState(() => _carregandoEnviar = false);
      setState(() => _carregandoSMS = false);
      setState(() => _carregandoEMAIL = false);
    }
  }

  void _enviaSMS() async {
    final form = formKey.currentState;

    setState(() => _carregandoSMS = true);
    form.save();
    _autenticacaoPresenter.doAutenticacao(
        ddi, telefone, Config.envia_sms, idioma);
  }

  void _enviaEmail() async {
    final form = formKey.currentState;

    setState(() => _carregandoEMAIL = true);
    form.save();

    _autenticacaoPresenter.doAutenticacao(
        ddi, telefone, Config.envia_email, idioma);
  }

  pegaValorSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      ddi = prefs.getString(SharedPreference.DDI);
      telefone = prefs.getString(SharedPreference.TELEFONE);
      idioma = prefs.getString(SharedPreference.IDIOMA);
    });
  }

  getTema() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    tema = prefs.getString('tema');
    logo = prefs.getString('logo');
    app = prefs.getString('app');
  }

  bool _screenUtilActive = true;

  setScreenSize() {
    if (!_screenUtilActive)
      Constant.setScreenAwareConstant(context);
    else
      Constant.setDefaultSize(context);

    setState(() {
      _screenUtilActive = !_screenUtilActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    pegaValorSF();

    return LocalizacaoWidget(
      child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Scaffold(
          key: scaffoldKey,
          body: SingleChildScrollView(
            child: SafeArea(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: _backBtnIcon(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _logo(),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _telefone(),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                      "${_locate.locale['PreenchaCamposCodigoRecebido']}.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize:
                              18 * MediaQuery.of(context).textScaleFactor)),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _form(context),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _btnEnviar(context),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_locate.locale['SolicitarNovamente'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize:
                                17 * MediaQuery.of(context).textScaleFactor)),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _solicitarNovamente(context),
                ),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: _version(),
                // ),
              ],
            )),
          ),
        );
      }),
    );
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  Widget _logo() {
    return Container(
      child:
          // --> Inicio logo
          Padding(
              padding:
                  EdgeInsets.only(left: 51, right: 51, top: 30, bottom: 20),
              child: Image.asset(
                logo,
                width: 300 ?? Constant.defaultImageHeight,
              )),
      // --> Fim logo,
    );
  }

  Widget _telefone() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 20),
        child: Text(
          '+$ddi $telefone',
          style: TextStyle(
              fontSize: 24 * MediaQuery.of(context).textScaleFactor,
              fontFamily: 'lato thin',
              fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _form(context) {
    return Container(
      child: Form(
        key: formKey,
        autovalidate: true,
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    top: 31, left: 51, bottom: 31, right: 51),
                child: TextFormField(
                  controller: codigoController,
                  obscureText: false,
                  textAlign: TextAlign.center,
                  maxLength: 5,
                  decoration: InputDecoration(
                      counterText: '',
                      prefixText: '',
                      prefixStyle: TextStyle(),
                      labelText: _locate.locale['SeuCodigoSms'],
                      helperText: _locate.locale['CampoObrigatorio'],
                      labelStyle: TextStyle(
                          color: const Color.fromRGBO(237, 28, 38, 1.0)),
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  focusNode: _codigoFocus,
                  onFieldSubmitted: (term) {
                    _codigoFocus.unfocus();
                    _submit();
                  },
                  onSaved: (val) => codigo = val,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnEnviar(context) {
    //->
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size size = mediaQuery.size;
    //->

    return Container(
      child: Padding(
          padding: EdgeInsets.only(top: 0, left: 81, bottom: 20, right: 81),
          child: Material(
            elevation: 7,
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(40),
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: () async {
                _submit();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.15, vertical: 21),
                child: _carregandoEnviar
                    ? new SpinKitWave(color: Colors.white, size: FontSize.s13)
                    : Text(
                        _locate.locale['Enviar'].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10 * MediaQuery.of(context).textScaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          )),
    );
  }

  Widget _backBtnIcon() {
    return Container(
      height: 40,
      width: 40,
      margin: EdgeInsets.only(
        left: 10,
        top: 10,
      ),
      child: IconButton(
        icon: new Icon(
          Icons.arrow_back_ios,
          size: 30,
        ),
        onPressed: () {
          AutenticacaoRotas.vaParaAutenticacao(context);
        },
      ),
    );
  }

  Widget _solicitarNovamente(context) {
    //->
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size size = mediaQuery.size;
    //->
    return Container(
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Padding(
                padding: EdgeInsets.only(top: 0, left: 5, bottom: 0, right: 5),
                child: Material(
                  elevation: 7,
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      _enviaSMS();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.15, vertical: 21),
                      child: _carregandoSMS
                          ? new SpinKitWave(
                              color: Colors.white,
                              size: 9 * MediaQuery.of(context).textScaleFactor)
                          : Text(
                              _locate.locale[TraducaoStringsConstante.Sms].toUpperCase(),
                              style: TextStyle(
                                fontSize:
                                    9 * MediaQuery.of(context).textScaleFactor,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                )),
          ),
          Flexible(
            child: Padding(
                padding: EdgeInsets.only(top: 0, left: 5, bottom: 0, right: 5),
                child: Material(
                  elevation: 7,
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      _enviaEmail();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.15, vertical: 20),
                      child: _carregandoEMAIL
                          ? new SpinKitWave(
                              color: Colors.white,
                              size: 10 * MediaQuery.of(context).textScaleFactor)
                          : Text(
                              _locate.locale[TraducaoStringsConstante.Email].toUpperCase(),
                              style: TextStyle(
                                fontSize:
                                    10 * MediaQuery.of(context).textScaleFactor,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _version() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(top: 50, bottom: 30),
        child: Text(
          FullControl.Versao,
          style: TextStyle(
              fontFamily: 'lato Thin',
              fontSize: 14 * MediaQuery.of(context).textScaleFactor),
        ),
      ),
    );
  }

  @override
  void onAuthStateChanged(AuthState state) {
    // if (state == AuthState.LOGGED_OUT)
    //   Navigator.of(context).pushReplacementNamed("/autenticacao");
    if (state == AuthState.LOGGED_IN) {
      Rotas.vaParaTermos(context, empresas: _listaEmpresas);
      // Rotas.vaParaEmpresas(context, empresas: _listaEmpresas);
    }
  }

  @override
  void onLoginErro(String errorTxt) {
    // TODO: implement onLoginError
  }

  @override
  void onLoginSucesso(resposta) async {
    String caminhoFoto = '';

    if (resposta.statusCode == 500) {
      _showSnackBar(resposta.statusMessage);
    } else {
      Login autenticacao = Login.fromJson(resposta.data);
      // this.empresas = autenticacao.entidade.empresas;

      setState(() => _carregandoEnviar = false);
      setState(() => _carregandoSMS = false);
      setState(() => _carregandoEMAIL = false);

      //var db = new DatabaseHelper();
      // await db.saveUser(autenticacao);

      var authStateProvider = new AuthStateProvider();

      if (autenticacao.successo == true) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SharedPreference.DDI, ddi);
        prefs.setString(SharedPreference.TELEFONE, telefone);
        prefs.setString(SharedPreference.IDIOMA, autenticacao.entidade.idioma);
        prefs.setString(SharedPreference.CODIGO, codigo);
        prefs.setString(SharedPreference.NOME_USUARIO, autenticacao.entidade.nomeUsuario);
        prefs.setInt(SharedPreference.USUARIO_ID, autenticacao.entidade.usuarioId);
        prefs.setInt(SharedPreference.REGISTRO_ID, autenticacao.entidade.registroId);
        prefs.setString(SharedPreference.TOKEN, autenticacao.entidade.token.token);
        prefs.setString(SharedPreference.TOKEN_DATA_EXPIRACAO, autenticacao.entidade.token.dataExpiracao);
        // prefs.setString(SharedPreference.USUARIO_AUTENTICADO, true.toString());
        // prefs.setString(SharedPreference.PUSH_NOTIFICATION, true.toString());
        // prefs.setString(SharedPreference.BLOQUEAR_APLICATIVO, false.toString());
        // prefs.setString(SharedPreference.MODO_BACKGROUND, true.toString());
        // prefs.setString(SharedPreference.SENHA_BLOQUEIO, '');
        caminhoFoto = await _armazenaFotoPerfil(autenticacao.entidade.fotoPerfil);
        prefs.setString(SharedPreference.FOTO_PERFIL, caminhoFoto);

        _listaEmpresas = autenticacao.entidade.empresas;
        authStateProvider.notify(AuthState.LOGGED_IN);
      } else {
        authStateProvider.notify(AuthState.LOGGED_OUT);
        _showSnackBar(autenticacao.erroCodigo);

        // showAlertDialog(context, 'Aviso!', autenticacao.erroCodigo);

      }
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
  void onAutenticacaoErro(String errorTxt) {
    // TODO: implement onAutenticacaoErro
  }

  @override
  void onAutenticacaoSucesso(resposta) async {
    if (resposta.statusCode == 500) {
      _showSnackBar(resposta.statusMessage);
    } else {
      Autenticacao autenticacao = Autenticacao.fromJson(resposta.data);

      setState(() => _carregandoEnviar = false);
      setState(() => _carregandoSMS = false);
      setState(() => _carregandoEMAIL = false);

      // var db = new DatabaseHelper();
      // await db.saveUser(autenticacao);

      if (autenticacao.successo == true) {
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // prefs.setString(SharedPreference.DDI, ddi);
        // prefs.setString(SharedPreference.TELEFONE, telefone);
        // prefs.setString(SharedPreference.IDIOMA, idioma);

      } else {
        _showSnackBar(autenticacao.erroCodigo);
        // showAlertDialog(context, 'Aviso!', autenticacao.erroCodigo);
      }
    }
  }
}
