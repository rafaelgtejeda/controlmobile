import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/rotas/autenticacao.rotas.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/termos/termo.servico.dart';
import 'package:erp/telas/autenticacao/autenticacao.tela.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';

class TermosTela extends StatefulWidget {
  List<Empresa> empresas;
  TermosTela({Key key, this.empresas}) : super(key: key);
  _TermosTelaState createState() => _TermosTelaState();
}

class _TermosTelaState extends State<TermosTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();

  Helper helper = new Helper();

  var idioma, app, nomeApp, nomeEmpresa;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  _TermosTelaState() {}

  recuperaIdioma() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    idioma = prefs.getString(SharedPreference.IDIOMA);
    app = prefs.getString('app');
    nomeApp = app == 'Fullcontrol' ? 'FullControl' : 'ATMOS';
    nomeEmpresa = app == 'Fullcontrol' ? 'Fulltime' : 'FRG Informática';
  }

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    recuperaIdioma();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: LocalizacaoWidget(
        child: StreamBuilder(
            builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              actions: <Widget>[],
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Text(_locale.locale[TraducaoStringsConstante.TermosDeUso].toUpperCase(),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0),
                child: Container(),
              ),
            ),
            body: SingleChildScrollView(child: termoDeUso()),
            bottomNavigationBar: BottomAppBar(
              child: Container(
                color: Colors.black,
                height: 60,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: _rodape(context)),
              ),
              color: Theme.of(context).primaryColor,
            ),
          );
        }),
      ),
    );
  }

  Widget _rodape(context) {
    //->
    MediaQueryData mediaQuery = MediaQuery.of(context);
    Size size = mediaQuery.size;
    //->
    return Container(
      alignment: Alignment.center,
      // color: Colors.black,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Flexible(
            flex: 1,
            child: Padding(
                padding: EdgeInsets.only(top: 5, left: 5, bottom: 0, right: 5),
                child: Material(
                  elevation: 1,
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AutenticacaoTela()));
                      // AutenticacaoRotas.vaParaAutenticacaoSplash(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.1, vertical: 20),
                      child: Text(
                        _locale.locale[TraducaoStringsConstante.Recusar].toUpperCase(),
                        style: TextStyle(
                          fontSize: 9 * MediaQuery.of(context).textScaleFactor,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )),
          ),
          Flexible(
            flex: 1,
            child: Padding(
                padding: EdgeInsets.only(top: 5, left: 5, bottom: 0, right: 5),
                child: Material(
                  elevation: 1,
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(40),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(40),
                    onTap: () async {

                      SharedPreferences prefs = await SharedPreferences.getInstance();

                      prefs.setString(SharedPreference.USUARIO_AUTENTICADO, true.toString());
                      prefs.setString(SharedPreference.PUSH_NOTIFICATION, true.toString());
                      prefs.setString(SharedPreference.BLOQUEAR_APLICATIVO, false.toString());
                      prefs.setString(SharedPreference.MODO_BACKGROUND, true.toString());
                      prefs.setString(SharedPreference.SENHA_BLOQUEIO, '');

                      await TermoServico().enviaIdOnesignal();

                      Rotas.vaParaEmpresas(context, empresas: widget.empresas);
                      
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.1, vertical: 20),
                      child: Text(
                        _locale.locale[TraducaoStringsConstante.Aceitar].toUpperCase(),
                        style: TextStyle(
                          fontSize: 10 * MediaQuery.of(context).textScaleFactor,
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

  Widget termoDeUso() {
    return Column(
      children: <Widget>[
        Visibility(
          visible: idioma == ConfigIdioma.PORTUGUES_BRASIL,
          child: termoBR(),
        ),
        Visibility(
          visible: idioma == ConfigIdioma.ENGLISH_US,
          child: termoUS(),
        ),
        Visibility(
          visible: idioma == ConfigIdioma.ESPANOL_ESP,
          child: termoDE(),
        ),
        Visibility(
          visible: idioma == ConfigIdioma.DEUTSCH_DE,
          child: termoES(),
        ),
      ],
    );
  }

  Widget termoBR() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'INSTRUMENTO DE ADESÃO, TERMOS E CONDIÇÕES GERAIS DE USO – ${nomeApp.toString().toUpperCase()}',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'Pelo presente instrumento de adesão, reconheço que, sendo eu maior de 18 anos, capaz, ao expressar o aceite eletrônico neste instrumento estou, na qualidade de Usuário do sistema de gerenciamento aceitando todos os termos e condições gerais de uso e todas as demais políticas e princípios que regem o aplicativo $nomeApp.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'A ACEITAÇÃO DESTES TERMOS E CONDIÇÕES GERAIS DE USO É INDISPENSÁVEL À UTILIZAÇÃO DO SISTEMA E SEUS SERVIÇOS.',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '1. O objeto do presente instrumento consiste em estabelecer a política e regulamento para acesso de Usuários ao Aplicativo ${nomeApp.toString().toUpperCase()}. O aplicativo possibilita a visualização de algumas ferramentas do ERP $nomeApp e interação com a ferramenta de ordem de serviço através do aplicativo em um aparelho smartphone.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '2. Para uso dos serviços disponibilizados o Usuário, ao contratar o software junto a $nomeEmpresa, indicará um telefone celular, o qual receberá um código através de sms. O SMS em seu smartphone, é a chave de segurança que permite o acesso ao aplicativo e emitindo comando para funcionamento. Portanto, o Usuário será o único responsável pelas operações efetuadas em sua conta. ',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '3 . O Usuário reconhece que em razão do não bloqueio de tela de seu smartphone, o sistema dispositivo pode ser acionado inesperadamente, isentando a ${nomeApp.toString().toUpperCase()} de qualquer ato praticado (exp. Celular dentro da bolsa, em mãos de terceiros, etc). ',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '4. Para segurança do Usuário, seu login, senha e dados serão transmitidos criptografados (Certificado de Segurança SSL - Secure Socket Layer). Toda informação ou dado pessoal prestado pelo Usuário será armazenado em servidores de alta segurança. A fabricante do software tomará todas as medidas possíveis para manter a confidencialidade e a segurança descrita nesta cláusula, porém não responderá por prejuízo que poderá ser derivado da violação dessas medidas por parte de terceiros que utilizem as redes públicas ou a internet, subvertendo os sistemas de segurança para acessar as informações dos Usuários.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '5. A $nomeApp não  garante a disponibilidade constante e ininterrupta de seu SISTEMA, o qual pode ser afetado pelo sinal da operadora de telefonia móvel, energia elétrica, manutenção, serviço de internet, gestora de dados, por caso fortuito ou força maior.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '6. As informações cedidas pelo Usuário e registradas devido ao uso do SISTEMA poderão ser utilizadas pela fabricante como insumos para customizar cada vez mais os serviços.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '7. Além das informações pessoais fornecidas, a fabricante do software tem a capacidade tecnológica de recolher outras informações técnicas, como o endereço IP de internet do usuário, o sistema operacional do seu telefone, o tipo de browser, etc, podendo utilizar essas informações para si ou para terceiros.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '8. Através do cadastramento, uso e fornecimento de informações à fabricante do software, o Usuário deliberadamente aceita o presente Termo e autoriza a fabricante do software utilizar as informações, inclusive, havendo ordem judicial, transmitir as informações aos órgãos legais.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '9. Este instrumento vigorará por prazo indeterminado, podendo, a critério da $nomeApp, ser alterado, a qualquer tempo, visando seu aprimoramento melhoria dos serviços prestados. Os novos Termos e Condições entrarão em vigor no dia seguinte da publicação no SISTEMA. Todavia, o Usuário, ao acessar o SISTEMA, receberá a nova versão dos Termos e Condições Gerais com uma solicitação de aceite, e caso não concorde com os termos  alterados, o vínculo contratual deixará de existir, desde que não haja nenhuma pendência.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '10. O Usuário declara e garante, para os fins de direito possuir capacidade jurídica para aceitar este TERMO e utilizar os produtos e serviços objeto deste instrumento, declara ainda que leu e está de pleno acordo com todos os termos deste documento.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '11. Para todos os assuntos referentes à interpretação e ao cumprimento deste, as partes se submetem ao Foro da Cidade de Garça/SP.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'O presente encontra-se devidamente registrado no Cartório de Registro de Títulos e Documentos da Comarca de Garça.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget termoUS() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'MEMBERSHIP INSTRUMENT, TERMS AND GENERAL CONDITIONS OF USE - ${nomeApp.toString().toUpperCase()}',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'By this instrument of adhesion, I acknowledge that, being over 18 years old, capable, when expressing the electronic acceptance in this instrument, I am, as User of the management system accepting all general terms and conditions of use and all other policies and principles that govern the $nomeApp application.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'ACCEPTANCE OF THESE GENERAL TERMS AND CONDITIONS OF USE IS INDISPENSABLE TO THE USE OF THE SYSTEM AND ITS SERVICES.',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '1. The purpose of this instrument is to establish the policy and regulation for Users to access the ${nomeApp.toString().toUpperCase()} Application. The application makes it possible to view some ERP $nomeApp tools and interact with the work order tool through the application on a smartphone device.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '2. To use the services provided, the User, when hiring the software with $nomeEmpresa, will indicate a cell phone, which will receive a code via SMS. The SMS on your smartphone is the security key that allows access to the application and issuing a command for operation. Therefore, the User will be solely responsible for the operations carried out on his account.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '3. The User acknowledges that due to the non-blocking of the screen of his smartphone, the device system can be triggered unexpectedly, exempting ${nomeApp.toString().toUpperCase()} from any act practiced (eg Cell phone inside the bag, in the hands of third parties, etc.).',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '4. For User security, your login, password and data will be transmitted encrypted (SSL Security Certificate - Secure Socket Layer). All information or personal data provided by the User will be stored on high security servers. The software manufacturer will take all possible measures to maintain the confidentiality and security described in this clause, but will not be liable for damages that may be caused by the violation of these measures by third parties using public networks or the internet, subverting the information systems. security to access User information.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '5. $nomeApp does not guarantee the constant and uninterrupted availability of its SYSTEM, which may be affected by the signal from the mobile operator, electricity, maintenance, internet service, data management, by chance or force majeure.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '6. The information provided by the User and registered due to the use of the SYSTEM may be used by the manufacturer as inputs to increasingly customize the services.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '7. In addition to the personal information provided, the software manufacturer has the technological capacity to collect other technical information, such as the users Internet IP address, the operating system of your phone, the type of browser, etc., and can use this information to themselves or to third parties.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '8. By registering, using and providing information to the software manufacturer, the User deliberately accepts this Term and authorizes the software manufacturer to use the information, including, in the event of a court order, transmitting the information to Organs legal bodies.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '9. This instrument will remain in force for an indefinite period and, at $nomeApp discretion, may be changed at any time, aiming at improving the services provided. The new Terms and Conditions will come into force on the day after publication in the SYSTEM. However, the User, when accessing the SYSTEM, will receive the new version of the General Terms and Conditions with a request for acceptance, and if he does not agree with the amended terms, the contractual link will cease to exist, as long as there is no pending.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '10. The User declares and guarantees, for the purposes of law, to have legal capacity to accept this TERMS and to use the products and services covered by this instrument, he also declares that he has read and is in full agreement with all the terms of this document.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '11. For all matters relating to its interpretation and compliance, the parties submit themselves to the Forum of the City of Garça / SP.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'The present is duly registered with the Registry of Titles and Documents of the District of Garça.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget termoDE() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'MITGLIEDSCHAFTSINSTRUMENT, ALLGEMEINE GESCHÄFTSBEDINGUNGEN - ${nomeApp.toString().toUpperCase()}',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'Durch dieses Haftungsinstrument erkenne ich an, dass ich mit über 18 Jahren in der Lage bin, als Benutzer des Managementsystems alle allgemeinen Nutzungsbedingungen und alle anderen Richtlinien und Richtlinien zu akzeptieren, wenn ich die elektronische Akzeptanz in diesem Instrument zum Ausdruck bringe Grundsätze für die $nomeApp-Anwendung.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'DIE ANNAHME DIESER ALLGEMEINEN NUTZUNGSBEDINGUNGEN IST FÜR DIE NUTZUNG DES SYSTEMS UND SEINER DIENSTLEISTUNGEN UNVERZICHTBAR.',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '1. Der Zweck dieses Instruments besteht darin, die Richtlinien und Vorschriften für den Zugriff von Benutzern auf die $nomeApp-Anwendung festzulegen. Die Anwendung ermöglicht es, einige ERP $nomeApp-Tools anzuzeigen und über die Anwendung auf einem Smartphone-Gerät mit dem Arbeitsauftragstool zu interagieren.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '2. Um die bereitgestellten Dienste nutzen zu können, gibt der Benutzer beim Mieten der Software bei Fulltime ein Mobiltelefon an, das einen Code per SMS erhält. Die SMS auf Ihrem Smartphone ist der Sicherheitsschlüssel, mit dem Sie auf die Anwendung zugreifen und einen Befehl für den Betrieb ausgeben können. Daher ist der Benutzer allein für die auf seinem Konto ausgeführten Vorgänge verantwortlich.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '3. Der Benutzer erkennt an, dass das Gerätesystem aufgrund der Nichtblockierung des Bildschirms seines Smartphones unerwartet ausgelöst werden kann, wodurch ${nomeApp.toString().toUpperCase()} von allen ausgeübten Handlungen befreit wird (z. B. Mobiltelefon in der Tasche, in den Händen Dritter usw.).',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '4. Aus Gründen der Benutzersicherheit werden Ihr Login, Ihr Passwort und Ihre Daten verschlüsselt übertragen (SSL-Sicherheitszertifikat - Secure Socket Layer). Alle vom Benutzer bereitgestellten Informationen oder persönlichen Daten werden auf Hochsicherheitsservern gespeichert. Der Softwarehersteller ergreift alle möglichen Maßnahmen, um die in dieser Klausel beschriebene Vertraulichkeit und Sicherheit zu gewährleisten, haftet jedoch nicht für Schäden, die sich aus der Verletzung dieser Maßnahmen durch Dritte ergeben, die öffentliche Netzwerke oder das Internet nutzen und die Informationssysteme untergraben. Sicherheit für den Zugriff auf Benutzerinformationen.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '5. $nomeApp garantiert nicht die konstante und ununterbrochene Verfügbarkeit seines SYSTEMS, die durch das Signal des Mobilfunkbetreibers, Strom, Wartung, Internetdienst, Datenverwaltung, durch Zufall oder höhere Gewalt beeinflusst werden kann.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '6. Die vom Benutzer bereitgestellten und aufgrund der Verwendung des SYSTEMS registrierten Informationen können vom Hersteller als Eingaben verwendet werden, um die Dienste zunehmend anzupassen.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '7. Zusätzlich zu den bereitgestellten persönlichen Informationen verfügt der Softwarehersteller über die technologische Kapazität, um andere technische Informationen wie die Internet-IP-Adresse des Benutzers, das Betriebssystem Ihres Telefons, den Browsertyp usw. zu sammeln, und kann diese Informationen verwenden, um selbst oder an Dritte.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '8. Durch die Registrierung, Verwendung und Bereitstellung von Informationen für den Softwarehersteller akzeptiert der Benutzer diese Bedingung absichtlich und ermächtigt den Softwarehersteller, die Informationen zu verwenden, einschließlich der Übermittlung der Informationen an die juristischen Personen im Falle einer gerichtlichen Anordnung.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '9. Dieses Instrument bleibt auf unbestimmte Zeit in Kraft und kann nach Ermessen von $nomeApp jederzeit geändert werden, um die erbrachten Dienstleistungen zu verbessern. Die neuen Allgemeinen Geschäftsbedingungen treten am Tag nach der Veröffentlichung im SYSTEM in Kraft. Wenn der Benutzer jedoch auf das SYSTEM zugreift, erhält er die neue Version der Allgemeinen Geschäftsbedingungen mit einer Aufforderung zur Annahme. Wenn er mit den geänderten Bedingungen nicht einverstanden ist, besteht der vertragliche Link nicht mehr, solange keine ausstehenden Bedingungen bestehen.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '10. Der Benutzer erklärt und garantiert, dass er rechtlich befugt ist, diese BEDINGUNGEN zu akzeptieren und die von diesem Instrument abgedeckten Produkte und Dienstleistungen zu nutzen, und erklärt außerdem, dass er alle Bestimmungen dieses Dokuments gelesen hat und damit einverstanden ist.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '11. Für alle Fragen im Zusammenhang mit ihrer Auslegung und Einhaltung unterwerfen sich die Parteien dem Forum der Stadt Garça / SP.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'Das Geschenk ist ordnungsgemäß im Register der Titel und Dokumente des Bezirks Garça registriert.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget termoES() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'INSTRUMENTO DE MEMBRESÍA, TÉRMINOS Y CONDICIONES GENERALES DE USO - $nomeApp',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'Mediante este instrumento de adhesión, reconozco que, siendo mayor de 18 años, capaz, al expresar la aceptación electrónica en este instrumento, soy, como Usuario del sistema de gestión, aceptando todos los términos y condiciones generales de uso y todas las demás políticas y principios que rigen la aplicación $nomeApp.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'LA ACEPTACIÓN DE ESTOS TÉRMINOS Y CONDICIONES GENERALES DE USO ES INDISPENSABLE AL USO DEL SISTEMA Y SUS SERVICIOS.',
                    style: TextStyle(color: Colors.black, fontSize: 16))
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '1. El propósito de este instrumento es establecer la política y regulación para que los Usuarios accedan a la Aplicación ${nomeApp.toString().toUpperCase()}. La aplicación hace posible ver algunas herramientas ERP $nomeApp e interactuar con la herramienta de orden de trabajo a través de la aplicación en un dispositivo de teléfono inteligente.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '2. Para utilizar los servicios provistos, el Usuario, al contratar el software con Fulltime, indicará un teléfono celular, que recibirá un código por SMS. El SMS en su teléfono inteligente es la clave de seguridad que permite acceder a la aplicación y emitir un comando para la operación. Por lo tanto, el Usuario será el único responsable de las operaciones realizadas en su cuenta.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '3) El usuario reconoce que debido a que no se bloquea la pantalla de su teléfono inteligente, el sistema del dispositivo puede activarse inesperadamente, eximiendo a ${nomeApp.toString().toUpperCase()} de cualquier acto practicado (por ejemplo, teléfono celular dentro de la bolsa, en manos de terceros, etc.).',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '4. Para la seguridad del usuario, su nombre de usuario, contraseña y datos se transmitirán encriptados (Certificado de seguridad SSL - Capa de conexión segura). Toda la información o datos personales proporcionados por el Usuario se almacenarán en servidores de alta seguridad. El fabricante del software tomará todas las medidas posibles para mantener la confidencialidad y seguridad descritas en esta cláusula, pero no será responsable por los daños que puedan ser causados ​​por la violación de estas medidas por parte de terceros que utilizan redes públicas o Internet, subvirtiendo los sistemas de información. seguridad para acceder a la información del usuario.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '5. $nomeApp no garantiza la disponibilidad constante e ininterrumpida de su SISTEMA, que puede verse afectada por la señal del operador móvil, la electricidad, el mantenimiento, el servicio de Internet, la gestión de datos, por casualidad o fuerza mayor.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '6. La información proporcionada por el Usuario y registrada debido al uso del SISTEMA puede ser utilizada por el fabricante como entradas para personalizar cada vez más los servicios.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '7. Además de la información personal proporcionada, el fabricante del software tiene la capacidad tecnológica de recopilar otra información técnica, como la dirección IP de Internet del usuario, el sistema operativo de su teléfono, el tipo de navegador, etc., y puede usar esta información para ellos mismos o a terceros.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '8. Al registrar, usar y proporcionar información al fabricante del software, el Usuario acepta deliberadamente este Término y autoriza al fabricante del software a usar la información, incluida, en caso de una orden judicial, transmitir la información a los organismos legales.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '9. Este instrumento permanecerá en vigencia por un período indefinido y puede, a discreción de FullControl, cambiarse en cualquier momento, con el objetivo de mejorar los servicios prestados. Los nuevos Términos y Condiciones entrarán en vigor el día después de su publicación en el SISTEMA. Sin embargo, el Usuario, al acceder al SISTEMA, recibirá la nueva versión de los Términos y Condiciones Generales con una solicitud de aceptación, y si no está de acuerdo con los términos modificados, el enlace contractual dejará de existir, siempre y cuando no quede pendiente.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '10. El Usuario declara y garantiza, a los efectos de la ley, tener capacidad legal para aceptar estos TÉRMINOS y para utilizar los productos y servicios cubiertos por este instrumento, también declara que ha leído y está totalmente de acuerdo con todos los términos de este documento.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        '11. Para todos los asuntos relacionados con su interpretación y cumplimiento, las partes se someten al Foro de la Ciudad de Garça / SP.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 36),
              children: <TextSpan>[
                TextSpan(
                    text:
                        'El obsequio está debidamente registrado en el Registro de Títulos y Documentos del Distrito de Garça.',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
