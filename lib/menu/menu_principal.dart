import 'dart:convert';
import 'dart:io';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/servicos/offiline/offline.servico.dart';
import 'package:erp/servicos/offiline/offline_new.servico.dart';
import 'package:erp/telas/configuracao/configuracao.tela.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erp/compartilhados/componentes/accordion.componente.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/compartilhados/componentes/idioma-selecao/idioma-selecao.componente.dart';
import 'package:erp/menu/menu_button.dart';
import 'package:erp/menu/menu_tile.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/fullcontrol.dart';
import 'package:erp/utils/request.util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuPrincipal extends StatefulWidget {
  final Function atualizaIdioma;
  MenuPrincipal({Key key, this.atualizaIdioma}) : super(key: key);
  @override
  _MenuPrincipalState createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends State<MenuPrincipal> {
  String ddi = "";
  String telefone = "";
  File fotoPerfil = File('');
  String nomeUsuario = "";

  bool _isOnline = true;

  bool _bloquearAplicativo = false;
  bool _pushNotification = false;
  bool _sincronizar = false;
  String _idiomaEnvio = '';
  final GlobalKey<IdiomaSelecaoComponenteState> _idiomaComponenteKey =
      new GlobalKey<IdiomaSelecaoComponenteState>();

  LocalizacaoServico _locale = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();

  @override
  void initState() {
    _locale.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    super.initState();
    adquireValores();
    _inicializaValoresConfiguracoes();
  }

  _inicializaValoresConfiguracoes() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String bloqueioValue = '';
    String pushValue = '';
    String sincronizarValue = '';

    bloqueioValue = _prefs.getString(SharedPreference.BLOQUEAR_APLICATIVO);
    pushValue = _prefs.getString(SharedPreference.PUSH_NOTIFICATION);
    sincronizarValue = _prefs.getString(SharedPreference.MODO_BACKGROUND);

    if (bloqueioValue == 'true') {
      setState(() {
        _bloquearAplicativo = true;
      });
    } else {
      setState(() {
        _bloquearAplicativo = false;
      });
    }

    if (pushValue == 'true') {
      setState(() {
        _pushNotification = true;
      });
    } else {
      setState(() {
        _pushNotification = false;
      });
    }

    if (sincronizarValue == 'true') {
      setState(() {
        _sincronizar = true;
      });
    } else {
      setState(() {
        _sincronizar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        initialData: '',
        builder: (context, snapshot) {
          return Drawer(
            child: Stack(
              children: <Widget>[
                Container(),
                ListView(
                  children: _constroiMenu(),
                ),
                
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _constroiMenu() {
    int indexCounter = 0;
    List<Widget> listaWidget = new List<Widget>();

    listaWidget.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(
            "${_locale.locale[TraducaoStringsConstante.Versao]} ${FullControl.Versao}",
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
    listaWidget.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 3,
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
              image: DecorationImage(
                image: fotoPerfil != null
                  ? FileImage(fotoPerfil)
                  : AssetImage(AssetsImagens.USUARIO_PADRAO))),
           
          ),
          SizedBox(
            height: 17,
          ),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 76),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  nomeUsuario,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          SizedBox(
            height: 25,
          ),
          SizedBox(
            height: 65,
            width: double.infinity,
            child: Container(
                color: Colors.grey[800],
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "+$ddi $telefone",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                )),
          )
        ],
      ),
    );
    listaWidget.add(
      Divider(),
    );
    
    listaWidget.add(
      Divider(
        thickness: 2,
      ),
    );
   
    if (_diretivas.diretivasDisponiveis.ordemServico.possuiOrdemDeServico) {
      int indice = indexCounter;
      listaWidget.add(MenuTile(
        Icons.assignment_turned_in,
        "${_locale.locale[TraducaoStringsConstante.OrdemDeServico]}",
        funcao: () {
          Rotas.vaParaTabs(context, indice);
        },
      ));
      indexCounter++;
    }

    if (_diretivas.diretivasDisponiveis.cliente.possuiClientes) {
      int indice = indexCounter;
      listaWidget.add(
        MenuTile(
          Icons.person,
          "${_locale.locale[TraducaoStringsConstante.Clientes]}",
          funcao: _isOnline
            ? () {
              Rotas.vaParaTabs(context, indice);
            }
            : () {},
        ),
      );
      indexCounter++;
    }

    if (_diretivas.diretivasDisponiveis.venda.possuiVendas) {
      int indice = indexCounter;
      listaWidget.add(
        MenuTile(
          Icons.assignment,
          "${_locale.locale[TraducaoStringsConstante.Vendas]}",
          funcao: () {
            Rotas.vaParaTabs(context, indice);
          },
        ),
      );
      indexCounter++;
    }
    // MenuTile(
    //   Icons.assignment, "${_locale.locale['Orcamento']}"
    // ),

    if (_diretivas.diretivasDisponiveis.financeiro.possuiFinanceiro) {
      int indice = indexCounter;
      listaWidget.add(
        MenuTile(
          Icons.monetization_on,
          _locale.locale[TraducaoStringsConstante.Financeiro],
          funcao: _isOnline
            ? () async {
              List<String> contasIds = new List<String>();
              contasIds = await RequestUtil().obterIdsContasSharedPreferences();
              if (contasIds.isNotEmpty) {
                Rotas.vaParaTabs(context, indice);
              } else {
                final bool resultado =
                    await Rotas.vaParaSelecaoContas(context, args: indice);
                if (resultado == true) {
                  Rotas.vaParaTabs(context, indice);
                }
              }
            }
            : () {},
        ),
        // MenuTile(Icons.event, "Agenda"),
      );
      indexCounter++;
    }

    if (_diretivas.diretivasDisponiveis.venda.possuiVendas) {
      int indice = indexCounter;
      listaWidget.add(
        MenuTile(
          Icons.settings,
          "${_locale.locale[TraducaoStringsConstante.Configuracoes]}",
          funcao: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ConfiguracaoTela()));
          },
        ),
      );
      indexCounter++;
    }

    listaWidget.add(
      Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Texto(
                _locale.locale[TraducaoStringsConstante.BloquearAplicativo],
                bold: true,
                fontSize: 18
            ),
            Switch(
              value: _bloquearAplicativo,
              onChanged: (value) async {
                bool valorResultado = false;
                bool valorFinal = false;
                dynamic resultado;
                if (value == true) {
                  resultado =
                      await Rotas.vaParaConfigurarBloqueio(context);
                } else {
                  resultado = await Rotas.vaParaConfigurarBloqueio(
                      context,
                      removerBloqueio: true);
                }

                if (resultado == false || resultado == null) {
                  valorResultado = false;
                } else {
                  valorResultado = true;
                }

                if (valorResultado == true) {
                  if (value == true) {
                    valorFinal = true;
                  } else {
                    valorFinal = false;
                  }
                } else {
                  if (value == false) {
                    valorFinal = true;
                  } else {
                    valorFinal = false;
                  }
                }

                SharedPreferences _prefs =
                    await SharedPreferences.getInstance();
                _prefs.setString(SharedPreference.BLOQUEAR_APLICATIVO,
                    valorFinal.toString());
                setState(() {
                  _bloquearAplicativo = valorFinal;
                });
              },
            )
          ],
        ),
      ),
    );

    // listaWidget.add(
    //   Accordion(
    //     aberto: false,
    //     titulo: <Widget>[
    //       Container(
    //         padding: EdgeInsets.symmetric(horizontal: 25),
    //         height: 50,
    //         child: Row(
    //           children: <Widget>[
    //             Icon(
    //               Icons.settings,
    //             ),
    //             SizedBox(
    //               width: 32,
    //             ),
    //             Texto(
    //               _locale.locale[TraducaoStringsConstante.Configuracoes],
    //             )
    //           ],
    //         ),
    //       ),
    //     ],
    //     itens: <Widget>[
    //       Padding(
    //         padding: const EdgeInsets.all(12.0),
    //         child: Column(
    //           children: <Widget>[
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: <Widget>[
    //                 Texto(
    //                     _locale.locale[TraducaoStringsConstante.BloquearAplicativo],
    //                     bold: true,
    //                     fontSize: 18),
    //                 Switch(
    //                   value: _bloquearAplicativo,
    //                   onChanged: (value) async {
    //                     bool valorResultado = false;
    //                     bool valorFinal = false;
    //                     dynamic resultado;
    //                     if (value == true) {
    //                       resultado =
    //                           await Rotas.vaParaConfigurarBloqueio(context);
    //                     } else {
    //                       resultado = await Rotas.vaParaConfigurarBloqueio(
    //                           context,
    //                           removerBloqueio: true);
    //                     }

    //                     if (resultado == false || resultado == null) {
    //                       valorResultado = false;
    //                     } else {
    //                       valorResultado = true;
    //                     }

    //                     if (valorResultado == true) {
    //                       if (value == true) {
    //                         valorFinal = true;
    //                       } else {
    //                         valorFinal = false;
    //                       }
    //                     } else {
    //                       if (value == false) {
    //                         valorFinal = true;
    //                       } else {
    //                         valorFinal = false;
    //                       }
    //                     }

    //                     SharedPreferences _prefs =
    //                         await SharedPreferences.getInstance();
    //                     _prefs.setString(SharedPreference.BLOQUEAR_APLICATIVO,
    //                         valorFinal.toString());
    //                     setState(() {
    //                       _bloquearAplicativo = valorFinal;
    //                     });
    //                   },
    //                 )
    //               ],
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //               children: <Widget>[
    //                 Texto(
    //                     _locale
    //                         .locale[TraducaoStringsConstante.NotificacaoPush],
    //                     bold: true,
    //                     fontSize: 18),
    //                 Switch(
    //                     value: _pushNotification,
    //                     onChanged: (value) async {
    //                       SharedPreferences _prefs =
    //                           await SharedPreferences.getInstance();
    //                       _prefs.setString(SharedPreference.PUSH_NOTIFICATION,
    //                           value.toString());
    //                       setState(() {
    //                         _pushNotification = value;
    //                       });
    //                     })
    //               ],
    //             ),
    //             Visibility(
    //               visible: _isOnline,
    //               child: InkWell(
    //                 child: Padding(
    //                   padding: const EdgeInsets.symmetric(vertical: 12.0),
    //                   child: Row(
    //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                     children: <Widget>[
    //                       Texto(_locale.locale[TraducaoStringsConstante.Sincronizar], bold: true, fontSize: 18),
    //                       Icon(Icons.sync)                          
    //                     ],
    //                   ),
    //                 ),
    //                 onTap: () async {
    //                   await OfflineServiceNew().sincronizacaoDownload(context);
    //                 },
    //               ),
    //             ),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               children: <Widget>[
    //                 Texto(_locale.locale[TraducaoStringsConstante.Idioma],
    //                     bold: true, fontSize: 18, textAlign: TextAlign.left),
    //               ],
    //             ),
    //             Padding(
    //               padding: const EdgeInsets.all(4.0),
    //               child: IdiomaSelecaoComponente(
    //                 key: _idiomaComponenteKey,
    //                 atualizaIdioma: _atualizaIdioma,
    //                 atualizaIdiomaDeEnvio: _atualizaIdiomaDeEnvio,
    //                 atualizaEmBanco: true,
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ), 
    // );
    
   listaWidget.add(
     Padding(
       padding: const EdgeInsets.only(left:20),
       child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Texto(_locale.locale[TraducaoStringsConstante.Idioma],
                bold: true, fontSize: 18, textAlign: TextAlign.left),
          ],
        ),
     ),
   );

   listaWidget.add(     
      Padding(
        padding: const EdgeInsets.only(top: 20, left: 20),
        child: IdiomaSelecaoComponente(
          key: _idiomaComponenteKey,
          atualizaIdioma: _atualizaIdioma,
          atualizaIdiomaDeEnvio: _atualizaIdiomaDeEnvio,
          atualizaEmBanco: true,
        ),
      )
   );
    
    listaWidget.add(
      SizedBox(
        height: 20,
      ),
    );
    listaWidget.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: MenuBotao(
            Icons.cached, "${_locale.locale[TraducaoStringsConstante.TrocarEmpresa]}", _trocarEmpresa),
      ),
    );
    listaWidget.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: MenuBotao(null, "${_locale.locale[TraducaoStringsConstante.Logout]}", () async {
          bool confirmacao = await AlertaComponente().showAlertaConfirmacao(
            context: context, mensagem: _locale.locale[TraducaoStringsConstante.LogoutConfirmacao]
          );

          if (confirmacao) {
            await SharedPreference().clearStorage();
            DBProvider().deleteAllOffline();
            AutenticacaoRotas.vaParaAutenticacaoSplash(context);
          }
        }),
      ),
    );

    return listaWidget;
  }

  _trocarEmpresa() async {
    List<String> listaContasEsvaziada = new List<String>();
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setStringList(SharedPreference.CONTAS_SELECIONADAS, listaContasEsvaziada);
    Rotas.vaParaEmpresas(context);
  }

  _atualizaIdioma() async {
    await _locale.iniciaLocalizacao(context);
    widget.atualizaIdioma();
    setState(() {});
  }

  _atualizaIdiomaDeEnvio(String idioma) {
    _idiomaEnvio = idioma;
  }

  adquireValores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      ddi = prefs.getString(SharedPreference.DDI);
      telefone = prefs.getString(SharedPreference.TELEFONE);
      nomeUsuario = prefs.getString(SharedPreference.NOME_USUARIO);
      fotoExiste().then((resultado) {
        if (resultado == true) {
          String foto = prefs.getString(SharedPreference.FOTO_PERFIL);
          fotoPerfil = File(foto);
        } else
          fotoPerfil = null;
      });
    });
  }

  Future<bool> fotoExiste() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String valor = prefs.getString(SharedPreference.FOTO_PERFIL).toString();
    if (valor == "") {
      return false;
    } else {
      return true;
    }
  }
}
