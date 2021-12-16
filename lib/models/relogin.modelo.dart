import 'package:erp/models/empresa.modelo.dart';

class ReLoginModelo {
  List<Empresa> empresas;
  String nomeUsuario;
  Token token;
  int registroId;
  String idioma;
  String fotoPerfil;
  int usuarioId;
  String timeZone;
  bool horarioVeraoNaoAtivo;
  String login;

  ReLoginModelo(
      {this.empresas,
      this.nomeUsuario,
      this.token,
      this.registroId,
      this.idioma,
      this.fotoPerfil,
      this.usuarioId,
      this.timeZone,
      this.horarioVeraoNaoAtivo,
      this.login});

  ReLoginModelo.fromJson(Map<String, dynamic> json) {
    if (json['empresas'] != null) {
      empresas = new List<Empresa>();
      json['empresas'].forEach((v) {
        empresas.add(new Empresa.fromJson(v));
      });
    }
    nomeUsuario = json['nomeUsuario'];
    token = json['token'] != null ? new Token.fromJson(json['token']) : null;
    registroId = json['registroId'];
    idioma = json['idioma'];
    fotoPerfil = json['fotoPerfil'];
    usuarioId = json['usuarioId'];
    timeZone = json['timeZone'];
    horarioVeraoNaoAtivo = json['horarioVeraoNaoAtivo'];
    login = json['login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.empresas != null) {
      data['empresas'] = this.empresas.map((v) => v.toJson()).toList();
    }
    data['nomeUsuario'] = this.nomeUsuario;
    if (this.token != null) {
      data['token'] = this.token.toJson();
    }
    data['registroId'] = this.registroId;
    data['idioma'] = this.idioma;
    data['fotoPerfil'] = this.fotoPerfil;
    data['usuarioId'] = this.usuarioId;
    data['timeZone'] = this.timeZone;
    data['horarioVeraoNaoAtivo'] = this.horarioVeraoNaoAtivo;
    data['login'] = this.login;
    return data;
  }
}

class Token {
  String dataCriacao;
  String dataExpiracao;
  String token;

  Token({this.dataCriacao, this.dataExpiracao, this.token});

  Token.fromJson(Map<String, dynamic> json) {
    dataCriacao = json['dataCriacao'];
    dataExpiracao = json['dataExpiracao'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataCriacao'] = this.dataCriacao;
    data['dataExpiracao'] = this.dataExpiracao;
    data['token'] = this.token;
    return data;
  }
}
