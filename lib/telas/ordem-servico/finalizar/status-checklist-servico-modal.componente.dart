import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/models/os/grid-finalizacao-servico-x-checklist.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:erp/utils/request.util.dart';
import 'package:provider/provider.dart';

class StatusCheckListServicoModalComponente extends StatefulWidget {
  final int osXTecXServId;
  final int osXMatId;
  final int osXTecId;

  StatusCheckListServicoModalComponente({Key key, this.osXTecXServId, this.osXMatId, this.osXTecId}) : super(key: key);

  @override
  _StatusCheckListServicoModalComponenteState createState() => _StatusCheckListServicoModalComponenteState();
}

class _StatusCheckListServicoModalComponenteState extends State<StatusCheckListServicoModalComponente> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamCheckServico;
  List<GridFinalizacaoServicoXCheckListModelo> _chekServicosList = new List<GridFinalizacaoServicoXCheckListModelo>();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamCheckServico = Stream.fromFuture(_fazRequest());
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestCheckListServicos = await OrdemServicoService().getGridFinalizacaoServicoXCheckList(
      osXTecXServId: widget.osXTecXServId,
      osXMatId: widget.osXMatId,
      osXTecId: widget.osXTecId
    );

    requestCheckListServicos.forEach((data) {
      _chekServicosList.add(GridFinalizacaoServicoXCheckListModelo.fromJson(data));
    });

    return _chekServicosList;
  }

  @override
  Widget build(BuildContext context) {
     bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale[TraducaoStringsConstante.ServicosExecutados]),
            ),
            body: CustomOfflineWidget(
              child: StreamBuilder(
                stream: _streamCheckServico,
                builder: (context, snapshot) {
                  return _childStreamConexao(snapshot: snapshot);
                }
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }
  Widget _childStreamConexao({@required AsyncSnapshot snapshot}) {
    if (snapshot.hasError) {
      return Container();
    }
    // else if (_servicosVinculadosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
    //   return Carregando();
    // }
    else if (_chekServicosList.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
      return Container();
    }
    else if (_chekServicosList.isEmpty && snapshot.connectionState == ConnectionState.done) {
      return Container();
    }
    // else if (_servicosVinculadosList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
    //   return SemInformacao();
    // }
    else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (BuildContext context, int index) =>
          Divider(thickness: 2,height: 0,),
          itemBuilder: (context, index) {
            return _listaServicosVinculados(context, index, _chekServicosList[index]);
          },
          itemCount: _chekServicosList.length,
        ),
      );
    }
  }

  Widget _listaServicosVinculados(BuildContext context, index, GridFinalizacaoServicoXCheckListModelo itemServico) {
    bool _retornaStatusServico(int statusNumero) {
      switch (statusNumero) {
        case 0:
          return false;
          break;
        case 1:
          return true;
          break;
        default:
          return true;
          break;
      }
    }

    int _alteraStatusServico(bool status) {
      if (status == true) {
        return 1;
      }
      else {
        return 0;
      }
    }

    return InkWell(
      onTap: () {},
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Flexible(
                child: Checkbox(
                  value: _retornaStatusServico(itemServico.status),
                  onChanged: (bool status) async {
                    AtualizarStatusCheckXServicoModelo atualizaStatusObjeto = new AtualizarStatusCheckXServicoModelo();
                    Data dataAtualizacao = new Data();
                    atualizaStatusObjeto.data = dataAtualizacao;

                    atualizaStatusObjeto.status = _alteraStatusServico(status);
                    atualizaStatusObjeto.data.id = itemServico.id;
                    atualizaStatusObjeto.data.descricao = itemServico.descricao;
                    atualizaStatusObjeto.data.obrigatorio = itemServico.obrigatorio;
                    atualizaStatusObjeto.data.osxTecXServId = itemServico.osxTecXServId;
                    atualizaStatusObjeto.data.servCheckListId = itemServico.servCheckListId;
                    atualizaStatusObjeto.data.status = itemServico.status;

                    String atualizaStatusObjetoJson = json.encode(atualizaStatusObjeto.toJson());
                    if(!await RequestUtil().verificaOnline()) {
                      bool resposta = await OrdemServicoService().atualizarStatusCheckXServico(
                        context: context,
                        checkServico: atualizaStatusObjetoJson
                      );
                      if (resposta) {
                        setState(() {
                          itemServico.status = _alteraStatusServico(status);
                        });
                      }
                    }
                    else {
                      Response resposta = await OrdemServicoService().atualizarStatusCheckXServico(
                        context: context,
                        checkServico: atualizaStatusObjetoJson
                      );

                      if (resposta.statusCode == 200) {
                        setState(() {
                          itemServico.status = _alteraStatusServico(status);
                        });
                      }
                    }
                  }
                ),
              ),
              Flexible(
                flex: 10,
                child: Texto(itemServico.descricao + (itemServico.obrigatorio == 1 ? (' - ' + _locate.locale[TraducaoStringsConstante.Obrigatorio]) : ''))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
