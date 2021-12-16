import 'dart:io';
import 'dart:async';
import 'package:erp/servicos/token/token.servico.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class RequestService {
  // ->
  Future<dynamic> executaRequest(endpoint, method, data, params) async {
    // ->
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ->
    Dio dio = new Dio();
    Response response;
    // ->
    TokenServico api = new TokenServico();
    // ->
    String baseURL = Request.BASE_URL;
    String token = prefs.getString(SharedPreference.TOKEN);
    String dataExpiracao =
        prefs.getString(SharedPreference.TOKEN_DATA_EXPIRACAO);

    DateTime dataAtual = new DateTime.now();

    if (dataExpiracao != null &&
        dataAtual.isAfter(DateTime.parse(dataExpiracao))) {}

    if (params) {}

    if (method == Request.GET) {
      // ->
      try {
        // ->
        dio.options.connectTimeout = 50000;
        dio.options.receiveTimeout = 30000;
        // ->
        response = await dio.get(
          // ->
          baseURL + endpoint,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              HttpHeaders.authorizationHeader: 'Bearer ' + token,
            },
            followRedirects: false,
            receiveDataWhenStatusError: true,
            validateStatus: (status) {
              print(status);
              return status <= 500;
            },
          ),
          // ->
        );
        // ->
        if (response.statusCode == 401) {
          // ->
          api.renovaToken();
          // ->
          try {
            // ->
            String novoToken = prefs.getString(SharedPreference.TOKEN);
            // ->
            dio.options.connectTimeout = 50000;
            dio.options.receiveTimeout = 30000;
            // ->
            response = await dio.get(
              baseURL + endpoint,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  HttpHeaders.authorizationHeader: 'Bearer ' + novoToken,
                },
                followRedirects: false,
                receiveDataWhenStatusError: true,
                validateStatus: (status) {
                  return status <= 500;
                },
              ),
            );
            // ->
            return response;
            // ->
          } catch (error, stacktrace) {
            print("Exception occured: $error stackTrace: $stacktrace");
          }
          // ->
        }
        // ->
        if (response.statusCode == 200) {
          return response;
        }
        // ->
      } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        // return UserResponse.withError("$error");
      }
      // ->
    }

    if (method == Request.GET && params != null) {
      // ->
      try {
        // ->
        dio.options.connectTimeout = 50000;
        dio.options.receiveTimeout = 30000;
        // ->
        response = await dio.get(
          // ->
          baseURL + endpoint,
          queryParameters: null,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              HttpHeaders.authorizationHeader: 'Bearer ' + token,
            },
            followRedirects: false,
            receiveDataWhenStatusError: true,
            validateStatus: (status) {
              print(status);
              return status <= 500;
            },
          ),
          // ->
        );
        // ->

        // ->
        if (response.statusCode == 401) {
          // ->
          api.renovaToken();
          // ->

          // ->
          try {
            // ->
            String novoToken = prefs.getString(SharedPreference.TOKEN);
            // ->
            dio.options.connectTimeout = 50000;
            dio.options.receiveTimeout = 30000;
            // ->
            response = await dio.get(
              baseURL + endpoint,
              options: Options(
                headers: {
                  'Content-Type': 'application/json',
                  HttpHeaders.authorizationHeader: 'Bearer ' + novoToken,
                },
                followRedirects: false,
                receiveDataWhenStatusError: true,
                validateStatus: (status) {
                  return status <= 500;
                },
              ),
            );
            // ->
            return response;
            // ->
          } catch (error, stacktrace) {
            print("Exception occured: $error stackTrace: $stacktrace");
          }
          // ->
        }
        // ->
        if (response.statusCode == 200) {
          return response;
        }
        // ->
      } catch (error, stacktrace) {
        print("Exception occured: $error stackTrace: $stacktrace");
        // return UserResponse.withError("$error");
      }
      // ->
    }
    // ->
  }
}
