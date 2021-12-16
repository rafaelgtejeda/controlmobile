import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando-alerta.componente.dart';
import 'package:erp/models/idioma-item.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/config.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdiomaSelecaoComponente extends StatefulWidget {
  final Function atualizaIdioma;
  final Function(String) atualizaIdiomaDeEnvio;
  final bool atualizaEmBanco;
  IdiomaSelecaoComponente({Key key, this.atualizaIdioma, this.atualizaIdiomaDeEnvio, this.atualizaEmBanco = false}) : super(key: key);
  @override
  IdiomaSelecaoComponenteState createState() => IdiomaSelecaoComponenteState();
}

class IdiomaSelecaoComponenteState extends State<IdiomaSelecaoComponente> {
  LocalizacaoServico _locate = LocalizacaoServico();
  List<IdiomaItemModelo> _listaIdiomas = new List<IdiomaItemModelo>();
  Stream<dynamic> _listaIdiomasStream;

  @override
  void initState() { 
    super.initState();
    _listaIdiomasStream = Stream.fromFuture(_preencheLista());
    _verificaIdiomaSelecionado();
  }

  Future<dynamic> _preencheLista() async {
    if (_listaIdiomas.length == 0) {
      IdiomaItemModelo _pt_br = new IdiomaItemModelo();
      IdiomaItemModelo _en_us = new IdiomaItemModelo();
      IdiomaItemModelo _es_es = new IdiomaItemModelo();
      IdiomaItemModelo _de_de = new IdiomaItemModelo();

      _pt_br.imagemCaminho = 'images/flags/br.png';
      _pt_br.tooltip = ConfigIdioma.PORTUGUES_BRASIL_TOOLTIP;
      _pt_br.corSplash = Colors.green;
      _pt_br.idioma = ConfigIdioma.PORTUGUES_BRASIL;
      _pt_br.isSelected = false;

      _en_us.imagemCaminho = 'images/flags/us.png';
      _en_us.tooltip = ConfigIdioma.ENGLISH_US_TOOLTIP;
      _en_us.corSplash = Colors.blue[900];
      _en_us.idioma = ConfigIdioma.ENGLISH_US;
      _en_us.isSelected = false;

      _es_es.imagemCaminho = 'images/flags/es.png';
      _es_es.tooltip = ConfigIdioma.ESPANOL_ESP_TOOLTIP;
      _es_es.corSplash = Colors.orange[900];
      _es_es.idioma = ConfigIdioma.ESPANOL_ESP;
      _es_es.isSelected = false;

      _de_de.imagemCaminho = 'images/flags/de.png';
      _de_de.tooltip = ConfigIdioma.DEUTSCH_DE_TOOLTIP;
      _de_de.corSplash = Colors.red[900];
      _de_de.idioma = ConfigIdioma.DEUTSCH_DE;
      _de_de.isSelected = false;
      
      _listaIdiomas.add(_pt_br);
      _listaIdiomas.add(_en_us);
      _listaIdiomas.add(_es_es);
      _listaIdiomas.add(_de_de);
    }
    return _listaIdiomas;
  }

  _verificaIdiomaSelecionado() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String idioma = _prefs.getString(SharedPreference.IDIOMA);

    for (int i = 0; i < _listaIdiomas.length; i++) {
      if(_listaIdiomas[i].idioma == idioma) {
        _listaIdiomas[i].isSelected = true;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            height: 62,
            // width: 300,
            child: StreamBuilder(
              stream: _listaIdiomasStream,
              builder: (context, snapshot) {
                return ListView.separated(
                  separatorBuilder: (context, index) => Container(width: 8),
                  itemBuilder: (context, index) {
                    return _idiomaItemBuilder(context, _listaIdiomas[index]);
                  },
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: _listaIdiomas.length,
                );
              }
            ),
          );
        }
      ),
    );
  }

  Widget _idiomaItemBuilder(BuildContext context, IdiomaItemModelo item) {
    return Container(
      height: 62,
      width: 62,
      // padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: item.isSelected ? item.corSplash : Colors.transparent,
      ),
      child: Tooltip(
        message: item.tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          focusColor: item.corSplash,
          highlightColor: item.corSplash,
          splashColor: item.corSplash,
          onTap: () async {
            SharedPreferences _prefs = await SharedPreferences.getInstance();
            if (_prefs.getString(SharedPreference.IDIOMA) != item.idioma) {
              widget.atualizaIdiomaDeEnvio(item.idioma);
              if(widget.atualizaEmBanco) {
                dynamic resultadoRequest = await _locate.alterarIdiomaEmBanco(context: context, idioma: item.idioma);
                // if (resultadoRequest.statusCode == 200) {
                if ((resultadoRequest is Response && resultadoRequest.statusCode == 200)
                  || (resultadoRequest is bool && resultadoRequest == true)) {
                  _prefs.setString(SharedPreference.IDIOMA, item.idioma);
                  CarregandoAlertaComponente().showCarregarSemTexto(context);
                  await widget.atualizaIdioma();
                  CarregandoAlertaComponente().dismissCarregar(context);
                  for(int i = 0; i < _listaIdiomas.length; i++) {
                    _listaIdiomas[i].isSelected = false;
                  }
                  item.isSelected = true;
                  setState(() {});
                }
              }
              else {
                _prefs.setString(SharedPreference.IDIOMA, item.idioma);
                CarregandoAlertaComponente().showCarregarSemTexto(context);
                await widget.atualizaIdioma();
                CarregandoAlertaComponente().dismissCarregar(context);
                for(int i = 0; i < _listaIdiomas.length; i++) {
                  _listaIdiomas[i].isSelected = false;
                }
                item.isSelected = true;
                setState(() {});
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                // shape: BoxShape.rectangle,
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: AssetImage(item.imagemCaminho),
                  fit: BoxFit.fitHeight
                )
              ),
              // child: Image.asset(
              //   'images/flags/br.png',
              // ),
            ),
          ),
        ),
      ),
    );
  }
}
