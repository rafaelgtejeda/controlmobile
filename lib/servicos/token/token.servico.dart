import 'dart:async';
import 'package:dio/dio.dart';
import 'package:erp/models/token.dart';
import 'package:erp/utils/constantes/request.constante.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenServico {
  //->
  Future<dynamic> renovaToken() async {
    // ->
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // ->
    Dio dio = new Dio();
    Response response;
    print("Token Antigo: ${prefs.getString(SharedPreference.TOKEN)}");
    // ->
    try {
      dio.options.connectTimeout = 50000;
      dio.options.receiveTimeout = 30000;
      response = await dio.get(
        Request.BASE_URL + 'Account/Token',
        queryParameters: {
          "DDI": prefs.getString(SharedPreference.DDI),
          "Telefone": prefs.getString(SharedPreference.TELEFONE),
          "CodigoAtivacao": prefs.getString(SharedPreference.CODIGO),
          "idioma": prefs.getString(SharedPreference.IDIOMA),
        },
        options: Options(
          followRedirects: false,
          receiveDataWhenStatusError: true,
          validateStatus: (status) {
            return status <= 500;
          },
        ),
      );
      Token token = new Token.fromJson(response.data);
      print("Token Novo: ${prefs.getString(SharedPreference.TOKEN)}");
      prefs.setString(SharedPreference.TOKEN, token.entidade.token);
      prefs.setString(
          SharedPreference.TOKEN_DATA_EXPIRACAO, token.entidade.dataExpiracao);
      prefs.setString(
          SharedPreference.TOKEN_DATA_CRIACAO, token.entidade.dataCriacao);

      // ->
       return token.entidade.token;
      // ->
    } catch (error, stacktrace) {
      //->
      // print("Exception occured: $error stackTrace: $stacktrace");
      // return UserResponse.withError("$error");
    }
  }
}
