
import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/models/os/gri-OS-agendada.modelo.dart';
import 'package:erp/models/os/reagendar.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:erp/utils/request.util.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/ordem-servico/ordem-servico.servicos.dart';

class ReagendarTela extends StatefulWidget {
  
  final GridOSAgendadaModelo gridOS;

  const ReagendarTela({Key key, this.gridOS}) : super(key: key);
  
  @override
  _ReagendarTelaState createState() => _ReagendarTelaState();

}

class _ReagendarTelaState extends State<ReagendarTela> {
  
  final TextEditingController motivoController = TextEditingController();
  
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  
  Reagendar reagendar = new Reagendar();
  RequestUtil _requestUtil = new RequestUtil();
  LocalizacaoServico _locate = new LocalizacaoServico();
  
  bool _autoValidacao = false;
  int _usuarioID;

  GridOSAgendadaModelo itemOS;

  String osHoraInicio;
  String osHoraFinal;

  DateTime hoje = DateTime.now();
  DateTime _dataFinal = DateTime.now();
  DateTime _dataInicial = DateTime.now();

  TimeOfDay _horaFinal = new TimeOfDay.now();
  TimeOfDay _horaInicial = new TimeOfDay.now();

  @override
  void initState() {

    super.initState();

           itemOS = widget.gridOS;
    osHoraInicio  = itemOS.horaInicio;
     osHoraFinal  = itemOS.horaFim;
     
     _locate.iniciaLocalizacao(context);

     _horaInicial = stringToTimeOfDay(osHoraInicio);
       _horaFinal = stringToTimeOfDay(osHoraFinal);

      _getUsuarioId();
      _carregaDatas();

  }
  
  Future<void> _getUsuarioId() async {
    int usuarioID;
    usuarioID = await _requestUtil.obterIdUsuarioSharedPreferences();
    _usuarioID = usuarioID;
  }

  Future<Null>selecionaDataInicial(BuildContext context) async {
    final DateTime selecionadoInicial = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataInicial
    );

