import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:erp/models/cliente/cobranca-pagamento/email-sms.modelo.dart';
import 'package:erp/utils/request.util.dart';

class EmailSMSService {
  RequestUtil _request = new RequestUtil();
  int _empresaId;
  int _usuarioId;

  EmailSMS _emailSMS = new EmailSMS();

  Future<dynamic> enviarEmailSMS({int area = 11, bool customizado = false, BuildContext context}) async {
    _empresaId = await _request.obterIdEmpresaShared();
    _usuarioId = await _request.obterIdUsuarioSharedPreferences();

    _emailSMS.area = area;
    _emailSMS.customizado = customizado;
    _emailSMS.empresaId = _empresaId;
    _emailSMS.manutencaoId = _usuarioId;

    String _emailSMSJson = json.encode(_emailSMS.toJson());
    return _request.postReq(
      endpoint: 'EmailSMS/Enviar',
      data: _emailSMSJson,
      loading: true,
      context: context
    );
  }
}
