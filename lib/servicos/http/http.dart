import 'package:dio/dio.dart';

//import 'package:erp/servicos/empresa/interceptors.dart';

import 'package:erp/utils/constantes/request.constante.dart';

 class CustomHttp {  
  final Dio client;
  CustomHttp(this.client) {

    var baseUrl = Request.BASE_URL;
    client.options.baseUrl = baseUrl;

    //CustomInterceptors refreshFlow = CustomInterceptors();
    //client.interceptors.add(refreshFlow);

    client.options.connectTimeout = 50000;
    client.options.receiveTimeout = 30000;

  }

}
