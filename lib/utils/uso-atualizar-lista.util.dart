import 'package:flutter/material.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/infinite-scroll.util.dart';
import 'package:erp/utils/request.util.dart';

class TelaComListaASerAtualizada extends StatefulWidget {
  @override
  _TelaComListaASerAtualizadaState createState() => _TelaComListaASerAtualizadaState();
}

class _TelaComListaASerAtualizadaState extends State<TelaComListaASerAtualizada> {

  List lista = new List();
  String pesquisa = '';
  TextEditingController _busca = new TextEditingController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  Stream<dynamic> _streamLista;

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            child: StreamBuilder(
              stream: _streamLista,
              builder: (context, snapshot) {
                return Column(
                  children: <Widget>[
                    FlatButton(
                      child: Text('NovoItem'),
                      onPressed: _novoItem,
                    ),
                    FlatButton(
                      child: Text('EditarItem'),
                      onPressed: _editarItem,
                    ),
                  ],
                );
              }
            ),
          );
        }
      ),
    );
  }

  Future<dynamic> _fazRequest() async {}

  _novoItem() async {
    dynamic argumentos = 0;
    // Atribui a chamada da tela de cadastro de item á uma variável final
    // Ela ira esperar pelo resultado da próxima tela quando fechar
    final resultado = await ArquivoDeRotas.vaParaCadastroItem(
      context,
      argumentos: argumentos,
    );

    // A tela de cadastro de item deve retornar um booleano ou nulo
    // Se retornar true, a tela anterior (no caso essa) irá atualizar a lista
    if (resultado != null && resultado == true) {
      setState(() {
        // Zera a Lista e a pesquisa para que ela seja preenchida com a lista atualizada
        lista.clear();
        pesquisa = '';
        _busca.clear();
      });
      // Zera as propriedades do infinite scroll caso já tenha sido utilizado
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      // Refaz a request
      _streamLista = Stream.fromFuture(_fazRequest());
    }
  }

  _editarItem({int idItem}) async {
    // Realiza a requisição na própria tela de listagem para economizar idas caso haja algum erro
    // Atribui para uma variável
    dynamic retorno = await ItemService().getItem(idItem: idItem, context: context);

    // Use o objeto de conversão para que a próxima tela consiga carregá-lo
    ItemEditar itemRetorno = ItemEditar.fromJson(retorno);

    // Repita o procedimento para Adição
    final resultado = await ArquivoDeRotas.vaParaCadastroItem(
      context,
      argumentos: itemRetorno
    );

    if (resultado != null && resultado == true) {
      setState(() {
        lista.clear();
        pesquisa = '';
        _busca.clear();
      });
      _infinite.skipCount = 0;
      _infinite.infiniteScrollCompleto = false;
      _streamLista = Stream.fromFuture(_fazRequest());
    }
  }
}

class ItemService {
  RequestUtil _request = new RequestUtil();

  Future<dynamic> getItem({@required int idItem, BuildContext context}) async {
    return _request.getReq(
      endpoint: '$idItem',
      data: null,
      loading: true,
      context: context
    );
  }
}

class ItemEditar {
  int idItemExemplo;

  ItemEditar({this.idItemExemplo});

  ItemEditar.fromJson(Map<String, dynamic> json) {
    idItemExemplo = json['idItemExemplo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idItemExemplo'] = this.idItemExemplo;
    return data;
  }
}


class ArquivoDeRotas {
  // Crie o método como static normalmente e seu retorno é um Future<bool>.
  // Faça-o como async e faça com que ele retorne o Navigator.push() para que possa receber o resultado
  // do Navigator.pop() da tela anterior e usá-lo caso retorne.
  static Future<bool> vaParaCadastroItem(BuildContext context, {dynamic argumentos}) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CadastroItemTela(argumentos: argumentos,))
    );
  }
}

class CadastroItemTela extends StatefulWidget {
  final dynamic argumentos;
  CadastroItemTela({this.argumentos});
  @override
  _CadastroItemTelaState createState() => _CadastroItemTelaState();
}

class _CadastroItemTelaState extends State<CadastroItemTela> {

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            child: FlatButton(
              child: Text('Salvar'),
              onPressed: () {
                // Chamar Navigator.pop e passar o context e o valor true caso a ação seja bem sucedida
                Navigator.pop(context, true);
              },
            )
          );
        }
      ),
    );
  }
}
