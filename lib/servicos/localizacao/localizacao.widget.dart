import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/carregando/carregando.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/utils/request.util.dart';
import 'package:provider/provider.dart';

class LocalizacaoWidget extends StatefulWidget {
  final StreamBuilder child;
  final bool exibirOffline;

  LocalizacaoWidget({this.child, this.exibirOffline = true});

  @override
  _LocalizacaoWidgetState createState() => _LocalizacaoWidgetState();
}

class _LocalizacaoWidgetState extends State<LocalizacaoWidget> {
  Stream<dynamic> _streamlocale;
  LocalizacaoServico _locale = new LocalizacaoServico();

  @override
  void initState() {
    super.initState();
    _streamlocale = Stream.fromFuture(_locale.iniciaLocalizacao(context));
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = Provider.of<ConnectivityStatus>(context) != ConnectivityStatus.CONNECTED;
    // Função para Sincronizar quando voltar a ficar online pode ser chamada aqui da seguinte forma:
    // 
    // RequestUtil().verificaOnline()
    //   .then((value) => print("Verificando: $value"));
    // 
    // Apenas Colocar a função dentro do then passando o valor
    return StreamBuilder(
      stream: _streamlocale,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Carregando(),
            );
          default:
            if(!snapshot.hasData) {
              return Center(
                child: Carregando(),
              );
            }
            else {
              // Uso Futuro

              // return Scaffold(
              //   body: widget.child,
              //   bottomNavigationBar: isOffline && widget.exibirOffline
              //     ? Container(
              //       height: 40,
              //       color: Theme.of(context).primaryColor,
              //       child: Center(child: Text(
              //         _locale.locale[TraducaoStringsConstante.Offline],
              //         style: TextStyle(color: Colors.white),
              //       )),
              //     )
              //     : null,
              // );

              // if (widget.exibirOffline) {
              //   return Scaffold(
              //     body: widget.child,
              //     bottomNavigationBar: Container(
              //       height: 40,
              //       color: Theme.of(context).primaryColor,
              //       child: Center(child: Text(
              //         _locale.locale[TraducaoStringsConstante.Offline],
              //         style: TextStyle(color: Colors.white),
              //       )),
              //     ),
              //   );
              // }
              // return widget.child;

              return widget.child;
            }
        }
      },
    );
  }
}

// class CustomOfflineWidget extends StatefulWidget {
//   // final BuildContext context;
//   final Widget child;

//   CustomOfflineWidget({
//     // this.context,
//     this.child
//   });

//   @override
//   _CustomOfflineWidgetState createState() => _CustomOfflineWidgetState();
// }

// class _CustomOfflineWidgetState extends State<CustomOfflineWidget> {
//   LocalizacaoServico _locale = new LocalizacaoServico();

//   @override
//   void initState() { 
//     super.initState();
//     _locale.iniciaLocalizacao(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LocalizacaoWidget(
//       child: StreamBuilder(
//         builder: (context, snapshot) {
//           return ConnectivityWidgetWrapper(
//             child: widget.child,

//             // message: _locale.locale[TraducaoStringsConstante.Offline],
//             // color: Theme.of(context).primaryColor,

//             // stacked: false,
//             // offlineWidget: ListView(
//             //   children: <Widget>[
//             //     Container(child: widget.child),
//             //     Container(
//             //       height: 40,
//             //       color: Theme.of(context).primaryColor,
//             //       child: Center(child: Text(_locale.locale[TraducaoStringsConstante.Offline])),
//             //     )
//             //   ],
//             // ),

//             // disableInteraction: true,
//           );
//         }
//       ),
//     );
//   }
// }

class OfflineMessageWidget extends StatefulWidget {
  @override
  _OfflineMessageWidgetState createState() => _OfflineMessageWidgetState();
}

class _OfflineMessageWidgetState extends State<OfflineMessageWidget> {
  LocalizacaoServico _locate = new LocalizacaoServico();

  @override
  void initState() { 
    super.initState();  
    _locate.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Container(
            height: 40,
            color: Theme.of(context).primaryColor,
            child: Center(child: Text(
              _locate.locale[TraducaoStringsConstante.Offline],
              style: TextStyle(color: Colors.white),
            )),
          );
        }
      ),
    );
  }
}

class CustomOfflineWidget extends StatefulWidget {
  final Widget child;
  final bool disableInteraction;
  final double height;
  final bool disabledIconOnly;
  final double borderRadius;

  CustomOfflineWidget({
    this.child, this.disableInteraction = true, this.height = 40,
    this.disabledIconOnly = false, this.borderRadius
  });

  @override
  _CustomOfflineWidgetState createState() => _CustomOfflineWidgetState();
}

class _CustomOfflineWidgetState extends State<CustomOfflineWidget> {
  LocalizacaoServico _locate = new LocalizacaoServico();

  @override
  void initState() { 
    super.initState();
    _locate.iniciaLocalizacao(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOffline = Provider.of<ConnectivityStatus>(context) != ConnectivityStatus.CONNECTED;

    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              widget.child,
              widget.disableInteraction && isOffline
                ? Column(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(widget.borderRadius ?? 0)
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white70),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: widget.disabledIconOnly
                                ? Icon(Icons.network_check, size: 40, color: Colors.grey[700],)
                                : Text(
                                  _locate.locale[TraducaoStringsConstante.IndisponivelOffline],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                              // Uso Futuro

                              // child: Stack(
                              //   children: <Widget>[
                              //     Text(
                              //       'Esta função está indisponível em offline',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 20,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     Text(
                              //       'Esta função está indisponível em offline',
                              //       style: TextStyle(
                              //         // color: Colors.white,
                              //         fontSize: 20,
                              //         fontWeight: FontWeight.bold,
                              //         foreground: Paint()
                              //           ..style = PaintingStyle.stroke
                              //           ..strokeWidth = 1.5
                              //           ..color = Colors.black,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
                : Container(),
            ],
          );
        }
      ),
    );
  }
}
