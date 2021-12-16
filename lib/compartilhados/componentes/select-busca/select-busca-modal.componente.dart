import 'dart:async';

import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/utils/infinite-scroll.util.dart';

class SelectBuscaModal extends StatefulWidget {
  
  /// Título da tela
  final String titulo;

  /// Função no serviço que contém a request para listagem e busca dos itens
  final Future servico;

  /// Nesta lista de mapeamento é necessário passar especificamente os elementos `titulo` e `variavel`.
  /// 
  /// São do tipo String e referentes á como deve ser o nome do atributo a ser exibido e qual a sua variável correspondente na API respectivamente.
  /// 
  /// Deve ser preenchido na seguinte estrutura:
  /// 
  ///      [
  ///        [
  ///          {'titulo': 'texto_a_ser_exibido_na_tela'},
  ///          {'variavel': 'chave_da_variavel_retornada_da_API'}
  ///        ]
  ///      ]
  /// 
  /// 
  /// Assim como o Exemplo:
  /// 
  ///      [
  ///        [
  ///          {'titulo': 'Descrição'},
  ///          {'variavel': 'sescricao'}
  ///        ]
  ///      ]
  /// 
  /// Para cada par de `chave` e `valor` que vier da API
  
  final List<List<Map<String, String>>> elementos;

  final String buscaText;

  SelectBuscaModal({
    Key key, @required this.titulo, @required this.elementos, @required this.servico, this.buscaText
  }) : super (key: key);

  @override
  SelectBuscaModalState createState() => SelectBuscaModalState();
}

class SelectBuscaModalState extends State<SelectBuscaModal> {

  Stream _streamLista;
  TextEditingController _busca = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  InfiniteScrollUtil _infinite = new InfiniteScrollUtil();
  List<dynamic> _lista = new List<dynamic>();
  String _pesquisa = '';
  Timer _debounce;
  FocusNode _focusBusca = new FocusNode();


  @override
  void initState() {
    _streamLista = Stream.fromFuture(_fazRequest());
    super.initState();
    _busca.addListener(_buscaDebounce);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _infinite.verificaPermanencia(pesquisa: _pesquisa);
        _streamLista = Stream.fromFuture(_fazRequest());
        setState(() {});
      }
    });
  }

  void dispose() {
    _scrollController.dispose();
    _busca.removeListener(_buscaDebounce);
    _busca.dispose();
    _focusBusca.dispose();
    super.dispose();
  }

  Future<dynamic> _fazRequest() async {
    // Verifica se o Infinite Scroll já completou
    if (!_infinite.infiniteScrollCompleto) {
      // Se não, fazer a request passando o skipCount do infinite Scroll Util
      dynamic requestLista = await widget.servico;
      List<dynamic> listaRequest = new List<dynamic>();
      requestLista.forEach((data) {
        listaRequest.add(data);
      });

      // Atribua a lista recebida à variável novaLista do Infinite Scroll Util
      _infinite.novaLista = listaRequest;
      // Adicione a novaLista á lista original
      _lista.addAll(_infinite.novaLista);

      // Verifique se o infinite Scroll continuará ou não
      _infinite.completaInfiniteScroll();
      return _lista;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                focusNode: _focusBusca,
                textInputAction: TextInputAction.none,
                onSubmitted: (_) {
                  _focusBusca.unfocus();
                },
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.text,
                controller: _busca,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.buscaText ?? '',
                  hintStyle: TextStyle(color: Colors.white),
                  suffixIcon: IconButton(
                    icon: (_pesquisa == '')
                      ? Icon(Icons.search, color: Colors.white)
                      : Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      if (_pesquisa.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _busca.clear());
                      }
                    }
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: _listaItens(),
    );
  }

  _realizaBusca() {
    if (_busca.text != _pesquisa) {
      _infinite.verificaPesquisaAlterada();
    }
    else {
      _infinite.pesquisaAlterada = false;
    }

    _pesquisa = _busca.text;
    setState(() {
      _lista = [];
    });
    _streamLista = Stream.fromFuture(_fazRequest());
  }

  _buscaDebounce() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_busca.text != _pesquisa) {
        _realizaBusca();
      }
    });
  }

  _listaItens() {
    return StreamBuilder(
      stream: _streamLista,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            // return Center(
            //   child: Container(
            //     width: 200,
            //     height: 200,
            //     alignment: Alignment.center,
            //     child: Center(
            //       child: Carregando(),
            //     )
            //   ),
            // );
          default:
            if(snapshot.hasError || !snapshot.hasData || snapshot.data == "") {
              return Container();
            }
            else {
              return ListView.separated(
                controller: _scrollController,
                separatorBuilder: (BuildContext context, int index) =>
                  Divider(thickness: 2,),
                itemBuilder: (context, index) {
                  if (index == _lista.length && !_infinite.infiniteScrollCompleto) {
                    return Container(
                      height: 100,
                      width: 100,
                      alignment: Alignment.center,
                      child: Carregando(),
                    );
                  }
                  return _item(context, index, _lista, widget.elementos);
                },
                itemCount: _lista.length,
              );
            }
        }
      },
    );
  }

  Widget _item(BuildContext context, int index, List<dynamic> lista, List<List<Map<String, String>>> elementos) {
    if (index >= lista.length) {
      return null;
    }
    return InkWell(
      onTap: () {
        Navigator.pop(context, lista[index]);
      },
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _preencheItem(elementos, index, lista)
        ),
      ),
    );
  }

  /// Cria os elementos de texto
  List<Widget> _preencheItem(List<List<Map<String, String>>>elementos, int index, List<dynamic> lista) {
    List<Widget> listaElementos = new List();
    for(var i = 0; i < elementos.length; i++) {
      listaElementos.add(new Text(
        "${elementos[i][0]['titulo']}${lista[index]['${elementos[i][1]['variavel']}']}"
      ));
    }
    return listaElementos;
  }
}

class ItemSelectBuscaModal {
  final Map<String, String>elementos;

  ItemSelectBuscaModal({@required this.elementos});
}
