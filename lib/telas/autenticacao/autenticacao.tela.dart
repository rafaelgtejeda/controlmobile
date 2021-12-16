import 'dart:convert';

import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/compartilhados/componentes/idioma-selecao/idioma-selecao.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';

import 'package:erp/telas/lista-paises/lista-paises.tela.dart';
import 'package:erp/utils/screen_util.dart';

import 'package:erp/models/autenticacao.modelo.dart';
import 'package:erp/models/autenticacao.listener.dart';
import 'package:erp/servicos/autenticacao/autenticacao.presenter.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/utils/fullcontrol.dart';

class AutenticacaoTela extends StatefulWidget {
  @override
  _AutenticacaoTelaState createState() => _AutenticacaoTelaState();
}

class _AutenticacaoTelaState extends State<AutenticacaoTela>
    with TickerProviderStateMixin
    implements AutenticacaoContract, AuthStateListener {
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  LocalizacaoServico _locale = new LocalizacaoServico();

  final TextEditingController ddiController = TextEditingController();
  // final TextEditingController telefoneController = TextEditingController();
  // final TextEditingController telefoneController = TextEditingController();
  var telefoneController = new MaskedTextController(mask: MascarasConstantes.MOBILE_PHONE_BR_COMPLETO);

  final FocusNode _telefoneFocus = FocusNode();
  final FocusNode _ddiFocus = FocusNode();

  final double size = 0.0;

  String app = "";
  String logo = "";
  String tema = "";

  String telefone, _idiomaEnvio = "pt-br";

  bool _isLoading = false;
  bool _onPressed = false;
  bool _screenUtilActive = true;

  Color _corSplash = Colors.green;
  List<bool> _idiomaSelecionado = new List<bool>();
  final GlobalKey<IdiomaSelecaoComponenteState> _idiomaComponenteKey =
      new GlobalKey<IdiomaSelecaoComponenteState>();

  AutenticacaoPresenter _presenter;

  _AutenticacaoTelaState() {
    _presenter = new AutenticacaoPresenter(this);

    var authStateProvider = new AuthStateProvider();
    authStateProvider.subscribe(this);

    getTema();
  }

  var ddi;
  var result;

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      _presenter.doAutenticacao(
          ddi, telefone, Config.envia_email, _idiomaEnvio);
    }
  }

  getTema() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    tema = prefs.getString('tema');
    logo = prefs.getString('logo');
    app = prefs.getString('app');
  }

  @override
  void onAuthStateChanged(AuthState state) {
    if (state == AuthState.LOGGED_IN) AutenticacaoRotas.vaParaLogin(context);
    // if (state == AuthState.LOGGED_IN) {Rotas.vaParaEmpresas(context);}
  }

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
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return null;
      },
      child: LocalizacaoWidget(
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
                      alignment: Alignment.topCenter,
                      child: _logo(),
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: _form(context),
                    ),

                    Container(
                      height: Constant.sizeLarge,
                    ),

                    Align(
                      alignment: Alignment.topCenter,
                      child: _textoDDI(context),
                    ),

                    Container(
                      height: Constant.sizeLarge,
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _btnAvancar(context),
                    ),

                    Container(
                      height: Constant.sizeLarge,
                    ),

                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _textoNaoSeiDDI(context),
                    ),

                    Container(
                      height: Constant.sizeLarge,
                    ),

                    IdiomaSelecaoComponente(
                      key: _idiomaComponenteKey,
                      atualizaIdioma: _atualizaIdioma,
                      atualizaIdiomaDeEnvio: _atualizaIdiomaDeEnvio,
                    ),

                    // Align(
                    //   alignment: Alignment.bottomCenter,
                    //   child: _versao(),
                    // ),

                    Container(
                      height: Constant.sizeLarge,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  _atualizaIdioma() async {
    await _locale.iniciaLocalizacao(context);
    setState(() {});
  }

  _atualizaIdiomaDeEnvio(String idioma) {
    _idiomaEnvio = idioma;
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  Widget _logo() {
    return Container(
      padding: Constant.spacingAllSmall,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: Constant.screenWidthTenth),
          child: Image.asset(
            //  (app == Config.Fullcontrol) ?
            //  ((tema == 'TemaEscuro') ? Config.LogoFullcontrolDark : Config.LogoFullcontrolLight) :
            //  ((tema == 'TemaEscuro') ? Config.LogoAtmosDark : Config.LogoAtmosLight),

            logo,
            width: 300 ?? Constant.defaultImageHeight,
          )),
    );
  }

  Widget _form(context) {
    return Container(
        child: Form(
      key: formKey,
      autovalidate: true,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        child: TextFormField(
                          controller: ddiController,
                          obscureText: false,
                          textAlign: TextAlign.left,
                          maxLength: 3,
                          decoration: InputDecoration(
                            counterText: '',
                            prefixText: '+ ',
                            labelText: "${_locale.locale['Ddi']}: ",
                            helperText: "${_locale.locale['DigiteDdi']}.",
                            errorText: "",
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          focusNode: _ddiFocus,
                          onFieldSubmitted: (term) {
                            if (term != '55') {
                              telefoneController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
                            }
                            else {
                              telefoneController.updateMask(MascarasConstantes.MOBILE_PHONE_BR_COMPLETO);
                            }
                            _ddiFocus.nextFocus();
                            // _fieldFocusChange(context, _ddiFocus, _telefoneFocus);
                          },
                          onSaved: (val) => ddi = val,
                          validator: (value) {
                            if (value.length == 0 ||
                                double.parse(value) == 0.0) {
                              _onPressed = false;
                            } else {
                              _onPressed = true;
                            }
                          },
                        ),
                      )),
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15),
                        child: TextFormField(
                          controller: telefoneController,
                          obscureText: false,
                          textAlign: TextAlign.left,
                          decoration: InputDecoration(
                              prefixText: '',
                              prefixStyle: TextStyle(),
                              labelText: "${_locale.locale['SeuTelefone']}:",
                              helperText:
                                  "${_locale.locale['DigiteTelefone']}.",
                              errorText: "",
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          focusNode: _telefoneFocus,
                          onFieldSubmitted: (term) {
                            _telefoneFocus.unfocus();
                            _submit();
                          },
                          onSaved: (val) {
                            String unmaskedTelefone = val.replaceAll('(', '');
                            unmaskedTelefone = unmaskedTelefone.replaceAll(')', '');
                            unmaskedTelefone = unmaskedTelefone.replaceAll('-', '');
                            unmaskedTelefone = unmaskedTelefone.replaceAll(' ', '');
                            telefone = unmaskedTelefone;
                          },
                          validator: (value) {
                            if (value.length == 0) {
                              _onPressed = false;
                            } else {
                              _onPressed = true;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  Widget _textoDDI(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: Constant.sizeExtraSmall,
            horizontal: Constant.screenWidthTenth),
        child: Center(
          child: Text(
            _locale.locale['DdiPaisCodigoAreaNumero'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16 * MediaQuery.of(context).textScaleFactor,
              fontFamily: 'Lato Thin',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnAvancar(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: Constant.sizeExtraSmall,
                horizontal: Constant.screenWidthTenth),
            child: Material(
              elevation: 7,
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40),
              child: InkWell(
                borderRadius: BorderRadius.circular(40),
                onTap: () {
                  if (_onPressed == false) {
                    _showSnackBar(_locale.locale['PreenchaCamposObrigatorios']);
                  } else {
                    _submit();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: _isLoading
                      ? SpinKitWave(color: Colors.white, size: FontSize.s13)
                      : Text(
                          _locale.locale['Avancar'].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                13 * MediaQuery.of(context).textScaleFactor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            )),
      ),
    );
  }

  Widget _textoNaoSeiDDI(context) {
    return InkWell(
      onTap: () {
        _navigateAndDisplaySelection(context);
      },
      child: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: Constant.sizeExtraSmall,
              horizontal: Constant.screenWidthTenth),
          child: Center(
            child: Text(_locale.locale['NaoSeiDdi'],
                style: TextStyle(
                    fontSize: 13 * MediaQuery.of(context).textScaleFactor,
                    decoration: TextDecoration.underline)),
          ),
        ),
      ),
    );
  }

  Widget _versao() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Constant.sizeExtraSmall,
          horizontal: Constant.screenWidthTenth),
      child: Text(
        FullControl.Versao,
        style: TextStyle(
            decoration: TextDecoration.none,
            fontWeight: FontWeight.normal,
            fontStyle: FontStyle.normal,
            fontFamily: 'Lato Thin',
            fontSize: 14 * MediaQuery.of(context).textScaleFactor),
      ),
    );
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void onAutenticacaoErro(String errorTxt) {
    _showSnackBar(errorTxt);
  }

  @override
  void onAutenticacaoSucesso(resposta) async {
    if (resposta.statusCode == 500) {
      _showSnackBar(resposta.statusMessage);
      setState(() => _isLoading = true);
    } else {
      Autenticacao autenticacao = Autenticacao.fromJson(resposta.data);

      setState(() => _isLoading = false);

      // var db = new DatabaseHelper();
      // await db.saveUser(autenticacao);

      var authStateProvider = new AuthStateProvider();

      if (autenticacao.successo == true) {
        authStateProvider.notify(AuthState.LOGGED_IN);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString(SharedPreference.DDI, ddi);
        prefs.setString(SharedPreference.TELEFONE, telefone);
      } else {
        authStateProvider.notify(AuthState.LOGGED_OUT);
        _showSnackBar(autenticacao.erroCodigo);

        // showAlertDialog(context, 'Aviso!', autenticacao.erroCodigo);
      }
    }
  }

  showAlertDialog(BuildContext context, titulo, texto) {
    // configura o button
    Widget okButton = FlatButton(
      child: Text("Fechar"),
      onPressed: () {},
    );
    // configura o  AlertDialog
    AlertDialog alerta = AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        okButton,
      ],
    );
    // exibe o dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alerta;
      },
    );
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ListaPaisesTela()),
    );
    // ddiController.text = result;
    if (result != null) {
      ddiController.text = result;
    }
    if (result != '55') {
      telefoneController.updateMask(MascarasConstantes.TELEFONE_PADRAO);
    }
    else {
      telefoneController.updateMask(MascarasConstantes.MOBILE_PHONE_BR_COMPLETO);
    }
  }
}
