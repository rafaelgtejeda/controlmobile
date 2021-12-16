import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/sem-informacao/sem-informacao.componente.dart';
import 'package:erp/models/lookUp/conta-corrente-lookup.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/servicos/lookup/conta-corrente-lookup.servicos.dart';
import 'package:erp/utils/constantes/opcoes-popup-menu.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/helper.dart';
import 'package:erp/utils/request.util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContasSelecao extends StatefulWidget {
  final int args;
  ContasSelecao({this.args});
  @override
  _ContasSelecaoState createState() => _ContasSelecaoState();
}

class _ContasSelecaoState extends State<ContasSelecao> {
  LocalizacaoServico _locate = new LocalizacaoServico();
  Stream<dynamic> _streamContas;
  List<ContaCorrenteLookup> _contasList = new List<ContaCorrenteLookup>();
  List<int> _contasSelecionadas = new List<int>();

  bool _habilitaBotao = false;

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
    _streamContas = Stream.fromFuture(_fazRequest());
    _preencheContasSelecionadasStorage();
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_locate.locale['SelecaoContas']),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: _escolheOpcao,
                  itemBuilder: (BuildContext context) {
                    return ConstantesOpcoesPopUpMenu.ESCOLHAS_CONTAS.map((String escolha) {
                      return PopupMenuItem<String>(
                        value: escolha,
                        child: Text(_locate.locale['$escolha']),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: CustomOfflineWidget(child: _listagemContas()),
            bottomNavigationBar: _isOnline
              ? _habilitaBotao
                ? _botaoSelecionar()
                : null
              : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  Widget _botaoSelecionar() {
    return Container(
      height: 50,
      width: double.maxFinite,
      color: Theme.of(context).primaryColor,
      child: FlatButton(
        onPressed: () async {
          if(_contasSelecionadas.isNotEmpty) {
            List<String> _contasIdsString = new List<String>();
            _contasSelecionadas.forEach((conta) {
              _contasIdsString.add(conta.toString());
            });
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            _prefs.setStringList(SharedPreference.CONTAS_SELECIONADAS, _contasIdsString);
            Navigator.pop(context, true);
          }
          else {
            Navigator.pop(context, false);
          }
        },
        child: Text(
          _locate.locale[TraducaoStringsConstante.SelecionarContas],
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _preencheContasSelecionadasStorage() async {
    List<String> _listaContasStorage = new List<String>();
    _listaContasStorage = await RequestUtil().obterIdsContasSharedPreferences();
    if (_listaContasStorage.isNotEmpty) {
      setState(() {
        // _contasSelecionadas.addAll(_listaContasStorage);
        _listaContasStorage.forEach((data) {
          _contasSelecionadas.add(int.parse(data));
        });
        _habilitaBotao = true;
      });
    }
  }

  Future<dynamic> _fazRequest() async {
    dynamic requestContas = await ContaCorrenteLookupService().obterContas(context: context);
    requestContas.forEach((data) {
      _contasList.add(ContaCorrenteLookup.fromJson(data));
    });
    _contasList = _verificaSelecionado(lista: _contasList);
    return _contasList;
  }

  Widget _listagemContas() {
    return StreamBuilder(
      stream: _streamContas,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          default:
            if(snapshot.hasError) {
              return Container();
            }
            else if (_contasList.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
              return SemInformacao();
            }
            else {
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) => Divider(thickness: 2, height: 0,),
                itemBuilder: (context, index) {
                  return _contaItem(context, index, _contasList);
                },
                itemCount: _contasList.length + 1,
              );
            }
        }
      }
    );
  }

  Widget _contaItem(BuildContext context, int index, List<ContaCorrenteLookup> lista) {
    if (index >= lista.length) {
      return null;
    }

    return InkWell(
      child: Container(
        color: lista[index].isSelected ? Colors.blue : Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                lista[index].nome,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
              Text(
                "${_locate.locale['Saldo']}: " + Helper().dinheiroFormatter(lista[index].saldo),
                style: TextStyle(
                  fontSize: 18,
                  color: lista[index].isSelected ? Colors.white : Colors.black
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _selecionarContas(idConta: lista[index].id, index: index);
      },
    );
  }

  _selecionarContas({int idConta, int index}) async {
    if (_contasSelecionadas.length == 0) {
      _contasSelecionadas.add(idConta);
      setState(() {
        _contasList[index].isSelected = true;
        _habilitaBotao = true;
      });
    }
    else {
      _multiplaSelecaoContas(idConta: idConta, index: index);
    }
  }

  _multiplaSelecaoContas({int idConta, int index}) {
    if (!_contasSelecionadas.contains(idConta)) {
      _contasSelecionadas.add(idConta);
      setState(() {
        _contasList[index].isSelected = true;
      });
    }
    else {
      if (_contasSelecionadas.length == 1) {
        setState(() {
          _habilitaBotao = false;
        });
      }
      _contasSelecionadas.remove(idConta);
      setState(() {
        _contasList[index].isSelected = false;
      });
    }
  }

  void _escolheOpcao(String escolha) {
    switch (escolha) {
      case ConstantesOpcoesPopUpMenu.SELECIONAR_TODAS:
        _selecionarTodos();
        break;
      default:
        break;
    }
  }

  _selecionarTodos() async {
    if(_contasSelecionadas.length == 0) {
      _contasSelecionadas.clear();

      _contasList.forEach((data) {
        _contasSelecionadas.add(data.id);
      });
      setState(() {
        _contasList.forEach((conta) {
          conta.isSelected = true;
        });
        _habilitaBotao = true;
      });
    }
    else if(_contasSelecionadas.length <= _contasList.length) {
      _contasSelecionadas.clear();
      setState(() {
        _contasList.forEach((conta) {
          conta.isSelected = false;
        });
        _habilitaBotao = false;
      });
    }
  }

  List<ContaCorrenteLookup> _verificaSelecionado({List<ContaCorrenteLookup> lista}) {
    lista.forEach((conta) {
      if(_contasSelecionadas.contains(conta.id)) {
        conta.isSelected = true;
      }
    });
    return lista;
  }
}
