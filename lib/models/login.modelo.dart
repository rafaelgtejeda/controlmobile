import 'package:erp/models/empresa.modelo.dart';

class Login {
  String _id;
  bool _successo;
  String _erroCodigo;
  String _erroDescricao;
  Entidade _entidade;
  List<Erros> _erros;

  Login(
      {String id,
      bool successo,
      String erroCodigo,
      String erroDescricao,
      Entidade entidade,
      List<Erros> erros}) {
    this._id = id;
    this._successo = successo;
    this._erroCodigo = erroCodigo;
    this._erroDescricao = erroDescricao;
    this._entidade = entidade;
    this._erros = erros;
  }

  String get id => _id;
  set id(String id) => _id = id;
  bool get successo => _successo;
  set successo(bool successo) => _successo = successo;
  String get erroCodigo => _erroCodigo;
  set erroCodigo(String erroCodigo) => _erroCodigo = erroCodigo;
  String get erroDescricao => _erroDescricao;
  set erroDescricao(String erroDescricao) => _erroDescricao = erroDescricao;
  Entidade get entidade => _entidade;
  set entidade(Entidade entidade) => _entidade = entidade;
  List<Erros> get erros => _erros;
  set erros(List<Erros> erros) => _erros = erros;

  Login.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _successo = json['successo'];
    _erroCodigo = json['erroCodigo'];
    _erroDescricao = json['erroDescricao'];
    _entidade = json['entidade'] != null
        ? new Entidade.fromJson(json['entidade'])
        : null;
    if (json['erros'] != null) {
      _erros = new List<Erros>();
      json['erros'].forEach((v) {
        _erros.add(new Erros.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['successo'] = this._successo;
    data['erroCodigo'] = this._erroCodigo;
    data['erroDescricao'] = this._erroDescricao;
    if (this._entidade != null) {
      data['entidade'] = this._entidade.toJson();
    }
    if (this._erros != null) {
      data['erros'] = this._erros.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entidade {
  List<Empresa> _empresas;
  String _nomeUsuario;
  Token _token;
  int _registroId;
  String _idioma;
  String _fotoPerfil;
  int _usuarioId;
  String _timeZone;
  bool _horarioVeraoNaoAtivo;
  String _login;

  Entidade(
      {List<Empresa> empresas,
      String nomeUsuario,
      Token token,
      int registroId,
      String idioma,
      String fotoPerfil,
      int usuarioId,
      String timeZone,
      bool horarioVeraoNaoAtivo,
      String login}) {
    this._empresas = empresas;
    this._nomeUsuario = nomeUsuario;
    this._token = token;
    this._registroId = registroId;
    this._idioma = idioma;
    this._fotoPerfil = fotoPerfil;
    this._usuarioId = usuarioId;
    this._timeZone = timeZone;
    this._horarioVeraoNaoAtivo = horarioVeraoNaoAtivo;
    this._login = login;
  }

  List<Empresa> get empresas => _empresas;
  set empresas(List<Empresa> empresas) => _empresas = empresas;
  String get nomeUsuario => _nomeUsuario;
  set nomeUsuario(String nomeUsuario) => _nomeUsuario = nomeUsuario;
  Token get token => _token;
  set token(Token token) => _token = token;
  int get registroId => _registroId;
  set registroId(int registroId) => _registroId = registroId;
  String get idioma => _idioma;
  set idioma(String idioma) => _idioma = idioma;
  String get fotoPerfil => _fotoPerfil;
  set fotoPerfil(String fotoPerfil) => _fotoPerfil = fotoPerfil;
  int get usuarioId => _usuarioId;
  set usuarioId(int usuarioId) => _usuarioId = usuarioId;
  String get timeZone => _timeZone;
  set timeZone(String timeZone) => _timeZone = timeZone;
  bool get horarioVeraoNaoAtivo => _horarioVeraoNaoAtivo;
  set horarioVeraoNaoAtivo(bool horarioVeraoNaoAtivo) =>
      _horarioVeraoNaoAtivo = horarioVeraoNaoAtivo;
  String get login => _login;
  set login(String login) => _login = login;

  Entidade.fromJson(Map<String, dynamic> json) {
    if (json['empresas'] != null) {
      _empresas = new List<Empresa>();
      json['empresas'].forEach((v) {
        _empresas.add(new Empresa.fromJson(v));
      });
    }
    _nomeUsuario = json['nomeUsuario'];
    _token = json['token'] != null ? new Token.fromJson(json['token']) : null;
    _registroId = json['registroId'];
    _idioma = json['idioma'];
    _fotoPerfil = json['fotoPerfil'];
    _usuarioId = json['usuarioId'];
    _timeZone = json['timeZone'];
    _horarioVeraoNaoAtivo = json['horarioVeraoNaoAtivo'];
    _login = json['login'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._empresas != null) {
      data['empresas'] = this._empresas.map((v) => v.toJson()).toList();
    }
    data['nomeUsuario'] = this._nomeUsuario;
    if (this._token != null) {
      data['token'] = this._token.toJson();
    }
    data['registroId'] = this._registroId;
    data['idioma'] = this._idioma;
    data['fotoPerfil'] = this._fotoPerfil;
    data['usuarioId'] = this._usuarioId;
    data['timeZone'] = this._timeZone;
    data['horarioVeraoNaoAtivo'] = this._horarioVeraoNaoAtivo;
    data['login'] = this._login;
    return data;
  }
}

// class Empresas {
//   int _id;
//   String _nome;
//   String _nomeFantasia;

//   Empresas({int id, String nome, String nomeFantasia}) {
//     this._id = id;
//     this._nome = nome;
//     this._nomeFantasia = nomeFantasia;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get nome => _nome;
//   set nome(String nome) => _nome = nome;
//   String get nomeFantasia => _nomeFantasia;
//   set nomeFantasia(String nomeFantasia) => _nomeFantasia = nomeFantasia;

//   Empresas.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _nome = json['nome'];
//     _nomeFantasia = json['nomeFantasia'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['nome'] = this._nome;
//     data['nomeFantasia'] = this._nomeFantasia;
//     return data;
//   }
// }

class Token {
  String _dataCriacao;
  String _dataExpiracao;
  String _token;

  Token({String dataCriacao, String dataExpiracao, String token}) {
    this._dataCriacao = dataCriacao;
    this._dataExpiracao = dataExpiracao;
    this._token = token;
  }

  String get dataCriacao => _dataCriacao;
  set dataCriacao(String dataCriacao) => _dataCriacao = dataCriacao;
  String get dataExpiracao => _dataExpiracao;
  set dataExpiracao(String dataExpiracao) => _dataExpiracao = dataExpiracao;
  String get token => _token;
  set token(String token) => _token = token;

  Token.fromJson(Map<String, dynamic> json) {
    _dataCriacao = json['dataCriacao'];
    _dataExpiracao = json['dataExpiracao'];
    _token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dataCriacao'] = this._dataCriacao;
    data['dataExpiracao'] = this._dataExpiracao;
    data['token'] = this._token;
    return data;
  }
}

class Erros {
  String _descricao;
  String _erroDescricao;

  Erros({String descricao, String erroDescricao}) {
    this._descricao = descricao;
    this._erroDescricao = erroDescricao;
  }

  String get descricao => _descricao;
  set descricao(String descricao) => _descricao = descricao;
  String get erroDescricao => _erroDescricao;
  set erroDescricao(String erroDescricao) => _erroDescricao = erroDescricao;

  Erros.fromJson(Map<String, dynamic> json) {
    _descricao = json['descricao'];
    _erroDescricao = json['erroDescricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descricao'] = this._descricao;
    data['erroDescricao'] = this._erroDescricao;
    return data;
  }
}
