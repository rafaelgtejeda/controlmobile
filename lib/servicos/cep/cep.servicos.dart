import 'package:flutter/material.dart';
import 'package:search_cep/search_cep.dart';

class CepService {

  Future<dynamic> buscaPorCep({@required String cep}) async {
    final infoCepJson = await SearchCep.searchInfoByCep(cep: cep);
    return infoCepJson;
  }

  Future<dynamic> buscaPorLocalidade({@required String uf, @required String cidade, @required String endereco}) async {
    final cepsJson = await SearchCep.searchForCeps(
      uf: uf,
      cidade: cidade,
      logradouro: endereco,
      returnType: ReturnType.json
    );
    return cepsJson;
  }
}
