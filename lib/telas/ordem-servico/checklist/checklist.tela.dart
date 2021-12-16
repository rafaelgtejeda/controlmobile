import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/os/atualizar-checklist-os-grid.modelo.dart';
import 'package:erp/models/os/checklist-os-grid.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/rotas/ordem-servico.rotas.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/servicos/ordem-servico/checklist-servico.servicos.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/utils/screen_util.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class ChecklistOSTela extends StatefulWidget {
  final int osId;
  final int osXTecId;
  const ChecklistOSTela({Key key, this.osId, this.osXTecId}) : super(key: key);

  @override
  _ChecklistOSTelaState createState() => _ChecklistOSTelaState();
}

class _ChecklistOSTelaState extends State<ChecklistOSTela> {
  LocalizacaoServico _locale = new LocalizacaoServico();
  List<ChecklistOSGrid> _checklistList = new List<ChecklistOSGrid>();
  MediaQueryData _media = MediaQueryData();

  int osID;
  int _totalPendente = 0;

  Stream<dynamic> _streamCL;

  Helper helper = new Helper();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    osID = widget.osId;
    _locale.iniciaLocalizacao(context);
    _streamCL = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestCheckLists = await ChecklistService().getChecklistServico(osId: widget.osId);
    List<ChecklistOSGrid> listaCheckList = new List<ChecklistOSGrid>();
    requestCheckLists.forEach((data) {
      listaCheckList.add(ChecklistOSGrid.fromJson(data));
    });
    _checklistList.addAll(listaCheckList);
    setState(() {
      _totalPendente = _checklistList.length;
    });
    return _checklistList;
  }

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();

    Timer(const Duration(seconds: 2), () {
      completer.complete();
    });

    setState(() {
      _checklistList.clear();
    });
    _streamCL = Stream.fromFuture(_fazRequest());

    return completer.future.then<void>((_) {
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: const Text('Refresh complete'),
          action: SnackBarAction(
              label: 'RETRY',
              onPressed: () {
                _refreshIndicatorKey.currentState.show();
              })));
    });
  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    _media = MediaQuery.of(context);
    return LocalizacaoWidget(
      exibirOffline: true,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              elevation: 0,
              title: Text(_locale.locale['CheckList'].toUpperCase()),
            ),
            // body: _getChecklist(),
            body: _listagemCheckList(),
            bottomNavigationBar: _isOnline
              ? _painelRodape()
              : Container(
                height: _media.size.width > 500 ? (_media.size.height * 0.4 + 40) : (_media.size.height * 0.275 + 40),
                child: ListView(
                  children: <Widget>[
                    _painelRodape(),
                    OfflineMessageWidget()
                  ],
                ),
              ),
          );
        },
      ),
    );
  }

  Widget _painelRodape() {
    return Container(
      height: _media.size.width > 500 ? _media.size.height * 0.4 : _media.size.height * 0.275,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: MediaQuery.of(context).copyWith().size.width / 1,
                  color: Colors.grey[300],
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      '${_locale.locale[TraducaoStringsConstante.ChecklistCompletarParte1]} $_totalPendente ${_locale.locale[TraducaoStringsConstante.ChecklistCompletarParte2]}'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                )
              ),
            ],
          ),
          Flexible(
            flex: 1,
            child: FadeInUp(3, _btnComSucesso())
            // child: FadeInUp(3, _botao())
          ),
          Flexible(
            flex: 1,
            child: FadeInUp(4, _btnSemSucesso())
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  Future<bool> _atualizarOSCheckList() async {
    bool resultado;
    AtualizarChecklistOSGrid _atualizaOSCheckList = new AtualizarChecklistOSGrid();
    String _checkListAtualizadaJson = '';
    _atualizaOSCheckList.osId = widget.osId;
    _atualizaOSCheckList.itens = _converteCheckList();
    _checkListAtualizadaJson = json.encode(_atualizaOSCheckList.toJson());
    if(!await RequestUtil().verificaOnline()) {
      bool resposta = await OrdemServicoService().atualizarCheckListOS(checklist: _checkListAtualizadaJson, context: context);
      resultado = resposta;
    }
    else {
      Response resposta = await OrdemServicoService().atualizarCheckListOS(checklist: _checkListAtualizadaJson, context: context);

      if(resposta.statusCode == 200) resultado = true;
      else resultado = false;
    }
    return resultado;
  }

  List<Itens> _converteCheckList() {
    List<Itens> itensCheckList = new List<Itens>();
    _checklistList.forEach((element) {
      Itens item = new Itens();
      item.id = element.id;
      item.status = element.status;
      itensCheckList.add(item);
    });
    return itensCheckList;
  }

  Future<bool> _verificaCheckLists() async {
    bool resultado = true;
    for (int i = 0; i < _checklistList.length; i++) {
      if(_checklistList[i].status == false) {
        resultado = false;
        break;
      }
    }
    return resultado;
  }

  Widget _botao({Color color, double height = 48, String texto, Function funcao}) {
    return Padding(
      // padding: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: _media.size.width > 350 ? 24 : 12
      ),
      child: Material(
        elevation: 5,
        color: color,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: height,
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Image.asset(AssetsIconApp.CheckWhite, width: 20,),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      texto.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _media.size.height > 350 ? 14 : 8
                      ),
                    ),
                  )
                ],
              ),
            ),
            onTap: funcao,
          ),
        ),
      ),
    );
  }

  Widget _btnComSucesso() {
    return _botao(
      texto: _locale.locale[TraducaoStringsConstante.FinalizarComSucesso],
      color: Colors.green,
      funcao: () async {
        if (await _verificaCheckLists() == true) {
          if (await _atualizarOSCheckList() == true) {
            OSConfig osConfig = new OSConfig();
            dynamic getOSConfig = await OrdemServicoService().getOSConfig(context: context);
            osConfig = OSConfig.fromJson(getOSConfig);
            OrdemServicoRotas.vaParaFinalizacaoOS(
              context: context,
              osId: osID,
              status: StatusOrdemDeServico.FinalizacaoTecnico,
              osXTecId: widget.osXTecId,
              osConfig: osConfig,
            );
          }
        }
        else {
          _showSnackBar(_locale.locale[TraducaoStringsConstante.FinalizarTodasTarefas]);
        }
      },
    );
  }

  // Widget _btnComSucesso() {
  //   return ButtonComponente(
  //       texto: '${_locale.locale['FinalizarComSucesso']}',
  //       imagemCaminho: AssetsIconApp.CheckWhite,
  //       backgroundColor: Colors.green,
  //       textColor: Colors.white,
  //       somenteTexto: false,
  //       somenteIcone: false,
  //       ladoIcone: 'Esquerdo',
  //       funcao: () async {
  //         if (await _verificaCheckLists() == true) {
  //           if (await _atualizarOSCheckList() == true) {
  //             OSConfig osConfig = new OSConfig();
  //             dynamic getOSConfig = await OrdemServicoService().getOSConfig(context: context);
  //             osConfig = OSConfig.fromJson(getOSConfig);
  //             OrdemServicoRotas.vaParaFinalizacaoOS(
  //               context: context,
  //               osId: osID,
  //               status: StatusOrdemDeServico.FinalizacaoTecnico,
  //               osXTecId: widget.osXTecId,
  //               osConfig: osConfig,
  //             );
  //           }
  //         }
  //         else {
  //           _showSnackBar(_locale.locale[TraducaoStringsConstante.FinalizarTodasTarefas]);
  //         }
  //       });
  // }

  Widget _btnSemSucesso() {
    return _botao(
      texto: _locale.locale[TraducaoStringsConstante.FinalizarSemSucesso],
      color: Colors.blue,
      funcao: () async {
        if (await _verificaCheckLists() == true) {
          if (await _atualizarOSCheckList() == true) {
            OSConfig osConfig = new OSConfig();
            dynamic getOSConfig = await OrdemServicoService().getOSConfig(context: context);
            osConfig = OSConfig.fromJson(getOSConfig);
            OrdemServicoRotas.vaParaFinalizacaoOS(
              context: context,
              osId: osID,
              status: StatusOrdemDeServico.FinalizacaoSemSucessoTecnico,
              osXTecId: widget.osXTecId,
              osConfig: osConfig,
            );
          }
        }
        else {
          _showSnackBar(_locale.locale[TraducaoStringsConstante.FinalizarTodasTarefas]);
        }
      },
    );
  }

  // Widget _btnSemSucesso() {
  //   return ButtonComponente(
  //       texto: '${_locale.locale['FinalizarSemSucesso']}',
  //       imagemCaminho: AssetsIconApp.CheckWhite,
  //       backgroundColor: Colors.blue,
  //       textColor: Colors.white,
  //       somenteTexto: false,
  //       somenteIcone: false,
  //       ladoIcone: 'Esquerdo',
  //       funcao: () async {
  //         if (await _verificaCheckLists() == true) {
  //           if (await _atualizarOSCheckList() == true) {
  //             OSConfig osConfig = new OSConfig();
  //             dynamic getOSConfig = await OrdemServicoService().getOSConfig(context: context);
  //             osConfig = OSConfig.fromJson(getOSConfig);
  //             OrdemServicoRotas.vaParaFinalizacaoOS(
  //               context: context,
  //               osId: osID,
  //               status: StatusOrdemDeServico.FinalizacaoSemSucessoTecnico,
  //               osXTecId: widget.osXTecId,
  //               osConfig: osConfig,
  //             );
  //           }
  //         }
  //         else {
  //           _showSnackBar(_locale.locale[TraducaoStringsConstante.FinalizarTodasTarefas]);
  //         }
  //       });
  // }

  Widget _childStreamConexao({@required BuildContext context, @required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (checklistList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (_checklistList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
      return SemInformacao();
    }
    else {
      return ListView.builder(
        shrinkWrap: true,
        controller: new ScrollController(),
        itemBuilder: (context, index) {
          return _checkListItem(context, index, _checklistList);
        },
        itemCount: _checklistList.length,
      );
    }
  }

  Widget _listagemCheckList() {
    return StreamBuilder(
      stream: _streamCL,
      builder: (context, snapshot) {
        return ListView(
          children: <Widget>[
            _childStreamConexao(context: context, snapshot: snapshot),
          ],
        );
      },
    );
  }

  Widget _checkListItem(BuildContext context, int index, List<ChecklistOSGrid> lista) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          Checkbox(
            value: lista[index].status,
            onChanged: (bool status){
              setState(() {
                lista[index].status = status;
              });
              if(status == true) {
                setState(() {
                  _totalPendente -= 1;
                });
              }
              else {
                setState(() {
                  _totalPendente += 1;
                });
              }
            }
          ),
          Texto(lista[index].descricao),
        ],
      ),
    );
  }
}
