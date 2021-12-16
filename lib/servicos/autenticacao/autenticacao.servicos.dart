import 'dart:async';
import 'package:dio/dio.dart';
import 'package:erp/utils/constantes/request.constante.dart';

class AutenticacaoService {
  //->
  Future<dynamic> autenticacao(
    String ddi,
    String telefone,
    int tipoDeEnvio,
    String idioma,
  ) async {
    // ->
    Dio dio = new Dio();
    Response response;

    var data = {
      "ddi": ddi,
      "telefone": telefone,
      "tipoDeEnvio": tipoDeEnvio,
      "idioma": idioma
    };

    try {
      dio.options.connectTimeout = 50000;
      dio.options.receiveTimeout = 30000;
      response = await dio.post(
        Request.BASE_URL + 'Account/Autenticacao',
        data: data,
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
      print("Exception occured: $error, stackTrace: $stacktrace");
      // return UserResponse.withError("$error");
    }
  }

  Future<dynamic> login(
    String ddi,
    String telefone,
    String codigo,
    String idioma,
  ) async {
    // ->
    Dio dio = new Dio();
    Response response;

    var obj = {
      "ddi": ddi,
      "telefone": telefone,
      "codigoAtivacao": codigo,
      "idioma": idioma
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
            print(status);
            return status <= 500;
          },
        ),
      );
      print(response);
      return response;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      // return UserResponse.withError("$error");
    }
  }
}
