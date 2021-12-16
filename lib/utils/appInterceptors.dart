
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:erp/servicos/token/token.servico.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInterceptors extends Interceptor {
  Dio dio = new Dio();
  @override
  Future<dynamic> onRequest(RequestOptions options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(SharedPreference.TOKEN);
    options.headers.addAll(
      {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      }
    );
    return options;
  }
  
  @override
  Future onError(DioError dioError) {
    TokenServico api = new TokenServico();
    dio.interceptors.requestLock.lock();
    dio.interceptors.responseLock.lock();
    api.renovaToken();
    dio.interceptors.requestLock.unlock();
    dio.interceptors.responseLock.unlock();
    return super.onError(dioError);
  }

  @override
  Future onResponse(Response options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dataExpiracaoToken = prefs.getString(SharedPreference.TOKEN_DATA_EXPIRACAO);

    if (DateTime.now().isAfter(DateTime.parse(dataExpiracaoToken))) {
      return DioError();
    }
    if (options.statusCode == 401) {
      return DioError(response: options);
    }
    return super.onResponse(options);
  }
}
