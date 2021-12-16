import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  static const String DDI = "ddi";
  static const String TELEFONE = "telefone";

  static const String IDIOMA = "idioma";
  static const String CODIGO = "codigo";

  static const String DEVICEMODEL = "deviceModel";

  static const String NOME_USUARIO = "nomeUsuario";
  static const String USUARIO_ID = "usuarioId";
  static const String FOTO_PERFIL = "fotoPerfil";

  static const String BLOQUEAR_APLICATIVO = "bloquearAplicativo";
  static const String SENHA_BLOQUEIO = "senhaBloqueio";
  static const String MODO_BACKGROUND = "modoBackground";

  static const String TOKEN = "token";
  static const String UUID = "UUID";

  static const String TOKEN_DATA_EXPIRACAO = "dataExpiracao";
  static const String TOKEN_DATA_CRIACAO = "dataCriacao";

  static const String USUARIO_AUTENTICADO = "usuarioAutenticado";

  static const String REGISTRO_ID = "registroId";
  static const String EMPRESA_ID = "empresaId";
  static const String EMPRESA_NOME_FANTASIA = "nomeFantasia";
  static const String DIRETIVAS_ACESSO = "diretivasAcesso";

  static const String PUSH_NOTIFICATION = "pushNotification";

  static const String DATA_INICIAL = "dataInicial";
  static const String DATA_FINAL = "dataFinal";

  static const String APP = "app";
  static const String TEMA = "tema";
  static const String LOGO = "logo";
  static const String LOGOSPLASHLight = "logoSplashLight";
  static const String LOGOSPLASHDark = "logoSplashLight";
  static const String LOGOSPLASH = "logoSplash";

  static const String CONTAS_SELECIONADAS = "contasSelecionadas";

  clearStorage() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove(SharedPreference.DDI);
    _prefs.remove(SharedPreference.TELEFONE);
    _prefs.remove(SharedPreference.IDIOMA);
    _prefs.remove(SharedPreference.CODIGO);
    _prefs.remove(SharedPreference.DEVICEMODEL);
    _prefs.remove(SharedPreference.NOME_USUARIO);
    _prefs.remove(SharedPreference.USUARIO_ID);
    _prefs.remove(SharedPreference.FOTO_PERFIL);
    _prefs.remove(SharedPreference.BLOQUEAR_APLICATIVO);
    _prefs.remove(SharedPreference.SENHA_BLOQUEIO);
    _prefs.remove(SharedPreference.MODO_BACKGROUND);
    _prefs.remove(SharedPreference.TOKEN);
    _prefs.remove(SharedPreference.UUID);
    _prefs.remove(SharedPreference.TOKEN_DATA_EXPIRACAO);
    _prefs.remove(SharedPreference.TOKEN_DATA_CRIACAO);
    _prefs.remove(SharedPreference.USUARIO_AUTENTICADO);
    _prefs.remove(SharedPreference.REGISTRO_ID);
    _prefs.remove(SharedPreference.EMPRESA_ID);
    _prefs.remove(SharedPreference.EMPRESA_NOME_FANTASIA);
    _prefs.remove(SharedPreference.DIRETIVAS_ACESSO);
    _prefs.remove(SharedPreference.PUSH_NOTIFICATION);
    _prefs.remove(SharedPreference.DATA_INICIAL);
    _prefs.remove(SharedPreference.DATA_FINAL);
    _prefs.remove(SharedPreference.CONTAS_SELECIONADAS);
  }
}
