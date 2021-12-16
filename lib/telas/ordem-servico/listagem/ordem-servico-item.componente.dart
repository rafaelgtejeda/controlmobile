import 'package:flutter/material.dart';
import 'package:erp/models/os/osProximosChamados.modelo.dart';
import 'package:erp/utils/helper.dart';
import 'package:intl/intl.dart';

class OrdemServicoItemComponente extends StatefulWidget {
  
  // final String data;
  // final int quantidade;
  // final int status;

  final OsProximosChamados item;

  // OrdemServicoItemComponente({this.data, this.quantidade, this.status});

  OrdemServicoItemComponente({this.item});

  @override
  _OrdemServicoItemComponenteState createState() => _OrdemServicoItemComponenteState();
}

class _OrdemServicoItemComponenteState extends State<OrdemServicoItemComponente> {
  
  String diaSemana;
  String dia;
  String mes;
  String ano;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 100,
      width: double.infinity,
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: <Widget>[
                Container(
                  width: 65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        dia,
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          
                        ),
                      ),
                      Text(
                        diaSemana,
                        style: TextStyle(
                          fontSize: 12,
                          
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  width: 35,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      mes,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        ano,
                        style: TextStyle(
                          fontSize: 12,
                          
                        ),
                      ),
                    )
                  ],
                ),
                Spacer(),
                Container(
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(
                        
                        fontSize: 24,
                      ),
                    ),
                  ),
                  height: 55,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  _formataData(String data) {
    Helper helper = new Helper();
    // data = "2019-12-18T03:00:00.000Z";

    int diaFormat = DateTime.parse(data).day;
    String diaSemanaFormat = DateFormat('EEEE').format(DateTime.parse(data)).replaceAll("-feira", "");
    String mesFormat = DateFormat('MMMM').format(DateTime.parse(data));
    int anoFormat = DateTime.parse(data).year;

    dia = diaFormat.toString();
    diaSemana = helper.capitalize(input: diaSemanaFormat);
    mes = helper.capitalize(input: mesFormat);
    ano = anoFormat.toString();
  }

  _verificaStatus(int status) {
    MaterialColor cor;
    switch (status) {
      case 0:
        cor = Colors.green;
        break;
      case 1:
        cor = Colors.orange;
        break;
      case 2:
        cor = Colors.red[900];
        break;
      default:
        cor = Colors.grey;
    }
    return cor;
  }
}