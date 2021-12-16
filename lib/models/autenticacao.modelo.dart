class Autenticacao {
  bool _successo;
  String _erroCodigo;

  Autenticacao({bool successo, String erroCodigo}) {
    this._successo = successo;
    this._erroCodigo = erroCodigo;
  }

  bool get successo => _successo;
  set successo(bool successo) => _successo = successo;
  String get erroCodigo => _erroCodigo;
  set erroCodigo(String erroCodigo) => _erroCodigo = erroCodigo;

  Autenticacao.fromJson(Map<String, dynamic> json) {
    _successo = json['successo'];
    _erroCodigo = json['erroCodigo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['successo'] = this._successo;
    data['erroCodigo'] = this._erroCodigo;
    return data;
  }
}
