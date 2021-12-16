import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:erp/models/relogin.modelo.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/servicos/empresa/empresa.servicos.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/models/diretivas-acesso/diretivas-acesso.modelo.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class SincronizacaoTela extends StatefulWidget {

  final List<Empresa> empresas;
  SincronizacaoTela({Key key, this.empresas}) : super(key: key);

  @override
  _SincronizacaoTelaState createState() => _SincronizacaoTelaState();
  
}

class _SincronizacaoTelaState extends State<SincronizacaoTela> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
   
  Stream<dynamic> _streamEmpresas;
  LocalizacaoServico _locate = new LocalizacaoServico();

  List<Empresa> empresasList = new List<Empresa>();

  _SincronizacaoTelaState() {}

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
    // _streamEmpresas = Stream.fromFuture(_fazRequest());
  }

  @override
  dispose() {
    super.dispose();
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
              appBar: AppBar(
                title: Text(
                  _locate.locale['TituloSelecionaEmpresa'],
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                centerTitle: true,
                leading: Container(),
              ),
              body: _listaEmpresa(),
            );
          }
        ),
      ),
    );
  }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return SemInformacao();
    }

    else if (empresasList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Carregando();
    }

    else if (empresasList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }

    else {
      return Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) =>
          Divider(
            thickness: 2,
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
        return _childStreamConexao(context: context, snapshot: snapshot);
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
}
