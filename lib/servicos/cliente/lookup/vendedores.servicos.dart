import 'package:flutter/foundation.dart';
import 'package:erp/models/cliente/lookup/vendedoresLookUp.modelo.dart';
import 'package:erp/models/empresa.modelo.dart';
import 'package:erp/provider/db.provider.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:sqflite/sqflite.dart';

class VendedoresService {
  RequestUtil request = new RequestUtil();
  int registroId;

  Future<dynamic> getVendedor(int idVendedor) async {
    registroId = await request.obterIdEmpresaShared();
    // registroId = await request.obterIdRegistroShared();
    if(await request.verificaOnline()) {
      return await request.getReq(
        endpoint: Endpoints.LOOKUP_VENDEDORES,
        data: {
          'id': idVendedor,
          'empresaId': registroId
        }
      );
    }
    else {
      return await VendedorLookupProvider().getVendedoresList(idVendedor: idVendedor);
    }
  }

  Future<List<VendedoresLookUp>> downloadTodosVendedores() async {
    // registroId = await request.obterIdRegistroShared();
    int empresaId = await request.obterIdEmpresaShared();
    List<VendedoresLookUp> _vendedores = List<VendedoresLookUp>();
    dynamic resultado;
    resultado = await request.getReq(
      endpoint: Endpoints.LOOKUP_VENDEDORES,
      data: {
        'ignorarPaginacao': true,
        'empresaId': empresaId
        // 'empresaId': registroId
      },
      ignorarArmazenamentoAutomatico: true
    );
    resultado.forEach((e) => _vendedores.add(VendedoresLookUp.fromJson(e)));
    return _vendedores;
  }

  Future<dynamic> listaVendedores({int skip = 0, String search = ''}) async {
    registroId = await request.obterIdEmpresaShared();
    // registroId = await request.obterIdRegistroShared();
    if(await request.verificaOnline()) {
      return request.getReq(
        endpoint: Endpoints.LOOKUP_VENDEDORES,
        data: {
          'skip': skip * Request.TAKE,
          'take': Request.TAKE,
          'search': search,
          'empresaId': registroId
        }
      );
    }
    else {
      return await VendedorLookupProvider().getVendedoresList(skip: skip, search: search);
    }
  }
}

class VendedorLookupProvider {
  DBProvider dbProvider = DBProvider();

  Future<bool> _verificaExistente() async {
    Database db = await dbProvider.database;
    final res = await db.query(DBProvider.TABLE_LOOKUP_VENDEDOR);
    return res.isNotEmpty;
  }

  insertVendedor(VendedoresLookUp vendedor) async {
    // Insere o vendedor na tabela
    Database db = await dbProvider.database;
    int res = await db.insert(DBProvider.TABLE_LOOKUP_VENDEDOR, vendedor.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    return res;
  }

  Future<bool> insertVendedoresBatch(List<VendedoresLookUp> vendedores) async {
    // Insere os vendedores na tabela via batches
    List<VendedoresLookUp> listaVendedores = new List<VendedoresLookUp>();
    Database db = await dbProvider.database;
    int batchCounter = (vendedores.length ~/ 10) + (vendedores.length % 10 == 0 ? 0 : 1);
    int currentBatch = 0;

    for(int i = 0; i < vendedores.length; i++) {
      listaVendedores.add(vendedores[i]);
      if ((i+1) % 10 == 0 || i+1 == vendedores.length) {
        await db.transaction((txn) async {
          Batch batch = txn.batch();
          listaVendedores.forEach((element) {
            batch.insert(
              DBProvider.TABLE_LOOKUP_VENDEDOR, element.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore
            );
          });
          // await batch.commit(continueOnError: true, noResult: true);

          // As duas últimaslinhas são apenas para confirmação de resultados
          // Foram omitidas para melhorar a performance
          var results = await batch.commit(continueOnError: true);
          currentBatch++;
          debugPrint(results.toString());
          return results;
        });
        listaVendedores.clear();
      }
    }

    if(currentBatch == batchCounter) return true;
    else return false;

    // await db.transaction((txn) async {
    //   Batch batch = txn.batch();
    //   vendedores.forEach((element) {
    //     batch.insert(DBProvider.TABLE_LOOKUP_VENDEDOR, element.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore);
    //   });
    // await batch.commit(continueOnError: true, noResult: true);

    // As duas últimaslinhas são apenas para confirmação de resultados
    // Foram omitidas para melhorar a performance
    //   var results = await batch.commit(continueOnError: true);
    //   print(results);
    // });
  }

  updateVendedor(VendedoresLookUp vendedor) async {
    Database db = await dbProvider.database;
    int res = await db.update(DBProvider.TABLE_LOOKUP_VENDEDOR, vendedor.toJson());
    return res;
  }

  updateAllVendedor(VendedoresLookUp vendedor) async {
    await deleteAllVendedor();
    await insertVendedor(vendedor);
  }

  getVendedoresList({int skip = 0, int idVendedor, String search = ''}) async {
    Database db = await dbProvider.database;
    skip = skip * Request.TAKE;
    List<Map<String, dynamic>> res;
    // Verifica se está buscando por id ou não
    if(idVendedor == null) {
      // Verifica se está fazendo uma busca de string ou não
      if(search == null || search.isEmpty) {
        // Se não houver busca, retorna tudo
        res = await db.query(
          DBProvider.TABLE_LOOKUP_VENDEDOR,
          limit: Request.TAKE, offset: skip
        );
      }
      else {
        // Se não, retorna a busca
        res = await db.query(
          DBProvider.TABLE_LOOKUP_VENDEDOR,
          where: 'nome LIKE ? OR email LIKE ?', whereArgs: ['%$search%', '%$search%'],
          limit: Request.TAKE, offset: skip
        );
      }
    }
    else {
      // Realiza a busca por ID
      res = await db.query(
        DBProvider.TABLE_LOOKUP_VENDEDOR,
        where: 'id = ?', whereArgs: [idVendedor],
        limit: Request.TAKE, offset: skip
      );
    }
    return res;
  }

  deleteVendedor(VendedoresLookUp vendedor) async {
    Database db = await dbProvider.database;
    int res = await db.delete(DBProvider.TABLE_LOOKUP_VENDEDOR, where: 'id = ?', whereArgs: [vendedor.id]);
  }

  deleteAllVendedor() async {
    // Realiza Truncate na tabela Vendedor.
    // Usualmente será utilizado para realizar a atualização da tabela quando fizer a sincronização
    if (await _verificaExistente()) {
      Database db = await dbProvider.database;
      int res = await db.delete(DBProvider.TABLE_LOOKUP_VENDEDOR);
    }
  }
}
