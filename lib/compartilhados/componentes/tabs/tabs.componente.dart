import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/rotas/rotas.dart';
import 'package:erp/servicos/diretivas-acesso/diretivas-acesso.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/telas/clientes/clientes.tela.dart';
import 'package:erp/telas/financeiro/finaceiro.tela.dart';
import 'package:erp/telas/ordem-servico/listagem/ordem-servico-listagem.tela.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:flutter/material.dart';
import 'package:erp/telas/vendas/vendas.tela.dart';
import 'package:erp/utils/helperFontSize.dart';
import 'package:provider/provider.dart';


class TabsComponente extends StatefulWidget {
  final int args;
  TabsComponente({Key key, this.args}) : super(key: key);
  _TabsComponenteState createState() => _TabsComponenteState();
}

class _TabsComponenteState extends State<TabsComponente> {

  TabIndex _tabIndexes = new TabIndex();
  bool _isOnline = true;

  int _currentTabIndex = 0;

  LocalizacaoServico _locale = new LocalizacaoServico();
  DiretivasAcessosService _diretivas = new DiretivasAcessosService();

  @override
  void initState() {
    super.initState();
    _locale.iniciaLocalizacao(context);
    _diretivas.iniciaDiretivas();
    _currentTabIndex = widget.args;
  }

  onTapped(int index) async {
    if (_tabIndexes.financeiro != null && index == _tabIndexes.financeiro && _isOnline) {
      List<String> contasIds = new List<String>();
      contasIds = await RequestUtil().obterIdsContasSharedPreferences();
      if (contasIds.isNotEmpty) {
        setState(() {
          _currentTabIndex = index;
        });
      } else {
        final bool resultado = await Rotas.vaParaSelecaoContas(context, args: index);
        if (resultado == true) {
          setState(() {
            _currentTabIndex = index;
          });
        }
      }
    }
    else {
      if(_isOnline) {
        setState(() {
          _currentTabIndex = index;
        });
      }
      else {
        if (index == _tabIndexes.ordemServico || index == _tabIndexes.vendas || index == _tabIndexes.clientes) {
          setState(() {
            _currentTabIndex = index;
          });
        }
      }
    }
  }

  final List<Widget> _children = [
    OrdemServicoListagemTela(),
    ClientesTela(),
    VendasTela(),
    FinanceiroTela()
  ];

  @override
  Widget build(BuildContext context) {
    _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    HelperFontSize helper = new HelperFontSize();
           helper.context = context;
              helper.size = MediaQuery.of(context).size;
    
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Scaffold(
            backgroundColor: Colors.grey[100],
            bottomNavigationBar: _bottomNormal(),
            body: _listaAtualizada()[_currentTabIndex],
          );
        },
      ),
    );
      
  }

  Widget _novoTeste() {
    return Row(
      children: <Widget>[
        IconButton(
          icon: null,
          onPressed: null,
        ),
      ],
    );
  }

  List<Widget> _listaAtualizada() {
    List<Widget> novaLista = new List<Widget>();

    if(_diretivas.diretivasDisponiveis.ordemServico.possuiOrdemDeServico) {
      novaLista.add(_children[0]);
    }

    if(_diretivas.diretivasDisponiveis.cliente.possuiClientes) {
      novaLista.add(_children[1]);
    }

    if(_diretivas.diretivasDisponiveis.venda.possuiVendas) {
      novaLista.add(_children[2]);
    }

    if(_diretivas.diretivasDisponiveis.financeiro.possuiFinanceiro) {
      novaLista.add(_children[3]);
    }

    return novaLista;
  }

  Widget _bottomNormal() => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: _currentTabIndex,
    items: _constroiListaTabs(),
    // items: widget.bottomTabs,
    onTap: onTapped,
  );

  List<BottomNavigationBarItem> _constroiListaTabs() {
    int indexCounter = 0;
    List<BottomNavigationBarItem> _lista = List<BottomNavigationBarItem>();

    // Ordem de Serviço
    if(_diretivas.diretivasDisponiveis.ordemServico.possuiOrdemDeServico) {
      int indice = indexCounter;
      _tabIndexes.ordemServico = indice;
      _lista.add(
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage(AssetsImagens.ORDEM_SERVICO),
              color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
              size: 25),
          title: Text(
            "${_locale.locale['OrdemDeServicoTab']}",
            style: TextStyle(
                fontSize: 16,
                color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey),
          ),
        )
      );
      indexCounter++;
    }

    // Clientes
    if(_diretivas.diretivasDisponiveis.cliente.possuiClientes) {
      int indice = indexCounter;
      _tabIndexes.clientes = indice;
      _lista.add(
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage(AssetsImagens.CLIENTES),
            color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            size: 25,
          ),
          title: Text(
            "${_locale.locale['Clientes']}",
            style: TextStyle(
              fontSize: 16,
              color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        )
      );
      indexCounter++;
    }
    
    // Vendas
    if(_diretivas.diretivasDisponiveis.venda.possuiVendas) {
      int indice = indexCounter;
      _tabIndexes.vendas = indice;
      _lista.add(
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage(AssetsImagens.VENDAS),
            color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            size: 25,
          ),
          title: Text(
            "${_locale.locale['Vendas']}",
            style: TextStyle(
              fontSize: 16,
              color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        )
      );
      indexCounter++;
    }
    
    // Financeiro
    if(_diretivas.diretivasDisponiveis.financeiro.possuiFinanceiro) {
      int indice = indexCounter;
      _tabIndexes.financeiro = indice;
      _lista.add(
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage(AssetsImagens.FINANCEIRO),
            color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            size: 25,
          ),
          title: Text(
            "${_locale.locale['Financeiro']}",
            style: TextStyle(
              fontSize: 16,
              color: _currentTabIndex == indice ? Theme.of(context).primaryColor : Colors.grey,
            ),
          ),
        )
      );
      indexCounter++;
    }

    return _lista;
  }
}

class TabIndex {
  int ordemServico;
  int clientes;
  int vendas;
  int financeiro;

  TabIndex({this.ordemServico, this.clientes, this.vendas, this.financeiro});
}
