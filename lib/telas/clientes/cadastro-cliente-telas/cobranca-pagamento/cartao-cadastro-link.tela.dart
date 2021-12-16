import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/rotas/clientes.rotas.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:provider/provider.dart';

class CadastroCartaoLinkTela extends StatefulWidget {
  final String link;

  CadastroCartaoLinkTela({this.link});

  @override
  _CadastroCartaoLinkTelaState createState() => _CadastroCartaoLinkTelaState();
}

class _CadastroCartaoLinkTelaState extends State<CadastroCartaoLinkTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();

  @override
  void initState() { 
    super.initState();
    _locale.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locale.locale['CadastroCartaoLink']),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _locale.locale['FormasEnvioLink'],
                        style: TextStyle(
                          fontSize: 24
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _locale.locale['LinkCadastro'] + ':',
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black
                        )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.link,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue[800]
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _locale.locale['EscolhaFormaEnvio'] + ':',
                        style: TextStyle(
                          fontSize: 18
                        ),
                      ),
                    ),
                    ButtonComponente(
                      funcao: () {
                        RotasClientes.vaParaCadastroCartaoWhatsApp(
                          context,
                          link: widget.link
                        );
                      },
                      ladoIcone: 'Esquerdo',
                      imagemCaminho: AssetsIconApp.Add,
                      somenteTexto: true,
                      somenteIcone: false,
                      texto: _locale.locale['WhatsApp'].toUpperCase(),
                      backgroundColor: Colors.green,
                      textColor: Colors.white
                    ),
                    ButtonComponente(
                      funcao: () async {
                        if(await _salvar() == true) {
                          Navigator.pop(context);
                        }
                      },
                      ladoIcone: 'Esquerdo',
                      imagemCaminho: AssetsIconApp.Add,
                      somenteTexto: true,
                      somenteIcone: false,
                      texto: _locale.locale['EmailSMS'].toUpperCase(),
                      backgroundColor: Colors.blue,
                      textColor: Colors.white
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Future<bool> _salvar() async {
    // Tratar Cadastro Cliente
    bool resultado;
    Response request = await ClienteService().cobrancaPagamento.emailSMS.enviarEmailSMS(area: 11, customizado: false, context: context);
    if (request.statusCode == 200) resultado = true;
    else resultado = false;
    return resultado;
  }
}
