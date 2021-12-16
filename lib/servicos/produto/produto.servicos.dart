import 'package:flutter/foundation.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/models/lookUp/produto-lookUp.modelo.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:sqflite/sqflite.dart';

class ProdutoService {
  RequestUtil _request = new RequestUtil();

  int _empresaId;

  String _retornaTiposString(List<int> tipos) {
    String tiposString = '';
    for(int i = 0; i < tipos.length; i++) {
      if(i == 0) {
        tiposString += '${tipos[i]}';
      }
      else {
        tiposString += ',${tipos[i]}';
      }
    }
    return tiposString;
  }

  Future<dynamic> buscaProdutoCodigo({String produtoCodigo, int empresaId, List<int> situacao}) async {
    if(await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.LOOKUP_PRODUTOS,
        data: {
          'codigo': produtoCodigo,
          'empresaId': empresaId
        },
      );
    }
    else {
      return await ProdutoLookupProvider().getProdutosList(codigo: produtoCodigo, empresaId: empresaId);
    }
  }

  Future<dynamic> buscaProdutoId({int produtoId, int empresaId}) async {
    if(await _request.verificaOnline()) {
      return _request.getReq(
        endpoint: Endpoints.LOOKUP_PRODUTOS,
        data: {
          'id': produtoId,
          'empresaId': empresaId,
        },
      );
    }
    else {
      return await ProdutoLookupProvider().getProdutosList(idProduto: produtoId, empresaId: empresaId);
    }
  }

  Future<dynamic> downloadTodosProdutosEmpresa(List<Empresa> empresa) async {
    List<dynamic> resultados = List<dynamic>();
    List<Future> requests = List<Future>();
    empresa.forEach((element) {
      dynamic resultado = _request.getReq(
        endpoint: Endpoints.LOOKUP_PRODUTOS,
        data: {
          'ignorarPaginacao': true,
          'empresaId': element.id,
          'situacoes': '1'
        },
        ignorarArmazenamentoAutomatico: true
      );
      requests.add(resultado);
    });
    resultados = await Future.wait(requests);
    return resultados;
  }

  Future<dynamic> listaProdutos({int skip = 0, String search = '', List<int> tipos, int empresaIdOverride}) async {

    String tiposString = '';
    tiposString = _retornaTiposString(tipos);

    if (await _request.verificaOnline()) {
      if (empresaIdOverride != null) {
        return _request.getReq(
          endpoint: Endpoints.LOOKUP_PRODUTOS,
          data: {
            'skip': skip * Request.TAKE,
            'take': Request.TAKE,
            'search': search,
            'empresaId': empresaIdOverride,
            'tipos': tiposString,
            'situacoes': '1'
          }
        );
      }
      else {
        _empresaId = await _request.obterIdEmpresaShared();
        return _request.getReq(
          endpoint: Endpoints.LOOKUP_PRODUTOS,
          data: {
            'skip': skip * Request.TAKE,
            'take': Request.TAKE,
            'search': search,
            'empresaId': _empresaId,
            'tipos': tiposString,
            'situacoes': '1'
          }
        );
      }
    }
    else {
      if (empresaIdOverride != null) {
        return await ProdutoLookupProvider().getProdutosList(
          empresaId: empresaIdOverride, tipos: tipos, skip: skip, search: search
        );
      }
      else {
        _empresaId = await _request.obterIdEmpresaShared();
        return await ProdutoLookupProvider().getProdutosList(
          empresaId: _empresaId, tipos: tipos, skip: skip, search: search
        );
      }
    }
  }
}


class ProdutoLookupProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_LOOKUP_PRODUTO);
    return res.isNotEmpty;
  }

  insertProduto(Produto produto) async {
    // Insere o produto na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_LOOKUP_PRODUTO, produto.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  List<ProdutoLookUp> _converteListaEmpresas(List<dynamic> lista, List<Empresa> empresas){
    List<ProdutoLookUp> _resultado = new List<ProdutoLookUp>();

    for(int i = 0; i < empresas.length; i++) {
      int empresaId = empresas[i].id;
      lista[i]['lista'].forEach((produto) {
        produto['empresaId'] = empresaId;
      });
      _resultado.add(ProdutoLookUp.fromJson(lista[i]));
    }

    return _resultado;
  }

  int _countBatch(List<ProdutoLookUp> lista) {
    int resultado = 0;
    lista.forEach((element) {
      resultado+= (element.lista.length ~/ 1000) + (element.lista.length % 1000 == 0 ? 0 : 1);
    });
    return resultado;
  }

  insertProdutosBatch(List<dynamic> produtosEmpresas, List<Empresa> empresas) async {
    List<ProdutoLookUp> produtos = _converteListaEmpresas(produtosEmpresas, empresas);
    List<Produto> listaProdutos = new List<Produto>();

    // Insere os produtos na tabela via batches
    Database db = await dbProvider.database;
    int batchCounter = _countBatch(produtos);
    int currentBatch = 0;

    for(int i = 0; i < produtos.length; i++) {
      for(int j = 0; j < produtos[i].lista.length; j++) {
        listaProdutos.add(produtos[i].lista[j]);
        if ((j+1) % 1000 == 0 || j+1 == produtos[i].lista.length) {
          await db.transaction((txn) async {
            Batch batch = txn.batch();
            listaProdutos.forEach((element) {
              batch.insert(DBProvider.TABLE_LOOKUP_PRODUTO, element.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
            });
            // await batch.commit(continueOnError: true, noResult: true);

            // As duas últimaslinhas são apenas para confirmação de resultados
            // Foram omitidas para melhorar a performance
            var results = await batch.commit(continueOnError: true);
            currentBatch++;
            debugPrint(results.toString());
            return results;
          });
          listaProdutos.clear();
        }
      }
    }
    
    if (currentBatch == batchCounter) return true;
    else return false;
  }

  insertProdutosBatchSingular(List<Produto> produtos) async {
    List<Produto> listaProdutos = new List<Produto>();
    // Insere os produtos na tabela via batches
    Database db = await dbProvider.database;
    int batchCounter = (produtos.length ~/ 1000) + (produtos.length % 1000 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < produtos.length; i++) {
      listaProdutos.add(produtos[i]);
      if ((i+1) % 1000 == 0 || i+1 == produtos.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaProdutos.forEach((element) {
            batch.insert(DBProvider.TABLE_LOOKUP_PRODUTO, element.toMap(), conflictAlgorithm: ConflictAlgorithm.ignore);
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaProdutos.clear();
      }
    }


    if (currentBatch == batchCounter) return true;
    else return false;
  }

  updateProduto(Produto cliente) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_LOOKUP_PRODUTO, cliente.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  updateAllProduto(Produto cliente) async {
    await deleteAllProduto();
    await insertProduto(cliente);
  }

  getProdutosList({
    int skip = 0, int idProduto, String search = '', int empresaId, String codigo, List<int> tipos,
  }) async {
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;
    List<Map<String, dynamic>> res;
    // Verifica se está buscando por id, ou código ou não
    if(idProduto == null && codigo == null) {
      // Verifica se está fazendo uma busca de string ou não
      if(search == null || search.isEmpty) {
        // Se não houver busca, retorna tudo
        res = await db.query(
          DBProvider.TABLE_LOOKUP_PRODUTO,
          where: 'empresaId = ? AND tipo IN (${tipos.join(', ')})', whereArgs: [empresaId],
          limit: Request.TAKE, offset: skip
        );
      }
      else {
        // Se não, retorna a busca
        res = await db.query(
          DBProvider.TABLE_LOOKUP_PRODUTO,
          where: 'empresaId = ? AND (descricao LIKE ? OR codigo LIKE ?) AND tipo IN (${tipos.join(', ')})',
          whereArgs: [empresaId, '%$search%', '%$search%'],
          limit: Request.TAKE, offset: skip
        );
      }
    }
    else if (codigo.isNotEmpty) {
      // Realiza a busca por Código
      res = await db.query(
        DBProvider.TABLE_LOOKUP_PRODUTO,
        where: 'codigo = ?', whereArgs: [codigo],
        limit: Request.TAKE, offset: skip
      );
    }
    else {
      // Realiza a busca por ID
      res = await db.query(
        DBProvider.TABLE_LOOKUP_PRODUTO,
        where: 'id = ?', whereArgs: [idProduto],
        limit: Request.TAKE, offset: skip
      );
    }
    var retorno = {
      'lista': res,
      'pesquisaIdentica': false
    };
    return retorno;
  }

  deleteProduto(Produto cliente) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_LOOKUP_PRODUTO, where: 'id = ?', whereArgs: [cliente.id]);
  }

  deleteAllProduto() async {
    // Realiza Truncate na tabela Cliente.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_LOOKUP_PRODUTO);
    }
  }
}
