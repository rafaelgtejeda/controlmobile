import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/date-filter/date-filter-modal.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateFilterBarComponente extends StatefulWidget {
  final Function onPressed;
  final bool desativarEmOffline;
  DateFilterBarComponente({this.onPressed, this.desativarEmOffline = true, Key key}) : super(key: key);

  @override
  DateFilterBarComponenteState createState() => DateFilterBarComponenteState();
}

class DateFilterBarComponenteState extends State<DateFilterBarComponente> {
  DateTime dataInicial = DateTime.now();
  DateTime dataFinal = DateTime.now();
  LocalizacaoServico _locate = new LocalizacaoServico();

  @override
  void initState() {
    _locate.iniciaLocalizacao(context);
    obtemDatas();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Tooltip(
            message: !_isOnline && widget.desativarEmOffline ? _locate.locale[TraducaoStringsConstante.IndisponivelOffline] : '',
            child: InkWell(
              onTap: () async {
                if(!_isOnline) {
                  if(!widget.desativarEmOffline) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                    );
                    if(result == true){
                      obtemDatas();
                      widget.onPressed();
                      // _streamDashboard = Stream.fromFuture(_fazRequest());
                    }
                  }
                }
                else {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DateFilterModalComponente()),
                  );
                  if(result == true){
                    obtemDatas();
                    widget.onPressed();
                    // _streamDashboard = Stream.fromFuture(_fazRequest());
                  }
                }
              },
              child: Container(
                // color: Colors.red[900],
                height: 48,
                decoration: myBoxDecoration(),
                alignment: Alignment.center,
                child: Text(
                  "${DateFormat.yMd(SharedPreference.IDIOMA).format(dataInicial)} ${_locate.locale[TraducaoStringsConstante.Ate]} ${DateFormat.yMd(SharedPreference.IDIOMA).format(dataFinal)}",
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  BoxDecoration myBoxDecoration(){
    return BoxDecoration(
     // color: Colors.green,
     border: Border(
       top: BorderSide(
         color: Theme.of(context).dividerColor,
         width: 2,
       )
     )
    );
  }

  obtemDatas() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String dataInicio = prefs.getString(SharedPreference.DATA_INICIAL);
    String dataFim = prefs.getString(SharedPreference.DATA_FINAL);
    String idioma = prefs.getString(SharedPreference.IDIOMA);

    setState(() {
      dataInicial = DateTime.parse(dataInicio);
      dataFinal = DateTime.parse(dataFim);
    });
  }
  

}

