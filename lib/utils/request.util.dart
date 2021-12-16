import 'dart:io';
import 'package:dio/dio.dart';
import 'package:erp/models/os/detalhe-os-agendada.modelo.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/models/os/material-servico.modelo.dart';
import 'package:erp/models/os/os-config.modelo.dart';
import 'package:erp/models/os/osProximosChamados.modelo.dart';
import 'package:erp/servicos/offiline/offline.servico.dart';
import 'package:erp/servicos/ordem-servico/checklist-servico.servicos.dart';
import 'package:erp/servicos/ordem-servico/material-servico.servicos.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info/device_info.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/diretivas-acesso/diretivas-acesso.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/provider/db.provider.dart';

import 'package:erp/provider/lookup.offline.db.provider.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/empresa/empresa.servicos.dart';
import 'package:erp/servicos/produto/produto.servicos.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/provider/empresa.db.provider.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/compartilhados/componentes/alerta/alerta.componente.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class RequestUtil {
  
  Dio dio = new Dio(BaseOptions(
    connectTimeout: 50000,
    receiveTimeout: 30000,
    baseUrl: Request.BASE_URL

  ));
  Dio tokenDio = new Dio(BaseOptions(
    connectTimeout: 50000,
    receiveTimeout: 30000,
    baseUrl: Request.BASE_URL
  ));

  Response response = new Response();
  Response response2 = new Response();

  var connectivityResult;
  bool _estaOnline = false;

  var _playerId;

  String baseURL = Request.BASE_URL;

  int empresaId;
  int registroId;
  int usuarioId;
  List<String> contasId = new List<String>();

  String dataInicial;
  String dataFinal;
  String uuidSP;

  String token;
  String dataExpiracaoToken;
  // DateTime dataAtual = new DateTime.now().toUtc().subtract(Duration(hours: 1));
  // DateTime dataAtual = new DateTime.now().toUtc().subtract(Duration(hours: 3));
  DateTime dataAtual = new DateTime.now();
  // DateTime dataAtual = new DateTime.now().toUtc();

  String ddi;
  String telefone;
  String codigoAtivacao;
  String idioma;
  String model;

  bool _isloading = false;

  Future<bool> verificaOnline() async {
    return await ConnectivityWrapper.instance.isConnected;
  }
  
  Future<dynamic> _carregaConfigs() async {
    // dio.options.connectTimeout = 120000;
    // dio.options.receiveTimeout = 30000;
    // dio.options.baseUrl = baseURL;

    tokenDio.options = dio.options;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = prefs.getString(SharedPreference.TOKEN);
    dataExpiracaoToken = prefs.getString(SharedPreference.TOKEN_DATA_EXPIRACAO);

    ddi = prefs.getString(SharedPreference.DDI);
    telefone = prefs.getString(SharedPreference.TELEFONE);
    codigoAtivacao = prefs.getString(SharedPreference.CODIGO);
    idioma = prefs.getString(SharedPreference.IDIOMA);

    _estaOnline = await verificaOnline();

    _verificaTokenExpirado();
  }

  _verificaTokenExpirado() async {
    // if (dataAtual.isAfter(DateTime.parse(dataExpiracaoToken).toUtc())) {
    // if (dataAtual.toUtc().isAfter(DateTime.parse(dataExpiracaoToken).toUtc())) {
    if (dataAtual.toUtc().isAfter(DateTime.parse(dataExpiracaoToken))) {
    // if (dataAtual.isAfter(DateTime.parse(dataExpiracaoToken).toUtc().add(Duration(hours: 1)))) {

      if (_estaOnline) {
        response2 = await _requestoken();
        _armezenaDadosToken();
      }
    }
  }

  getUUID() async {
    var uuid = Uuid();
    return uuid.v4();
  }

  Future<String> getDeviceModel() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"
      model = androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"s
      model = iosInfo.utsname.machine;
    }

    return model;
  }

  Future<int> obterIdEmpresaShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    empresaId = prefs.getInt(SharedPreference.EMPRESA_ID);
    return empresaId;
  }

  Future<int> obterIdRegistroShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    registroId = prefs.getInt(SharedPreference.REGISTRO_ID);
    return registroId;
  }

  Future<int> obterIdUsuarioSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getInt(SharedPreference.USUARIO_ID);
    return usuarioId;
  }

  Future<String> obterIdPlayerOneSignal() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();
    return _playerId = status.subscriptionStatus.userId;
  }

  Future<List<String>> obterIdsContasSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contasString = new List<String>();
    if (prefs.getStringList(SharedPreference.CONTAS_SELECIONADAS) != null) {
      contasString = prefs.getStringList(SharedPreference.CONTAS_SELECIONADAS);
    }
    if (contasString.isNotEmpty) {
      contasString.forEach((contaId) {
        contasId.add(contaId);
      });
    }
    return contasId;
  }

  Future<String> obterDataInicialSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dataInicial = prefs.getString(SharedPreference.DATA_INICIAL);
    return dataInicial;
  }

  Future<String> obterDataFinalSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dataFinal = prefs.getString(SharedPreference.DATA_FINAL);
    return dataFinal;
  }

  Future<String> obterUUIDSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uuidSP =  prefs.getString(SharedPreference.UUID);
    return uuidSP;
  }

  Future<String> obterUUID() async {

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }

  }

  _armezenaDadosToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(SharedPreference.TOKEN, response2.data['entidade']['token']);
    prefs.setString(SharedPreference.TOKEN_DATA_CRIACAO, response2.data['entidade']['dataCriacao']);
    prefs.setString(SharedPreference.TOKEN_DATA_EXPIRACAO, response2.data['entidade']['dataExpiracao']);
    
  }

  Future<Response<dynamic>> _requestoken() async {
    return await tokenDio.get("Account/Token", queryParameters: {
      "DDI": ddi,
      "Telefone": telefone,
      "CodigoAtivacao": codigoAtivacao,
      "idioma": idioma,
    });
  }

  _offline(endpoint, parameters, responseData, {bool ignorarArmazenamentoAutomatico = false}) async {

    // return (response as List).map((empresa) {
    //   print('Inserting $empresa');
    //   EmpresaDBProvider.db
    //       .createEmpresa(idEmpresa, Empresa.fromJson(empresa));
    // }).toList();

    int empresa = await obterIdEmpresaShared();

    switch (endpoint) {
      case Endpoints.GRID_OS_PRXIMOS_CHAMADOS:
        if (!ignorarArmazenamentoAutomatico) {
          List<OsProximosChamados> proximosChamados = new List<OsProximosChamados>();
          responseData.forEach((proximoChamado) => proximosChamados.add(OsProximosChamados.fromJson(proximoChamado)));
          bool resultado = await OrdemServicoProximosChamadosProvider().insertOSProximosChamadosBatch(proximosChamados);
        }
        break;
        
      case Endpoints.GRID_OS_AGENDADA:
        if (!ignorarArmazenamentoAutomatico) {
          List<GridOSAgendadaModelo> osAgendadaList = new List<GridOSAgendadaModelo>();
          responseData.forEach((osAgendada) => osAgendadaList.add(GridOSAgendadaModelo.fromJson(osAgendada)));
          bool resultado = await OrdemServicoAgendadaProvider().insertOSAgendadaBatch(osAgendadaList);
        }
        break;

      case Endpoints.DETALHE_OS_AGENDADA:
        if (!ignorarArmazenamentoAutomatico) {
          List<DetalheOSAgendada> osAgendadaDetalhesList = new List<DetalheOSAgendada>();
          osAgendadaDetalhesList.add(DetalheOSAgendada.fromJson(responseData));
          
          bool resultado = await OrdemServicoAgendadaDetalhesProvider().insertDetalhesOSBatch(osAgendadaDetalhesList);
        }
        break;

      case Endpoints.GET_OS_CONFIG:
        if (!ignorarArmazenamentoAutomatico) {
          List<OSConfig> osAgendadaDetalhesList = new List<OSConfig>();
          // responseData.forEach((osAgendada) => osAgendadaDetalhesList.add(OSConfig.fromJson(osAgendada)));
          dynamic resultado = await OrdemServicoGetOSConfigProvider().insertGetOSConfig(osConfig: responseData, empresaId: empresaId);
        }
        break;

      case Endpoints.GRID_MATERIAL:

        if (!ignorarArmazenamentoAutomatico) {
          // List<MaterialServicoGrid> produtos = new List<MaterialServicoGrid>();
          // responseData['lista'].forEach((produto) {
          //   produto['osId'] = parameters['osId'];
          //   produtos.add(Produto.fromJson(produto));
          // });
          MaterialServicoGrid produtos = MaterialServicoGrid.fromJson(responseData);
          produtos.sumario.osId = parameters['osId'];
          produtos.lista.forEach((element) {
            element.osId = parameters['osId'];
          });
          // responseData['lista'].forEach((produto) {
          //   produto['osId'] = parameters['osId'];
          //   produtos.add(Produto.fromJson(produto));
          // });
          bool resultado =  await MateriaisServicosProvider().insertProdutosBatchSingular(produtos);
        }
        
        break;

      case Endpoints.GRID_CHECKLISTS_OS:
        if (!ignorarArmazenamentoAutomatico) {
          List<OSConfigMaterial> osAgendadaDetalhesList = new List<OSConfigMaterial>();
          // responseData.forEach((osAgendada) => osAgendadaDetalhesList.add(OSConfig.fromJson(osAgendada)));
          dynamic resultado = await CheckListOSProvider().insertCheckListOS(listaCheckListJson: responseData, osId: parameters['osId']);
        }
        break;

      case Endpoints.GET_OS_CONFIG_MATERIAL:
        if (!ignorarArmazenamentoAutomatico) {
          List<OSConfigMaterial> osAgendadaDetalhesList = new List<OSConfigMaterial>();
          // responseData.forEach((osAgendada) => osAgendadaDetalhesList.add(OSConfig.fromJson(osAgendada)));
          dynamic resultado = await OrdemServicoGetOSConfigMaterialProvider().insertGetOSConfigMaterial(osConfigMaterial: responseData, osId: parameters['id']);
        }
        break;

      case Endpoints.EMPRESA_ACESSOS:
        // Insere Diretivas no banco de dados via batching
        // List<DiretivasAcessoModelo> diretivas = new List<DiretivasAcessoModelo>();
        // responseData.forEach((diretiva) => diretivas.add(DiretivasAcessoModelo.fromJson(diretiva)));
        
        // Insere Diretivas normalmente no banco de dados, sem batching
        
        // return await EmpresaAcessosProvider().insertEmpresaAcesso(DiretivasAcessoModelo.fromJson(responseData));
        if (!ignorarArmazenamentoAutomatico) {
          return await EmpresaAcessosProvider().insertEmpresaAcesso(
            empresaId: parameters['empresaId'], object: responseData
          );
        }
        break;

      case Endpoints.LOOKUP_VENDEDORES:
        // Insere Vendedores no banco de dados via batching
        // Optado pela possibilidade de alta massa de dados
        if (!ignorarArmazenamentoAutomatico) {
          List<VendedoresLookUp> vendedores = new List<VendedoresLookUp>();
          responseData.forEach((vendedor) => vendedores.add(VendedoresLookUp.fromJson(vendedor)));
          bool resultado = await VendedorLookupProvider().insertVendedoresBatch(vendedores);
        }
        
        // List<VendedoresLookUp> listaVendedores = new List<VendedoresLookUp>();
        // for(int i = 0; i < vendedores.length; i++) {
        //   listaVendedores.add(vendedores[i]);
        //   if ((i+1) % 10 == 0 || i+1 == vendedores.length) {
        //     await VendedorLookupProvider().insertVendedoresBatch(listaVendedores);
        //     listaVendedores.clear();
        //   }
        // }

        // Insere Vendedores normalmente no banco de dados, sem batching
        // return (responseData as List).map((vendedor) {
        //   VendedorLookupProvider().insertVendedor(VendedoresLookUp.fromJson(vendedor));
        // }).toList();
        break;

      case Endpoints.LOOKUP_PRODUTOS:
        // Insere Clientes normalmente no banco de dados, sem batching
        // return (responseData as List).map((cliente) {
        //   cliente['empresaId'] = empresa;
        //   ClienteLookupProvider().insertCliente(ClienteLookup.fromJson(cliente));
        // }).toList();

        // Insere Clientes no banco de dados via batching
        // Optado pela possibilidade de alta massa de dados

        if (!ignorarArmazenamentoAutomatico) {
          List<Produto> produtos = new List<Produto>();
          responseData['lista'].forEach((produto) {
            produto['empresaId'] = parameters['empresaId'];
            produtos.add(Produto.fromJson(produto));
          });
          bool resultado =  await ProdutoLookupProvider().insertProdutosBatchSingular(produtos);
        }


        // List<Produto> listaProdutos = new List<Produto>();
        // for(int i = 0; i < produtos.length; i++) {
        //   listaProdutos.add(produtos[i]);
        //   if ((i+1) % 1000 == 0 || i+1 == produtos.length) {
        //     await ProdutoLookupProvider().insertProdutosBatch(listaProdutos, deleteSeExistente: deleteSeExistente);
        //     listaProdutos.clear();
        //   }
        // }
        
        break;

      case Endpoints.PARCEIRO_LOOKUP:
        // Insere Clientes normalmente no banco de dados, sem batching
        // return (responseData as List).map((cliente) {
        //   cliente['empresaId'] = empresa;
        //   ClienteLookupProvider().insertCliente(ClienteLookup.fromJson(cliente));
        // }).toList();

        // Insere Clientes no banco de dados via batching
        // Optado pela possibilidade de alta massa de dados

        // if (ignorarArmazenamentoAutomatico) await ClienteLookupProvider().deleteAllCliente();
        if (!ignorarArmazenamentoAutomatico) {
          List<ClienteLookup> clientes = new List<ClienteLookup>();
          responseData.forEach((cliente) {
            cliente['empresaId'] = parameters['empresaId'];
            clientes.add(ClienteLookup.fromJson(cliente));
          });

          bool resultado = await ClienteLookupProvider().insertClientesBatchSingular(clientes);
        }


        // List<ClienteLookup> listaClientes = new List<ClienteLookup>();
        // for(int i = 0; i < clientes.length; i++) {
        //   listaClientes.add(clientes[i]);
        //   if ((i+1) % 1000 == 0 || i+1 == clientes.length) {
        //     await ClienteLookupProvider().insertClientesBatch(listaClientes);
        //     listaClientes.clear();
        //   }
        // }
        
        break;

      default:
        bool naoExiste = await DBProvider.db.checkOffline(endpoint, parameters);
        debugPrint('Não Existe?: $naoExiste');
        if (naoExiste) {
          debugPrint('Inserindo');
          DBProvider.db.createOffline(endpoint, parameters, responseData);
        }
        else {
          DBProvider.db.updateOffline(endpoint, parameters, responseData);
        }
    }

    // return (response as List).map((empresa) {
    //   print('Inserindo: $empresa');
    //   EmpresaRepositorio.salvaEmpresa(empresa);
    // }).toList();


  }

  _offlineLookUp(endpoint, parameters, response) async {

    var idEmpresa = await obterIdEmpresaShared();
     
     String tipos = '[1,9,13]';

     String lookupNome = 'Clientes';

     debugPrint('Inserindo');

    // bool verifica = await DBProvider.db.checkOffline(endpoint, parameters);
    
    // if (verifica) {
    //   DBProvider.db.createOffline(endpoint, parameters, response);
    // }

    // debugPrint('Existe: $verifica');

     return (response as List).map((empresa) {
       print('Inserting $empresa');
      // LookupOfflineDBProvider.db.createProdutoLookUp(endpoint, tipos, lookupNome, Lista.fromJson(empresa));
     }).toList();  

  }

  _exibeErros(BuildContext context) {

    if (response.data['erros'].isEmpty) {

      print(response);

      if(_isloading) CarregandoAlertaComponente().dismissCarregar(context);

      AlertaComponente().showAlertaErro(context: context, mensagem: response.data['erroCodigo']);

      return response;

    } else {
      
      print(response);

      List<String> erros = new List<String>();

      if(_isloading) CarregandoAlertaComponente().dismissCarregar(context);

      erros.add(response.data['erroCodigo'] + '\n\n');

      response.data['erros'].forEach((erro) {
        String mensagem = erro['descricao'] + ':\n' + erro['erroDescricao'] + '\n\n';
               erros.add(mensagem);
      });
      AlertaComponente().showAlertaErros(context: context, erros: erros);
      return response;
    }
  }

  Future<dynamic> getReq(
      { 
        @required String endpoint,
        @required dynamic data,
        BuildContext context,
        bool loading = false,
        String mensagemErro = '',
        bool ignorarArmazenamentoAutomatico = false,
        bool sincronizacao = false
      }
      ) async {

    _isloading = loading;

    if (_isloading) CarregandoAlertaComponente().showCarregar(context);

    await _carregaConfigs();

    if (_estaOnline) {

      if(!sincronizacao) {
        await Future.wait([OfflineService().sincronizacaoUpload(context)]);
      }
      
      print('Estou Online');

      try {
        response = await dio.get(
          endpoint,
          queryParameters: data,
          options: Options(
              headers: {
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: 'Bearer ' + token,
              },
              followRedirects: true,
              receiveDataWhenStatusError: true,
              validateStatus: (status) {
                return status <= 500;
              }),
        );

        if (response.statusCode == 401) {
          response2 = await _requestoken();

          _armezenaDadosToken();

          response = await dio.get(endpoint,
              queryParameters: data,
              options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    HttpHeaders.authorizationHeader:
                        'Bearer ' + response2.data['entidade']['token'],
                  },
                  followRedirects: true,
                  receiveDataWhenStatusError: true,
                  validateStatus: (status) {
                    // if(_isloading) CarregandoAlertaComponente().dismissCarregar(context);
                    return status <= 500;
                  }));

          print('401: ${response2.data['entidade']['token']}');

          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          if (response.data['entidade'] != {} ||
              response.data['entidade'] != null) {
            _offline(endpoint, data, response.data['entidade'], ignorarArmazenamentoAutomatico: ignorarArmazenamentoAutomatico);
            return response.data['entidade'];
          } else {
            return response;
          }
        }
        else if (response.statusCode == 400) {
          print(response);
          print(response.statusCode);
          // CarregandoAlertaComponente().dismissCarregar(context);
          AlertaComponente().showAlertaErro(
            context: context,
            mensagem: mensagemErro != '' ? mensagemErro : 'Erro400',
            localedMessage: mensagemErro != '' ? false : true
          );
          return response;
        }
        else {
          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          print(response);
          print(response.statusCode);
          if (response.data['entidade'] == {} || response.data['entidade'] == null) {
            return response;
          }
          else {
            // await DBProvider().deleteAllOffline();
            _offline(endpoint, data, response.data['entidade'], ignorarArmazenamentoAutomatico: ignorarArmazenamentoAutomatico);
            return response.data['entidade'];
          }
        }
      } catch (error, stacktrace) {
        // if (loading) CarregandoAlertaComponente().dismissCarregar(context);
        await AlertaComponente().showAlertaErro(
          context: context,
          mensagem: mensagemErro != '' ? mensagemErro : 'Erro400',
          localedMessage: mensagemErro == ''
        );
        print("Uma excessção aconteceu: $error | StackTrace: $stacktrace");
        return response;
      }
    } else {
      debugPrint('Estou Offline');
      if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      dynamic empresasLista = await DBProvider.db.getOffline(endpoint, data);
      return empresasLista;

    }
  }

  Future<dynamic> postReq(
      {@required String endpoint,
      @required dynamic data,
      BuildContext context,
      bool loading = false,
      String mensagemErro = '',
      bool sincronizacao = false}) async {

    _isloading = loading;

    if (_isloading) CarregandoAlertaComponente().showCarregar(context);

    await _carregaConfigs();

    if (_estaOnline) {

      if(!sincronizacao) {
        await Future.wait([OfflineService().sincronizacaoUpload(context)]);
      }
      
      try {
        response = await dio.post(
          endpoint,
          data: data,
          options: Options(
              headers: {
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: 'Bearer ' + token,
              },
              followRedirects: true,
              receiveDataWhenStatusError: true,
              validateStatus: (status) {
                return status <= 500;
              }),
        );

        if (response.statusCode == 401) {

          response2 = await _requestoken();
          _armezenaDadosToken();

          response = await dio.post(endpoint,
              data: data,
              options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    HttpHeaders.authorizationHeader:
                        'Bearer ' + response2.data['entidade']['token'],
                  },
                  followRedirects: true,
                  receiveDataWhenStatusError: true,
                  validateStatus: (status) {
                    if (loading)
                      CarregandoAlertaComponente().dismissCarregar(context);
                    return status <= 500;
                  }));

          
          print('401: ${response2.data['entidade']['token']}');

          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          _offline(endpoint, data, response.data['entidade']);
          return response;
        } else if (response.data['erroCodigo'] == null ||
                   response.data['erros'] == null) {

          print(response.statusCode);
          print(response);

          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);

          print(response);
          print(response.statusCode);

          if (response.data['entidade'] == {} || response.data['entidade'] == null) {
            return response;
          }
          else {
            _offline(endpoint, data, response.data['entidade']);
            return response.data['entidade'];
          }
        } else {
          _exibeErros(context);
          _offline(endpoint, data, response.data['entidade']);
          return response;
        }
      } catch (error, stacktrace) {

        if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
        if (response.data['erroCodigo'] == null || response.data['erros'] == null) {
          await AlertaComponente().showAlertaErro(
            context: context,
            mensagem: mensagemErro != '' ? mensagemErro : 'Erro400',
            localedMessage: mensagemErro == ''
          );
        }
        else {
          _exibeErros(context);
        }

        print("Uma excessção aconteceu: $error | StackTrace: $stacktrace");
        _offline(endpoint, data, response.data['entidade']);
        return response;
      }
    } else {
      debugPrint('Estou Offline');

      // if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      // EmpresaRepositorio.listaEmpresa();
      if (endpoint == Endpoints.ACCOUNT_LOGIN) {
        dynamic empresasLista = await DBProvider.db.getOffline(endpoint, data);
        if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
        return empresasLista;
      }
      else {
        debugPrint('Método para salvar no banco para sincronizar depois que entrar em conexão.');
        dynamic resultado = await DBProvider.db.salvarEmOffline(
          endpoint: endpoint,
          parameters: {},
          method: Request.POST,
          object: data
        );
        // var resultado = await DBProvider.db.salvarEmOffline(endpoint, {}, 'POST', data);
        debugPrint(resultado.toString());
        if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
        return true;
      }
    }
  }

  Future<dynamic> putReq(
      {@required String endpoint,
      @required dynamic data,
      BuildContext context,
      bool loading = false,
      String mensagemErro = '',
      bool sincronizacao = false}) async {
    _isloading = loading;
    if (_isloading) CarregandoAlertaComponente().showCarregar(context);
    await _carregaConfigs();

    if (_estaOnline) {

      if(!sincronizacao) {
        await Future.wait([OfflineService().sincronizacaoUpload(context)]);
      }

      try {
        response = await dio.put(
          endpoint,
          data: data,
          options: Options(
              headers: {
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: 'Bearer ' + token,
              },
              followRedirects: true,
              receiveDataWhenStatusError: true,
              validateStatus: (status) {
                return status <= 500;
              }),
        );

        if (response.statusCode == 401) {
          response2 = await _requestoken();
          _armezenaDadosToken();

          response = await dio.put(endpoint,
              data: data,
              options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    HttpHeaders.authorizationHeader:
                        'Bearer ' + response2.data['entidade']['token'],
                  },
                  followRedirects: true,
                  receiveDataWhenStatusError: true,
                  validateStatus: (status) {
                    if (_isloading)
                      CarregandoAlertaComponente().dismissCarregar(context);
                    return status <= 500;
                  }));

          print('401: ${response2.data['entidade']['token']}');
          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          return response;
        } else if (response.data['erroCodigo'] == null ||
            response.data['erros'] == null) {
          print(response);
          print(response.statusCode);
          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          if (response.data['entidade'] == {} || response.data['entidade'] == null) {
            return response;
          }
          else {
            _offline(endpoint, data, response.data['entidade']);
            return response.data['entidade'];
          }
        } else {
          _exibeErros(context);
          return response;
        }
      } catch (error, stacktrace) {
        if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
        await AlertaComponente().showAlertaErro(
          context: context,
          mensagem: mensagemErro != '' ? mensagemErro : 'Erro400',
          localedMessage: mensagemErro == ''
        );
        print("Uma excessção aconteceu: $error | StackTrace: $stacktrace");
        return response;
      }
    } else {
      debugPrint('Estou Offline');
      // debugPrint('Método para salvar no banco para sincronizar depois que entrar em conexão.');
      debugPrint('Método para salvar no banco para sincronizar depois que entrar em conexão.');
      dynamic resultado = await DBProvider.db.salvarEmOffline(
        endpoint: endpoint,
        parameters: {},
        method: Request.PUT,
        object: data
      );
      // var resultado = await DBProvider.db.salvarEmOffline(endpoint, {}, 'POST', data);
      debugPrint(resultado.toString());
      if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      return true;
      // if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      // return true;
    }
  }

  Future<dynamic> deleteReq(
      {@required String endpoint,
      @required dynamic data,
      BuildContext context,
      bool loading = false,
      String mensagemErro = '',
      bool sincronizacao = false}) async {
    print('token: $token');

    _isloading = loading;

    if (_isloading) CarregandoAlertaComponente().showCarregar(context);

    await _carregaConfigs();

    if (_estaOnline) {

      if(!sincronizacao) {
        await Future.wait([OfflineService().sincronizacaoUpload(context)]);
      }

      try {
        response = await dio.delete(
          endpoint,
          data: data,
          options: Options(
              headers: {
                'Content-Type': 'application/json',
                HttpHeaders.authorizationHeader: 'Bearer ' + token,
              },
              followRedirects: true,
              receiveDataWhenStatusError: true,
              validateStatus: (status) {
                return status <= 500;
              }),
        );

        if (response.statusCode == 401) {
          response2 = await _requestoken();
          _armezenaDadosToken();

          response = await dio.delete(endpoint,
              data: data,
              options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                    HttpHeaders.authorizationHeader:
                        'Bearer ' + response2.data['entidade']['token'],
                  },
                  followRedirects: true,
                  receiveDataWhenStatusError: true,
                  validateStatus: (status) {
                    if (loading)
                      CarregandoAlertaComponente().dismissCarregar(context);
                    return status <= 500;
                  }));

          print('401: ${response2.data['entidade']['token']}');
          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          return response;
        } else if (response.data['erroCodigo'] == null ||
            response.data['erros'] == null) {
          print(response.statusCode);
          if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
          if (response.data['entidade'] == {} || response.data['entidade'] == null) {
            return response;
          }
          else {
            _offline(endpoint, data, response.data['entidade']);
            return response.data['entidade'];
          }
        } else {
          _exibeErros(context);
          return response;
        }
      } catch (error, stacktrace) {
        if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
        await AlertaComponente().showAlertaErro(
          context: context,
          mensagem: mensagemErro != '' ? mensagemErro : 'Erro400',
          localedMessage: mensagemErro == ''
        );
        print("Uma excessção aconteceu: $error | StackTrace: $stacktrace");
        return response;
      }
    } else {
      debugPrint('Estou Offline');
      // debugPrint('Método para salvar no banco para sincronizar depois que entrar em conexão.');
      debugPrint('Método para salvar no banco para sincronizar depois que entrar em conexão.');
      dynamic resultado = await DBProvider.db.salvarEmOffline(
        endpoint: endpoint,
        parameters: {},
        method: Request.DELETE,
        object: data
      );
      // var resultado = await DBProvider.db.salvarEmOffline(endpoint, {}, 'POST', data);
      debugPrint(resultado.toString());
      if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      return true;
      // if (_isloading) CarregandoAlertaComponente().dismissCarregar(context);
      // return true;
    }
  }
}
