import 'dart:async';

import 'package:flutter/material.dart';

class BuscaComponente extends StatefulWidget {
  final Function funcao;
  final String placeholder;
  BuscaComponente({Key key, this.funcao, this.placeholder}) : super(key: key);
  @override
  BuscaComponenteState createState() => BuscaComponenteState();
}

class BuscaComponenteState extends State<BuscaComponente> {
  TextEditingController _busca = new TextEditingController();
  FocusNode _focusBusca = new FocusNode();
  Timer _debounce;
  String pesquisa = '';
  // Declaração da key em qualquer tela
  // final GlobalKey<BuscaComponenteState> _buscaKey = GlobalKey<BuscaComponenteState>();

  @override
  void initState() { 
    super.initState();
    _busca.addListener(_buscaDebounce);
  }

  @override
  void dispose() { 
    _busca.removeListener(_buscaDebounce);
    _busca.dispose();
    _focusBusca.dispose();
    super.dispose();
  }

  _buscaDebounce() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (alterouBusca()) {
        widget.funcao();
      }
    });
  }

  bool alterouBusca() {
    if (_busca.text != pesquisa) {
      pesquisa = _busca.text;
      return true;
    }
    else {
      return false;
    }
  }

  clearBusca() {
    _busca.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          focusNode: _focusBusca,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            _focusBusca.unfocus();
          },
          style: TextStyle(color: Colors.white),
          keyboardType: TextInputType.text,
          controller: _busca,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.placeholder,
            hintStyle: TextStyle(color: Colors.white),
            suffixIcon: IconButton(
              icon: (pesquisa == '')
                ? Icon(Icons.search, color: Colors.white)
                : Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                if (pesquisa.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) => _busca.clear());
                }
              }
            ),
          ),
        ),
      ),
    );
  }
}
