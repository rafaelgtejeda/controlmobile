class Token {
  String _id;
  bool _successo;
  String _erroCodigo;
  String _erroDescricao;
  Entidade _entidade;
  List<Erros> _erros;

  Token(
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

  Token.fromJson(Map<String, dynamic> json) {
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
  String _dataCriacao;
  String _dataExpiracao;
  String _token;

  Entidade({String dataCriacao, String dataExpiracao, String token}) {
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

  Entidade.fromJson(Map<String, dynamic> json) {
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
