class TiposEnderecosLookUp {
  int _codigo;
  String _descricao;

  TiposEnderecosLookUp({int codigo, String descricao}) {
    this._codigo = codigo;
    this._descricao = descricao;
  }

  int get codigo => _codigo;
  set codigo(int codigo) => _codigo = codigo;
  String get descricao => _descricao;
  set descricao(String descricao) => _descricao = descricao;

  TiposEnderecosLookUp.fromJson(Map<String, dynamic> json) {
    _codigo = json['codigo'];
    _descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codigo'] = this._codigo;
    data['descricao'] = this._descricao;
    return data;
  }
}
