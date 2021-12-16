import 'package:erp/offline/orm_base.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter/foundation.dart';

class Controlador{
   
  RequestUtil _requestUtil = new RequestUtil();

  adicionaControlador() async {

    int existe = await Controle().select().toCount();

    debugPrint('controlador: $existe');

    if(existe == 0) {
      Controle.withFields(1, 1, "1800-01-01 00:00:00.000", false).save();
               debugPrint('Adicionou adaptador default');
    }
  }

  verificaOffline() async {

    List<Cliente> lista = await Cliente().select().apiId.equals(0).toList();

    debugPrint('Clientes não sincronizado ${lista.length}');

    final controles = await Controle().select().toList();   
    for(var c in controles) {
       print(c.toMap());
    }
          
    if(lista.isNotEmpty) {
      await Future.wait([
        enviaAPI(clientes: lista)
      ]);
    }

    debugPrint('Clientes não sincronizado ${lista.length}');
    
  }

  Future<List<dynamic>> enviaAPI({List<Cliente> clientes}) async {

    List<Future> requisicoes = new List<Future>();
    List<dynamic> resultados = new List<dynamic>();

    clientes.forEach((c) {
      var parceiro = {
        "empresaId": c.empresaId,
        "cnpJ_CPF": c.cnpJCPF,
        "nome": c.nome_razaosocial,
        "nomeFantasia": c.nomeFantasia,
        "enderecoPrincipal": {
          "cep": c.cep,
          "codigoIBGE": "string",
          "endereco": c.endereco,
          "numero": c.numero,
          "bairro": c.bairro,
          "complemento": c.complemento,
          "cidade": c.cidade,
          "uf": c.uf
        },
        "contatoPrincipal": {
          "email": c.email,
          "telefone": {
            "ddd": c.dddTelefone,
            "ddi": c.ddiTelefone,
            "phone": c.telefone
          },
          "telefone2": {
            "ddd": "",
            "ddi": "",
            "phone": ""
          },
          "celular": {
            "ddd": c.dddCelular,
            "ddi": c.ddiCelular,
            "phone": c.celular
          },
        }
      };
      
      dynamic requisicao = _requestUtil.postReq(
        endpoint: Endpoints.PARCEIRO, data: parceiro, sincronizacao: true
      );

      requisicoes.add(requisicao);
    });

    resultados = await Future.wait(requisicoes);

    for(int i = 0; i < resultados.length; i++) {
      clientes[i].apiId = int.parse(resultados[i].data['id']);
    }

    await Cliente.saveAll(clientes);

    final atualizaData = await Controle.withId(1, 1,"${DateTime.now().toString()}", false).save();
 
    print(atualizaData);

    return resultados;
  }
}
