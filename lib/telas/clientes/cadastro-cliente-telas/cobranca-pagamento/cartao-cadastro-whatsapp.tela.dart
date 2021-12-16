import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CadastroCartaoWhatsAppTela extends StatefulWidget {
  final String link;

  CadastroCartaoWhatsAppTela({this.link});

  @override
  _CadastroCartaoWhatsAppTelaState createState() => _CadastroCartaoWhatsAppTelaState();
}

class _CadastroCartaoWhatsAppTelaState extends State<CadastroCartaoWhatsAppTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();

  TextEditingController _destinatarioController = new TextEditingController();
  TextEditingController _mensagemController = new TextEditingController();

  String _destinatario = '';
  String _mensagem = '';

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _autovalidate = false;

  @override
  void initState() { 
    super.initState();
    _locale.iniciaLocalizacao(context);
    _mensagemController.text = widget.link;
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(_locale.locale['EnviarWhatsApp']),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  autovalidate: _autovalidate,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Tooltip(
                          message: _locale.locale['InstrucaoDestinatario'],
                          child: TextFormField(
                            controller: _destinatarioController,
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: _locale.locale['ExemploDestinatario'],
                              labelText: _locale.locale['Destinatario'],
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 20,
                            validator: (input) {
                              if (input.isEmpty) {
                                return _locale.locale['PreenchaDestinatario'];
                              }
                              else {
                                return null;
                              }
                            },
                            keyboardType: TextInputType.phone,
                            onSaved: (input) => _destinatario = input,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _mensagemController,
                          decoration: InputDecoration(
                            labelText: "${_locale.locale['Mensagem']}",
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                          keyboardType: TextInputType.text,
                          onSaved: (input) => _mensagem = input,
                        ),
                      ),
                      ButtonComponente(
                        funcao: _submit,
                        ladoIcone: 'Esquerdo',
                        imagemCaminho: AssetsIconApp.Add,
                        somenteTexto: true,
                        somenteIcone: false,
                        texto: _locale.locale['EnviarWhatsApp'].toUpperCase(),
                        backgroundColor: Colors.green,
                        textColor: Colors.white
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      whatsAppOpen();
    }
    else {
      setState(() {
        _autovalidate = true;
      });
    }
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  void whatsAppOpen() async {
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    if (whatsapp) {
      await FlutterLaunch.launchWathsApp(phone: _destinatario, message: _mensagem);
    }
    else {
      _showSnackBar(_locale.locale['ErroWhatsApp']);
    }
  }
}

// class FlutterLaunch {
//   static const MethodChannel _channel = const MethodChannel('flutter_launch');

//   static Future<Null> launchWathsApp(
//       {@required String phone, @required String message}) async {
//     if(Platform.isIOS || Platform.isMacOS) {
//       final Map<String, dynamic> params = <String, dynamic>{
//         'phone': phone,
//         'text': message
//       };
//       await _channel.invokeMethod('launchWathsApp', params);
//     }
//     else {
//       final Map<String, dynamic> params = <String, dynamic>{
//         'phone': phone,
//         'message': message
//       };
//       await _channel.invokeMethod('launchWathsApp', params);
//     }
//   }

//   static Future<bool> hasApp({@required String name}) async {
//     final Map<String, dynamic> params = <String, dynamic>{
//       'name': name,
//     };
//     return await _channel.invokeMethod('hasApp', params);
//   }
// }