    if (selecionadoInicial != null && selecionadoInicial != _dataInicial) {
      setState(() {
        _dataInicial = selecionadoInicial;
      });
    }
  }

  Future<Null>selecionaDataFinal(BuildContext context) async {
    final DateTime selecionadoFinal = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: _dataFinal
    );

    if (selecionadoFinal != null && selecionadoFinal != _dataFinal) {
      setState(() {
        _dataFinal = selecionadoFinal;
      });
    }
  }

  Future<Null>selecionaHoraInicial(BuildContext context) async {

    final TimeOfDay selecionadoHoraInicial = await showTimePicker(
      context: context,
      initialTime: _horaInicial
    );

    if (selecionadoHoraInicial != null && selecionadoHoraInicial != _horaInicial) {
      setState(() {
        _horaInicial = selecionadoHoraInicial;
      });
    }

  }

  Future<Null>selecionaHoraFinal(BuildContext context) async {
    
    final TimeOfDay selecionadoHoraFinal = await showTimePicker(
     context: context,
     initialTime: _horaFinal
    );

    if (selecionadoHoraFinal != null && selecionadoHoraFinal != _horaFinal) {
      setState(() {
        _horaFinal = selecionadoHoraFinal;
      });
    }

  }

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  _carregaDatas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _dataInicial = DateTime.now();
      _dataFinal = DateTime.now();
    });
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        initialData: '',
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Container(
            // chama o scafold
            child: 
              Scaffold(
                key: scaffoldKey,
                appBar: AppBar(
                  title: Text(
                    '${_locate.locale["Reagendar"]}'.toUpperCase(),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      child: Form(
                        key: formKey,
                        autovalidate: _autoValidacao,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _dataIconeComponent(
                                  texto: '${_locate.locale["DataInicial"]}',
                                  data: DateFormat.yMd().format(DateTime.parse(_dataInicial.toString())),
                                  funcao: () {selecionaDataInicial(context);}
                                ),
                                _dataIconeComponent(
                                  texto: '${_locate.locale["DataFinal"]}',
                                  data: DateFormat.yMd().format(DateTime.parse(_dataFinal.toString())),
                                  funcao: () {selecionaDataFinal(context);}
                                ),
                              ],
                            ),
                            Container(
                              child: Text('${_locate.locale["Horario"]}',
                                      style: TextStyle(         
                                        fontSize: 18 * MediaQuery.of(context).textScaleFactor,                  
                                      ))
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                _horaIconeComponent(
                                  texto: '',
                                  data: '${_horaInicial.format(context)}',
                                  funcao: () {selecionaHoraInicial(context);}
                                ),
                                _horaIconeComponent(
                                  texto: '',
                                  data: '${_horaFinal.format(context)}',
                                  funcao: () {selecionaHoraFinal(context);}
                                ),
                              ],
                            ),

                            SizedBox(height: 0),

                            Container(
                              child: Text('${_locate.locale["DescrevaMotivo"]}',
                                      style: TextStyle(         
                                        fontSize: 18 * MediaQuery.of(context).textScaleFactor,                  
                                      )),
                            ),

                            SizedBox(height: 0),

                            _inputMotivo(),

                            SizedBox(height: 10),

                            _btnAgendar(),
                            
                            SizedBox(height: 0),
                            
                        ],
                    ),
                  ),
                  ),
                ),
              ),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            )
          );
        },
      ),
    );
  }

  Widget _inputMotivo(){
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: TextFormField(
          controller: motivoController,
          keyboardType: TextInputType.multiline,
          maxLines: 4,
          validator: (input) {
            if (input.isNotEmpty) {
              return null;
            } else {
              return "${_locate.locale['MotivoValidacao']}";
            }
          },
          onSaved: (input) => {} ,
        ),
      ),
    );
  }

  Widget _btnAgendar() {
    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(40),
          child: InkWell(
            borderRadius: BorderRadius.circular(40),
            onTap: () {_submit(funcao: (){Navigator.pop(context, true);});},
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Center(
                child: Text(
                  '${_locate.locale["Agendar"]}'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * MediaQuery.of(context).textScaleFactor,                  
                  ),
                ),
              ),
            ),
          ),
        )
      ),
    );
  }

  Widget _dataIconeComponent({@required String texto, @required String data, @required Function funcao}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28)
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: funcao,
              child: Container(
                padding: EdgeInsets.only(top: 40, bottom: 10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12,),
                    Text(
                      texto,
                      style: TextStyle(
                        fontSize: 16 * MediaQuery.of(context).textScaleFactor, 
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 0),

          Container(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: funcao,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28)
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  data,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _horaIconeComponent({@required String texto, @required String data, @required Function funcao}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28)
            ),
          ),
          SizedBox(height: 0,),
          Container(
            child: InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: funcao,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28)
                ),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Text(
                  data,
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontSize: 16 * MediaQuery.of(context).textScaleFactor,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _submit({Function funcao}) {

    if (formKey.currentState.validate()) {
      
      formKey.currentState.save();
      
      String diaInicio = _dataInicial.day.toString();
      String mesInicio = _dataInicial.month.toString();
      String anoInicio = _dataInicial.year.toString();

      String horaInicio = _horaInicial.hour.toString();
      String minutoInicio = _horaInicial.minute.toString();

      String _dataIn = DateTime.utc(
        int.parse(anoInicio), 
        int.parse(mesInicio), 
        int.parse(diaInicio),
        int.parse(horaInicio),
        int.parse(minutoInicio),
      ).toString();

      String diaFim = _dataFinal.day.toString();
      String mesFim = _dataFinal.month.toString();
      String anoFim = _dataFinal.year.toString();

      String horaFim = _horaFinal.hour.toString();
      String minutoFim = _horaFinal.minute.toString();

      String _dataFim = DateTime.utc(
        int.parse(anoFim), 
        int.parse(mesFim), 
        int.parse(diaFim),
        int.parse(horaFim),
        int.parse(minutoFim),
      ).toString();

      if(DateTime.parse(_dataFim).isBefore(DateTime.parse(_dataIn))) {
        _showSnackBar(_locate.locale['PeriodoDataInvalido']);
      }
      else {
        reagendar.osId = itemOS.osId;
        reagendar.osxTecId = itemOS.id;
        reagendar.motivo = motivoController.text;
        reagendar.dataIn =  _dataIn;
        reagendar.dataFim = _dataFim;
        reagendar.usuarioId = _usuarioID;
        
        _salvar(funcao: () => funcao());
      }


    } else {
      setState(() {
        _autoValidacao = true;
      });
    }

  }

  _salvar({@required Function funcao}) {

    String data = json.encode(reagendar.toJson());
      OrdemServicoService().reagendar(data, context: context)
        .then((data) {
          funcao();
        });

  }

}
