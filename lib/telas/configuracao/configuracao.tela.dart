import 'dart:async';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/offiline/offline_new.servico.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:provider/provider.dart';
import 'package:erp/utils/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfiguracaoTela extends StatefulWidget {
  ConfiguracaoTela({Key key}) : super(key: key);
  _ConfiguracaoTelaState createState() => _ConfiguracaoTelaState();
}

class _ConfiguracaoTelaState extends State<ConfiguracaoTela> {

  LocalizacaoServico _locale = new LocalizacaoServico();
  Helper helper = new Helper();

  TextEditingController _cronMinutoController = new TextEditingController();
  
  bool _bloquearAplicativo = false;
  bool _pushNotification = false;
  bool _sincronizar = false;

  @override
  void initState() {
    super.initState();

    _locale.iniciaLocalizacao(context);
    carregaCron();
  }

  carregaCron() async {
    List<Agendador> agendador = await Agendador().select().id.equals(1).toList();
    _cronMinutoController.text = agendador[0].dataCron;
  }
  
  @override
  void dispose() {

    super.dispose();
  }
    
  @override
  Widget build(BuildContext context) {

    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              actions: <Widget>[
              ],
              title: Text(_locale.locale["Configuracoes"].toUpperCase(), style: TextStyle(fontSize: 16))
            ),
            body: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: <Widget>[
                    //       Texto(
                    //           _locale.locale[TraducaoStringsConstante.BloquearAplicativo],
                    //           bold: true,
                    //           fontSize: 18
                    //       ),
                    //       Switch(
                    //         value: _bloquearAplicativo,
                    //         onChanged: (value) async {
                    //           bool valorResultado = false;
                    //           bool valorFinal = false;
                    //           dynamic resultado;
                    //           if (value == true) {
                    //             resultado =
                    //                 await Rotas.vaParaConfigurarBloqueio(context);
                    //           } else {
                    //             resultado = await Rotas.vaParaConfigurarBloqueio(
                    //                 context,
                    //                 removerBloqueio: true);
                    //           }

                    //           if (resultado == false || resultado == null) {
                    //             valorResultado = false;
                    //           } else {
                    //             valorResultado = true;
                    //           }

                    //           if (valorResultado == true) {
                    //             if (value == true) {
                    //               valorFinal = true;
                    //             } else {
                    //               valorFinal = false;
                    //             }
                    //           } else {
                    //             if (value == false) {
                    //               valorFinal = true;
                    //             } else {
                    //               valorFinal = false;
                    //             }
                    //           }

                    //           SharedPreferences _prefs =
                    //               await SharedPreferences.getInstance();
                    //           _prefs.setString(SharedPreference.BLOQUEAR_APLICATIVO,
                    //               valorFinal.toString());
                    //           setState(() {
                    //             _bloquearAplicativo = valorFinal;
                    //           });
                    //         },
                    //       )
                    //     ],
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Texto(
                              _locale.locale[TraducaoStringsConstante.NotificacaoPush],
                              bold: true,
                              fontSize: 18),
                          Switch(
                              value: _pushNotification,
                              onChanged: (value) async {
                                SharedPreferences _prefs =
                                    await SharedPreferences.getInstance();
                                _prefs.setString(SharedPreference.PUSH_NOTIFICATION,
                                    value.toString());
                                setState(() {
                                  _pushNotification = value;
                                });
                              })
                        ],
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Visibility(
                    //     visible: _isOnline,
                    //     child: InkWell(
                    //       child: Padding(
                    //         padding: const EdgeInsets.symmetric(vertical: 0.0),
                    //         child: Row(
                    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //           children: <Widget>[
                    //             Texto(_locale.locale[TraducaoStringsConstante.Sincronizar], bold: true, fontSize: 18),
                    //             // Icon(Icons.sync)                          
                    //           ],
                    //         ),
                    //       ),
                    //       onTap: () async {
                    //         await OfflineServiceNew().sincronizacaoDownload(context);
                    //       },
                    //     ),
                    //   ),
                    // ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ArgonButton(
                        height: 55,
                        roundLoadingShape: true,
                        width: MediaQuery.of(context).size.width * 0.99,
                        minWidth: MediaQuery.of(context).size.width * 0.0,
                        onTap: (startLoading, stopLoading, btnState) async {
                          
                          startLoading();
                          await OfflineServiceNew().sincronizacaoDownload(context).then((value) => stopLoading());
                          

                          // if (btnState == ButtonState.Idle) {
                          //   startLoading();
                          //   await OfflineServiceNew().sincronizacaoDownload(context);
                          //   stopLoading();
                          // } else {
                          //   stopLoading();
                          // }

                        },
                        child: Text(
                          _locale.locale[TraducaoStringsConstante.Sincronizar],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        loader: SpinKitRing(
                          color: Colors.white,
                          // size: loaderWidth ,
                        ),
                        borderRadius: 22.0,
                        color: Colors.black54,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        controller: _cronMinutoController,
                        decoration: InputDecoration(
                          labelText: _locale.locale[TraducaoStringsConstante.DigiteIntervaloMinutos],
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        maxLength: 3,
                        onSaved: (input) => {},
                        onFieldSubmitted: (term) {},
                        textInputAction: TextInputAction.done,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ArgonButton(
                        height: 55,
                        roundLoadingShape: true,
                        width: MediaQuery.of(context).size.width * 0.99,
                        minWidth: MediaQuery.of(context).size.width * 0.0,
                        onTap: (startLoading, stopLoading, btnState) async {
                          
                          startLoading();
                          await Agendador.withId(1, 1, _cronMinutoController.text, false).save().then((value) => stopLoading());


                          // if (btnState == ButtonState.Idle) {
                          //   startLoading(); 
                          //   stopLoading();
                          // } else {
                          //   stopLoading();
                          // }

                        },
                        child: Text(
                          _locale.locale[TraducaoStringsConstante.Salvar],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700),
                        ),
                        loader: SpinKitRing(
                          color: Colors.white,
                          // size: loaderWidth ,
                        ),
                        borderRadius: 22.0,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                  ],
                ),
              ),
            ),        
          );
        }
      ),
    );
  }



  
}
