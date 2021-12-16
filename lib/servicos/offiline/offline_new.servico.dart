import 'dart:convert';

import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/os/detalhe-os-agendada.modelo.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/models/os/osProximosChamados.modelo.dart';
import 'package:erp/offline/orm_base.dart';
import 'package:erp/servicos/ordem-servico/checklist-servico.servicos.dart';
import 'package:erp/servicos/ordem-servico/material-servico.servicos.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/empresa.modelo.dart' as padrao;
import 'package:erp/provider/db.provider.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/empresa/empresa.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/offiline/offline.modelo.dart';
import 'package:erp/servicos/produto/produto.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';

class OfflineServiceNew {
  RequestUtil _requestUtil = new RequestUtil();
  LocalizacaoServico _locate = LocalizacaoServico();

  final GlobalKey<CarregandoStateLessState> _carregandoKey = GlobalKey<CarregandoStateLessState>();
  

  Future<void> sincronizacaoUpload(BuildContext context) async {
    List<OfflineSalvar> _requisicoesOffline = await DBProvider().checkOfflineSalvar();
    if (_requisicoesOffline.length != 0) {
      // CarregandoAlertaComponente().showCarregar(context);
      await Future.wait([
        _montaRequisicoesUpload(listaDeRequisicoes: _requisicoesOffline)
      ]);
      // CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  Future<List<dynamic>> _montaRequisicoesUpload({@required List<OfflineSalvar> listaDeRequisicoes}) async {
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    bool erro = false;
    listaDeRequisicoes.forEach((element) {
      switch (element.method) {
        case Request.POST:
          dynamic resultado = _requestUtil.postReq(
            endpoint: element.endpoint, data: json.decode(element.object), sincronizacao: true
          );
          requests.add(resultado);
          break;

        case Request.GET:
          dynamic resultado = _requestUtil.getReq(
            endpoint: element.endpoint, data: json.decode(element.object), sincronizacao: true
          );
          requests.add(resultado);
          break;

        case Request.PUT:
          dynamic resultado = _requestUtil.putReq(
            endpoint: element.endpoint, data: json.decode(element.object), sincronizacao: true
          );
          requests.add(resultado);
          break;

        case Request.DELETE:
          dynamic resultado = _requestUtil.deleteReq(
            endpoint: element.endpoint, data: json.decode(element.object), sincronizacao: true
          );
          requests.add(resultado);
          break;

        default:
          dynamic resultado = _requestUtil.postReq(
            endpoint: element.endpoint, data: json.decode(element.object), sincronizacao: true
          );
          requests.add(resultado);
      }
    });
    resultados = await Future.wait(requests);
    if (resultados.length != 0) {
      resultados.forEach((r) {
        if(r == false) {
          erro = true;
        }
      });
    }

    if(erro) {}
    else {
      DBProvider().deleteOfflineSalvar();
    }

    return resultados;
  }

  Future<void> sincronizacaoDownload(BuildContext context) async {
    CarregandoStateLess _carregando = CarregandoStateLess(key: _carregandoKey);
    await _locate.iniciaLocalizacao(context);
    bool confirmacao = await AlertaComponente().showAlertaConfirmacao(
      context: context,
      mensagem: _locate.locale[TraducaoStringsConstante.SincronizacaoConfirmacao]
    );

    if (confirmacao && await _requestUtil.verificaOnline()) {
      // CarregandoAlertaComponente().showCarregarSemTexto(context);
      List<dynamic> resultados = new List<dynamic>();
      showDialog(
        context: context,
        // child: _carregando,
        builder: (context) => _carregando,
      );
      // CarregandoStateLess(key: _carregandoKey,);
      int empresaId = await _requestUtil.obterIdEmpresaShared();
      List<padrao.Empresa> listaEmpresas = new List<padrao.Empresa>();
      dynamic empresasEUsuario = await EmpresaService().listaEmpresas();
      padrao.EmpresaEUsuario empEUser = padrao.EmpresaEUsuario.fromJson(empresasEUsuario);
      listaEmpresas.addAll(empEUser.empresas);
      var resultadosFuture = await Future.wait([
        _sincronizaEmpresaAcessos(empresaId: empresaId, listaEmpresas: listaEmpresas),
        // _sincronizaVendedores(),
        // _sincronizaProdutos(empresaId: empresaId, listaEmpresas: listaEmpresas),
        _sincronizaClientes(empresaId: empresaId, listaEmpresas: listaEmpresas),
        // _sincronizaOSProximosChamados(),
        // _sincronizaOSAgendada(),
        // _sincronizaOSConfig(empresaId: empresaId, listaEmpresas: listaEmpresas),
      ])
        .catchError((e) {
          debugPrint(e.toString());
          // _carregandoKey.currentState.dismissCarregar();
        });
      _carregandoKey.currentState.dismissCarregar();
      if (resultadosFuture != null) {
        resultados.addAll(resultadosFuture);
        debugPrint(resultados.toString());

        for (int i = 0; i < resultados.length; i++) {
          if (resultados[i] == false) {
            AlertaComponente().showAlertaErro(
              localedMessage: true, mensagem: _locate.locale[TraducaoStringsConstante.SincronizacaoErro]
            );
          }
        }
      }
        // .catchError((e) => AlertaComponente().showAlertaErro(
        //   localedMessage: true, mensagem: _locate.locale[TraducaoStringsConstante.SincronizacaoErro]
        // ));
      // CarregandoAlertaComponente().dismissCarregar(context);
    }
  }

  Future<bool> _sincronizaEmpresaAcessos({int empresaId, List<padrao.Empresa> listaEmpresas}) async {
    bool retorno = false;
    // await EmpresaService().downloadTodosAcessosEmpresa(empresaId);

    // listaEmpresas.forEach((empresa) async {
    //   var resultado = await EmpresaService().downloadTodosAcessosEmpresa(empresa.id);
    //   _listaDeRequests.add(resultado);
    // });

    dynamic resultado = await EmpresaService().downloadTodosAcessosEmpresa(listaEmpresas);
    if (resultado.length != 0) {
      await EmpresaAcessosProvider().deleteAllEmpresaAcesso();
      retorno = await EmpresaAcessosProvider().insertEmpresasAcessosBatch(resultado);
    }
    return retorno;
  }

  Future<bool> _sincronizaVendedores() async {
    bool retorno = false;
    // await VendedoresService().downloadTodosVendedoresEmpresa(empresaId);

    // listaEmpresas.forEach((empresa) async {
    //   await VendedoresService().downloadTodosVendedoresEmpresa(empresa.id);
    // });

    List<VendedoresLookUp> vendedores = await VendedoresService().downloadTodosVendedores();
    if (vendedores.length != 0) {
      await VendedorLookupProvider().deleteAllVendedor();
      retorno = await VendedorLookupProvider().insertVendedoresBatch(vendedores);
    }
    return retorno;
  }

  // Future<bool> _sincronizaProdutos({int empresaId, List<Empresa> listaEmpresas}) async {
  //   bool retorno = false;
  //   // await ProdutoService().downloadTodosProdutosEmpresa(empresaId);

  //   // listaEmpresas.forEach((empresa) async {
  //   //   await ProdutoService().downloadTodosProdutosEmpresa(empresa.id);
  //   // });

  //   dynamic resultado = await ProdutoService().downloadTodosProdutosEmpresa(listaEmpresas);
  //   if (resultado.length != 0) {
  //     await ProdutoLookupProvider().deleteAllProduto();
  //     retorno = await ProdutoLookupProvider().insertProdutosBatch(resultado, listaEmpresas);
  //   }
  //   return retorno;
  // }

  Future<void> _sincronizaClientes({int empresaId, List<padrao.Empresa> listaEmpresas}) async {
    bool retorno = false;
    // await ClienteService().downloadTodosClientesEmpresa(empresaId);

    // listaEmpresas.forEach((empresa) async {
    //   await ClienteService().downloadTodosClientesEmpresa(empresa.id);
    // });

    dynamic resultado = await ClienteService().downloadTodosClientesEmpresa(listaEmpresas);
    if (resultado.length != 0) {
      // await ClienteLookupProvider().deleteAllCliente();

      retorno = await insertClientesBatch(resultado, listaEmpresas);
    }
    return retorno;
  }

  List<List<ClienteLookup>> _converteListaEmpresas(List<dynamic> lista, List<padrao.Empresa> empresas){
    List<List<ClienteLookup>> _resultado = new List<List<ClienteLookup>>();

    for(int i = 0; i < empresas.length; i++) {
      List<ClienteLookup> _listaClientes = new List<ClienteLookup>();
      int empresaId = empresas[i].id;
      lista[i].forEach((cliente) {
        cliente['empresaId'] = empresaId;
        _listaClientes.add(ClienteLookup.fromJson(cliente));
      });
      _resultado.add(_listaClientes);
    }

    return _resultado;
  }

  Future<bool> insertClientesBatch(List<dynamic> clientes, List<padrao.Empresa> empresas) async {
    List<List<ClienteLookup>> clientesEmpresa = _converteListaEmpresas(clientes, empresas);

    // clientesEmpresa.forEach((element) {});

    for(int i = 0; i < clientesEmpresa.length; i++) {
      int quantidade = clientesEmpresa[i].length;
      List<Cliente> clientesAdicionar = new List<Cliente>();
      clientesEmpresa[i].forEach((e) async {
        Cliente novoCliente = new Cliente();
        novoCliente.apiId = e.id;
        novoCliente.nome_razaosocial = e.nome;
        novoCliente.nomeFantasia = e.nomeFantasia;
        novoCliente.empresaId = e.empresaId;
        clientesAdicionar.add(novoCliente);
        // await novoCliente.save();
      });
      var results = await Cliente.saveAll(clientesAdicionar);
    }

    return true;
  }

  Future<bool> _sincronizaOSProximosChamados() async {
    bool retorno = false;

    List<OsProximosChamados> proximosChamados = await OrdemServicoService().downloadTodosProximosChamados();
    if (proximosChamados.length != 0) {
      await OrdemServicoProximosChamadosProvider().deleteAllProximosChamados();
      retorno = await OrdemServicoProximosChamadosProvider().insertOSProximosChamadosBatch(proximosChamados);
    }
    return retorno;
  }

  Future<bool> _sincronizaOSAgendada() async {
    bool retorno = false;

    List<GridOSAgendadaModelo> osAgendadas = await OrdemServicoService().downloadTodasOSAgendadas();
    if (osAgendadas.length != 0) {
      await OrdemServicoAgendadaProvider().deleteAllOSAgendada();
      retorno = await OrdemServicoAgendadaProvider().insertOSAgendadaBatch(osAgendadas);
      await Future .wait([
        _sincronizaOSAgendadaDetalhes(osAgendadas: osAgendadas),
        _sincronizaOSConfigMaterial(osAgendada: osAgendadas),
        _sincronizaCheckListOS(osAgendada: osAgendadas),
        _sincronizaMaterialServicoOS(osAgendada: osAgendadas),
      ]);
    }
    return retorno;
  }

  Future<bool> _sincronizaOSAgendadaDetalhes({List<GridOSAgendadaModelo> osAgendadas}) async {
    bool retorno = false;

    // List<GridOSAgendadaModelo> osAgendadas = ;
    List<DetalheOSAgendada> osAgendadasDetalhes = await OrdemServicoService().downloadTodasOSAgendadaDetalhes(osAgendadas);
    if (osAgendadasDetalhes.length != 0) {
      await OrdemServicoAgendadaDetalhesProvider().deleteAllDetalhesOS();
      retorno = await OrdemServicoAgendadaDetalhesProvider().insertDetalhesOSBatch(osAgendadasDetalhes);
    }
    return retorno;
  }

  // Future<bool> _sincronizaOSConfig({int empresaId, List<Empresa> listaEmpresas}) async {
  //   bool retorno = false;
  //   // await EmpresaService().downloadTodosAcessosEmpresa(empresaId);

  //   // listaEmpresas.forEach((empresa) async {
  //   //   var resultado = await EmpresaService().downloadTodosAcessosEmpresa(empresa.id);
  //   //   _listaDeRequests.add(resultado);
  //   // });

  //   dynamic resultado = await OrdemServicoService().downloadTodasOsConfig(listaEmpresas);
  //   if (resultado.length != 0) {
  //     await OrdemServicoGetOSConfigProvider().deleteAllgetOSConfig();
  //     retorno = await OrdemServicoGetOSConfigProvider().insertGetOSConfigBatch(resultado, listaEmpresas);
  //   }
  //   return retorno;
  // }

  Future<bool> _sincronizaOSConfigMaterial({List<GridOSAgendadaModelo> osAgendada}) async {
    bool retorno = false;
    // await EmpresaService().downloadTodosAcessosEmpresa(empresaId);

    // listaEmpresas.forEach((empresa) async {
    //   var resultado = await EmpresaService().downloadTodosAcessosEmpresa(empresa.id);
    //   _listaDeRequests.add(resultado);
    // });

    List<OSConfigMaterial> resultado = await OrdemServicoService().downloadTodasOsConfigMaterial(osAgendada);
    if (resultado.length != 0) {
      await OrdemServicoGetOSConfigMaterialProvider().deleteAllgetOSConfigMaterial();
      retorno = await OrdemServicoGetOSConfigMaterialProvider().insertGetOSConfigMaterialBatch(resultado, osAgendada);
    }
    return retorno;
  }

  Future<bool> _sincronizaCheckListOS({List<GridOSAgendadaModelo> osAgendada}) async {
    bool retorno = false;
    // await EmpresaService().downloadTodosAcessosEmpresa(empresaId);

    // listaEmpresas.forEach((empresa) async {
    //   var resultado = await EmpresaService().downloadTodosAcessosEmpresa(empresa.id);
    //   _listaDeRequests.add(resultado);
    // });

    dynamic resultado = await ChecklistService().downloadTodasOsConfigMaterial(osAgendada: osAgendada);
    if (resultado.length != 0) {
      await CheckListOSProvider().deleteAllCheckListOS();
      retorno = await CheckListOSProvider().insertChecklistOSBatch(resultado, osAgendada);
    }
    return retorno;

    // List<dynamic> resultado = await OrdemServicoService().downloadTodasOsConfigMaterial(osAgendada);
    // if (resultado.length != 0) {
    //   await OrdemServicoGetOSConfigMaterialProvider().deleteAllgetOSConfigMaterial();
    //   retorno = await OrdemServicoGetOSConfigMaterialProvider().insertGetOSConfigMaterialBatch(resultado, osAgendada);
    // }
    // return retorno;
  }

  Future<bool> _sincronizaMaterialServicoOS({List<GridOSAgendadaModelo> osAgendada}) async {
    bool retorno = false;

    dynamic resultado = await MarterialServicoService().downloadTodosMaterialServico(osAgendada: osAgendada);
    if (resultado.length != 0) {
      await MateriaisServicosProvider().deleteAllMaterialServico();
      retorno = await MateriaisServicosProvider().insertProdutosBatch(resultado, osAgendada);
    }
    return retorno;
  }
}
