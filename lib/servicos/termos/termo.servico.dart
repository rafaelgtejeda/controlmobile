import 'dart:async';
import 'package:erp/utils/request.util.dart';

class TermoServico {

  RequestUtil _request = new RequestUtil();
  int _usuarioId;
  String uuidSP, _playerId;

  Future<dynamic> enviaIdOnesignal() async {

      _usuarioId = await _request.obterIdUsuarioSharedPreferences();
          uuidSP = await _request.obterUUIDSharedPreferences();
       _playerId = await _request.obterIdPlayerOneSignal();
   
    print(_playerId);
    print(uuidSP);

    return _request.postReq(
      endpoint: '/Account/GravarOneSignalId',
      data: {
          'usuarioId': _usuarioId,
               'uuid': uuidSP,
        'oneSignalId': _playerId,
      }
    );

    
  }

}
