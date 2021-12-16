import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/models/lookUp/cliente-lookup.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/servicos/cliente/contato.servicos.dart';
import 'package:erp/servicos/cliente/checklist.servicos.dart';
import 'package:erp/servicos/cliente/limite-credito.servicos.dart';
import 'package:erp/servicos/cliente/lookup/vendedores.servicos.dart';
import 'package:erp/servicos/cliente/cobranca-pagamento.servicos.dart';
import 'package:erp/servicos/cliente/lookup/cidadeEstrangeira.servicos.dart';
import 'package:erp/servicos/cliente/lookup/ramoAtividade.servicos.dart';
import 'package:erp/servicos/cliente/lookup/grupoContato.servicos.dart';
import 'package:erp/servicos/cliente/lookup/tabelaPreco.servicos.dart';
import 'package:erp/servicos/cliente/parque-tecnologico.servicos.dart';
import 'package:erp/servicos/cliente/outros-enderecos.servicos.dart';
import 'package:erp/servicos/cliente/lookup/regiao.servicos.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:sqflite/sqflite.dart';

class ClienteService {
  
  RamoAtividadeService ramoAtividade = new RamoAtividadeService();
  RegiaoService regiao = new RegiaoService();
  GrupoContatoService grupoContato = new GrupoContatoService();

  CidadeEstrangeiraService cidadeEstrangeira = new CidadeEstrangeiraService();
  OutrosEnderecosService outrosEnderecos = new OutrosEnderecosService();
  CheckListService checkList = new CheckListService();
  ContatoService contato = new ContatoService();
  ParqueTecnologicoService parque = new ParqueTecnologicoService();
  CobrancaPagamentoService cobrancaPagamento = new CobrancaPagamentoService();

  TabelaPrecoService tabelaPreco = new TabelaPrecoService();
  VendedoresService vendedor = new VendedoresService();
  LimiteCreditoService limiteCredito = new LimiteCreditoService();

  RequestUtil _request = new RequestUtil();

  int _empresaId;

