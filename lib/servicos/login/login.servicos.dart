import 'dart:async';
import 'package:dio/dio.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/request.util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  //->
  String _deviceModel;
  String _uuidV4;

  RequestUtil _request = new RequestUtil();

  Future<dynamic> login(String codigo) async {
    // ->
    Dio dio = new Dio();
    Response response;
    // ->

    _deviceModel = await _request.getDeviceModel();
    _uuidV4 = await _request.getUUID();

    SharedPreferences _prefs = await SharedPreferences.getInstance();

    _prefs.setString(SharedPreference.UUID, _uuidV4.toString());
    _prefs.setString(SharedPreference.DEVICEMODEL, _deviceModel.toString());

    String ddi = _prefs.getString(SharedPreference.DDI);
    String telefone = _prefs.getString(SharedPreference.TELEFONE);
    String idioma = _prefs.getString(SharedPreference.IDIOMA);

    var obj = {
      "ddi": ddi,
      "telefone": telefone,
      "codigoAtivacao": codigo,
      "idioma": idioma,
      "modeloCelular": _deviceModel,
      "uuid": _uuidV4
    };

    try {
      dio.options.connectTimeout = 50000;
      dio.options.receiveTimeout = 30000;
      response = await dio.post(
        Request.BASE_URL + Endpoints.ACCOUNT_LOGIN,
        data: obj,
        options: Options(
          followRedirects: false,
          receiveDataWhenStatusError: true,
          validateStatus: (status) {
            return status <= 500;
          },
        ),
      );
      return response;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      // return UserResponse.withError("$error");
    }
  }
}
