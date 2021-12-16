import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:erp/compartilhados/animate/fadein.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:map_launcher/map_launcher.dart' as map_launcher;
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AndamentoMapaOrdemServicoTela extends StatefulWidget {

  final double latitude;
  final double longitude;
  final String endereco;

  AndamentoMapaOrdemServicoTela({Key key, this.latitude, this.longitude, this.endereco}) : super(key: key);

  @override
  _AndamentoMapaOrdemServicoTelaState createState() => _AndamentoMapaOrdemServicoTelaState();
}

class _AndamentoMapaOrdemServicoTelaState extends State<AndamentoMapaOrdemServicoTela> {
  
  LocalizacaoServico _locale = new LocalizacaoServico();
  double latitude = 0;
  double longitude = 0;
  String nomeFantasiaCliente = '';

@override
void initState() { 

  latitude = widget.latitude;
  longitude = widget.longitude;
  nomeFantasiaCliente = widget.endereco;

  super.initState();
   _locale.iniciaLocalizacao(context);
   verificaMapa() ;
}
  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return Container(
      child: LocalizacaoWidget(
      child: StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot){
          return Container(
            // chama o scafold
            child: Scaffold(
              appBar: AppBar(
                title: Text(_locale.locale['EmAndamento']),
              ),
              body: SlidingUpPanel(
                maxHeight: 202,
                panel: iconesApps(context, latitude, longitude),
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      mapa(context, latitude, longitude)
                    ],
                  )
                ),
              ),
              bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
            ),
          );
        },
      ),
    ),
    );
  }

  verificaMapa() async {
    final availableMaps = await map_launcher.MapLauncher.installedMaps;
    print(availableMaps);
  }

  Widget mapa(BuildContext context, latitude, longitude) {

    MediaQueryData queryData;
    queryData = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      height: queryData.size.height,
      child: new FlutterMap(
        options: new MapOptions(
          center: new LatLng(latitude, longitude),
          zoom: 15.0,
          plugins: [],
        ),
        layers: [
          new TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']
          ),
          new MarkerLayerOptions(
            markers: [
              new Marker(
                width: 61.0,
                height: 61.0,
                point: new LatLng(latitude, longitude),
                builder: (ctx) =>
                new Container(
                  child: Image.asset('images/app/pin.png', width: 61.0, height: 61.0,),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget  iconesApps(BuildContext context, latitude, longitude) {
    return Column(
      children: <Widget>[

        SizedBox(height: 12.0,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 30,
                height: 5,
                decoration: BoxDecoration(
                color: Colors.grey[300],
                  borderRadius: BorderRadius.all(Radius.circular(12.0))
                ),
              ),
            ],
          ),

        SizedBox(height: 0.0,),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_locale.locale['EscolhaMelhorOpcao']),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FadeInUp(1, InkWell(
                      onTap: () async {
                        
                         final coords = map_launcher.Coords(latitude, longitude);
                         
                         if (await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google)) {
                              await map_launcher.MapLauncher.showMarker(
                                mapType: map_launcher.MapType.google,
                                coords: coords,
                                title: nomeFantasiaCliente,
                                description: '',
                              );
                            }
                      },
                      child: Column(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset('images/app/icon-google-maps.png', width: 61),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text('Google Maps'),
                          ),
                        ),

                      ],
                    ),
                  )),
                  
                  FadeInUp(2, InkWell(
                      onTap: () async{ 
                        final coords = map_launcher.Coords(latitude, longitude);
                         
                         if (await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.waze)) {
                              await map_launcher.MapLauncher.showMarker(
                                mapType: map_launcher.MapType.waze,
                                coords: coords,
                                title: nomeFantasiaCliente,
                                description: '',
                              );
                            }
                      },
                      child: Column(
                      children: <Widget>[
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset('images/app/icon-waze.png', width: 61),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Text('Waze'),
                          ),
                        ),

                      ],
                    ),
                  ),)
                  

                ],
              ),
            ],
          )
        ),
      ],
    );
  }
}