  Future<dynamic> clientesLista({int skip = 0, String search = ''}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.PARCEIROS,
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId
      }
    );
  }

  Future<dynamic> clienteLookupLista({int skip = 0, String search = ''}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    if(await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.PARCEIRO_LOOKUP,
        data: {
          'skip': skip * Request.TAKE,
          'take': Request.TAKE,
          'search': search,
          'empresaId': _empresaId,
          'situacoes': '1,3',
          'tiposParceiro': '1'
        }
      );
    }
    else {
      return await ClienteLookupProvider().getClientesList(skip: skip, empresaId: _empresaId, search: search);
    }
  }

  Future<dynamic> downloadTodosClientesEmpresa(List<Empresa> empresa) async {
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    empresa.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.PARCEIRO_LOOKUP,
        data: {
          'ignorarPaginacao': true,
          'empresaId': element.id,
          'situacoes': '1,3',
          'tiposParceiro': '1'
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    return resultados;
  }

  Future<dynamic> getClienteLookup({int id}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    if(await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.PARCEIRO_LOOKUP,
        data: {
          'id': id,
        }
      );
    }
    else {
      return await ClienteLookupProvider().getClientesList(idCliente: id);
    }
  }

  Future<dynamic> clienteSituacoesLookup({int skip = 0, String search = ''}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.SITUACAO_PARCEIRO_LOOKUP,
      data: {
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId
      }
    );
  }

  Future<dynamic> getClienteSituacoesLookup({int skip = 0, String search = '', int id}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.SITUACAO_PARCEIRO_LOOKUP,
      data: {
        'id': id,
        'skip': skip * Request.TAKE,
        'take': Request.TAKE,
        'search': search,
        'empresaId': _empresaId
      }
    );
  }
  
  Future<dynamic> getCliente({int idCliente, BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.PARCEIRO,
      data: {
        'id': idCliente,
        'empresaId': _empresaId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> adicionarCliente(String cliente, {BuildContext context}) async {
    return _request.postReq(
      endpoint: Endpoints.PARCEIRO,
      data: cliente,
      loading: true,
      context: context
    );
  }

  Future<dynamic> consultarCNPJ({String cnpj = '', BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.PARCEIRO_CONSULTAR_CNPJ,
      data: {
        'cnpj': cnpj,
        'empresaId': _empresaId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> editarCliente(String cliente, {BuildContext context}) async {
    return _request.putReq(
      endpoint: Endpoints.PARCEIRO,
      data: cliente,
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaCliente({@required int idCliente, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: '${Endpoints.PARCEIRO}/$idCliente',
      data: null,
      loading: true,
      context: context
    );
  }

  Future<dynamic> selecionaTodosClientes({BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.getReq(
      endpoint: Endpoints.PARCEIRO_SELECIONAR_TODOS,
      data: {
        'empresaId': _empresaId
      },
      loading: true,
      context: context
    );
  }

  Future<dynamic> deletaClientesLote({@required List<int> idClientes, BuildContext context}) async {
    return _request.deleteReq(
      endpoint: Endpoints.PARCEIRO,
      data: idClientes,
      loading: true,
      context: context
    );
  }

  Future<dynamic> clienteProspectIncluir({String cliente, BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    return _request.postReq(
      endpoint: Endpoints.PARCEIRO_INCLUIR_PROSPECT,
      data: cliente,
      loading: true,
      context: context
    );
  }
}

class ClienteLookupProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_DIRETIVAS_EMPRESA);
    return res.isNotEmpty;
  }

  insertCliente(ClienteLookup cliente) async {
    // Insere o cliente na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_LOOKUP_PARCEIRO, cliente.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  List<List<ClienteLookup>> _converteListaEmpresas(List<dynamic> lista, List<Empresa> empresas){
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

  int _countBatch(List<List<ClienteLookup>> lista) {
    int resultado = 0;
    lista.forEach((element) {
      resultado+= (element.length ~/ 1000) + (element.length % 1000 == 0 ? 0 : 1);
    });
    return resultado;
  }

  Future<bool> insertClientesBatch(List<dynamic> clientes, List<Empresa> empresas) async {
    List<List<ClienteLookup>> clientesEmpresa = _converteListaEmpresas(clientes, empresas);
    List<ClienteLookup> listaClientes = new List<ClienteLookup>();

    // Insere os clientes na tabela via batches
    Database db = await dbProvider.database;
    int batchCounter = _countBatch(clientesEmpresa);
    int currentBatch = 0;

    for(int i = 0; i < clientesEmpresa.length; i++) {
      for(int j = 0; j < clientesEmpresa[i].length; j++) {
        listaClientes.add(clientesEmpresa[i][j]);
        if ((j+1) % 1000 == 0 || j+1 == clientesEmpresa[i].length) {
          await db.transaction((txn) async {
            Batch batch = txn.batch();
            listaClientes.forEach((element) {
              batch.insert(DBProvider.TABLE_LOOKUP_PARCEIRO, element.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore);
            });
            // await batch.commit(continueOnError: true, noResult: true);

            // As duas últimaslinhas são apenas para confirmação de resultados
            // Foram omitidas para melhorar a performance
            var results = await batch.commit(continueOnError: true);
            currentBatch++;
            debugPrint(results.toString());
            return results;
          });
          listaClientes.clear();
        }
      }
    }

    if (currentBatch == batchCounter) return true;
    else return false;
  }

  Future<bool> insertClientesBatchSingular(List<ClienteLookup> clientes) async {
    // Insere os clientes na tabela via batches
    List<ClienteLookup> listaClientes = new List<ClienteLookup>();
    Database db = await dbProvider.database;
    int batchCounter = (clientes.length ~/ 1000) + (clientes.length % 1000 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < clientes.length; i++) {
      listaClientes.add(clientes[i]);
      if ((i+1) % 1000 == 0 || i+1 == clientes.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaClientes.forEach((element) {
            batch.insert(DBProvider.TABLE_LOOKUP_PARCEIRO, element.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaClientes.clear();
      }
    }
    if (currentBatch == batchCounter) return true;
    else return false;
  }

  updateCliente(ClienteLookup cliente) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_LOOKUP_PARCEIRO, cliente.toJson());
    return res;
  }

  updateAllCliente(ClienteLookup cliente) async {
    await deleteAllCliente();
    await insertCliente(cliente);
  }

  getClientesList({int skip = 0, int idCliente, String search = '', int empresaId}) async {
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;
    List<Map<String, dynamic>> res;
    // Verifica se está buscando por id ou não
    if(idCliente == null) {
      // Verifica se está fazendo uma busca de string ou não
      if(search == null || search.isEmpty) {
        // Se não houver busca, retorna tudo
        res = await db.query(
          DBProvider.TABLE_LOOKUP_PARCEIRO,
          where: 'empresaId = ?', whereArgs: [empresaId],
          limit: Request.TAKE, offset: skip
        );
      }
      else {
        // Se não, retorna a busca
        res = await db.query(
          DBProvider.TABLE_LOOKUP_PARCEIRO,
          where: 'empresaId = ? AND (nome LIKE ? OR nomeFantasia LIKE ?)',
          whereArgs: [empresaId, '%$search%', '%$search%'],
          limit: Request.TAKE, offset: skip
        );
      }
    }
    else {
      // Realiza a busca por ID
      res = await db.query(
        DBProvider.TABLE_LOOKUP_PARCEIRO,
        where: 'id = ?', whereArgs: [idCliente],
        limit: Request.TAKE, offset: skip
      );
    }
    return res;
  }

  deleteCliente(ClienteLookup cliente) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_LOOKUP_PARCEIRO, where: 'id = ?', whereArgs: [cliente.id]);
  }

  deleteAllCliente() async {
    // Realiza Truncate na tabela Cliente.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_LOOKUP_PARCEIRO);
    }
  }
}
