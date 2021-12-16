import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:erp/compartilhados/componentes/custom-components/custom-components.componente.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/servicos/localizacao/traducao-strings.constante.dart';
import 'package:path_provider/path_provider.dart';

class AssinaturaComponente extends StatefulWidget {
  final int numero;
  final int idObjetoAssinatura;
  AssinaturaComponente({this.idObjetoAssinatura, this.numero});
  @override
  _AssinaturaComponenteState createState() => _AssinaturaComponenteState();
}

class _AssinaturaComponenteState extends State<AssinaturaComponente> {
  LocalizacaoServico _locate = new LocalizacaoServico();

  ByteData _img = ByteData(0);
  final _sign = GlobalKey<SignatureState>();
  File _assinaturaTemporaria = new File('');

  @override
  void initState() {
    super.initState();
    _locate.iniciaLocalizacao(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      exibirOffline: false,
      child: StreamBuilder(builder: (context, snapshot) {
        return Scaffold(
          body: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Signature(
                      color: Colors.black,
                      key: _sign,
                      // onSign: () {
                      //   final sign = _sign.currentState;
                      // },
                      strokeWidth: 3.5,
                    ),
                  ),
                  color: Colors.black12,
                ),
              ),
              _img.buffer.lengthInBytes == 0
                  ? Container()
                  : LimitedBox(
                      maxHeight: 200.0,
                      child: Image.memory(_img.buffer.asUint8List())),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _cancelar(),
                  _limpar(),
                  _salvar(),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _cancelar() {
    return BotaoPadrao(
        funcao: () {
          Navigator.pop(context);
        },
        cor: Colors.red[400],
        child: Texto(_locate.locale['Cancelar'], color: Colors.white));
  }

  Widget _limpar() {
    return BotaoPadrao(
        funcao: () {
          final sign = _sign.currentState;
          sign.clear();
          setState(() {
            _img = ByteData(0);
          });
        },
        cor: Colors.grey,
        child: Texto(_locate.locale['Limpar'], color: Colors.white));
  }

  Widget _salvar() {
    return BotaoPadrao(
        funcao: () async {
          final sign = _sign.currentState;
          final image = await sign.getData();
          var data = await image.toByteData(format: ui.ImageByteFormat.png);
          sign.clear();
          final Directory saida = await getTemporaryDirectory();
          _assinaturaTemporaria = File(
              "${saida.path}/assinatura_${widget.numero}_os_${widget.idObjetoAssinatura}.png");
          await _assinaturaTemporaria.writeAsBytes(data.buffer.asUint8List());
          Navigator.pop(context, _assinaturaTemporaria);
        },
        cor: Colors.green,
        child: Texto(_locate.locale['Salvar'], color: Colors.white));
  }
}
