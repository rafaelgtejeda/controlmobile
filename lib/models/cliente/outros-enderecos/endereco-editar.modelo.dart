class EnderecoEditar {
  int _id;
  int _tipoEndereco;
  String _descricaoTipoEndereco;
  String _descricaoEnderecoOutros;
  String _uf;
  String _cidade;
  String _codigoIBGE;
  String _cep;
  String _endereco;
  String _numero;
  String _complemento;
  String _bairro;
  int _parceiroId;
  int _cidadeEstrangeiroId;

  EnderecoEditar(
      {int id,
      int tipoEndereco,
      String descricaoTipoEndereco,
      String descricaoEnderecoOutros,
      String uf,
      String cidade,
      String codigoIBGE,
      String cep,
      String endereco,
      String numero,
      String complemento,
      String bairro,
      int parceiroId,
      int cidadeEstrangeiroId}) {
    this._id = id;
    this._tipoEndereco = tipoEndereco;
    this._descricaoTipoEndereco = descricaoTipoEndereco;
    this._descricaoEnderecoOutros = descricaoEnderecoOutros;
    this._uf = uf;
    this._cidade = cidade;
    this._codigoIBGE = codigoIBGE;
    this._cep = cep;
    this._endereco = endereco;
    this._numero = numero;
    this._complemento = complemento;
    this._bairro = bairro;
    this._parceiroId = parceiroId;
    this._cidadeEstrangeiroId = cidadeEstrangeiroId;
  }

  int get id => _id;
  set id(int id) => _id = id;
  int get tipoEndereco => _tipoEndereco;
  set tipoEndereco(int tipoEndereco) => _tipoEndereco = tipoEndereco;
  String get descricaoTipoEndereco => _descricaoTipoEndereco;
  set descricaoTipoEndereco(String descricaoTipoEndereco) =>
      _descricaoTipoEndereco = descricaoTipoEndereco;
  String get descricaoEnderecoOutros => _descricaoEnderecoOutros;
  set descricaoEnderecoOutros(String descricaoEnderecoOutros) =>
      _descricaoEnderecoOutros = descricaoEnderecoOutros;
  String get uf => _uf;
  set uf(String uf) => _uf = uf;
  String get cidade => _cidade;
  set cidade(String cidade) => _cidade = cidade;
  String get codigoIBGE => _codigoIBGE;
  set codigoIBGE(String codigoIBGE) => _codigoIBGE = codigoIBGE;
  String get cep => _cep;
  set cep(String cep) => _cep = cep;
  String get endereco => _endereco;
  set endereco(String endereco) => _endereco = endereco;
  String get numero => _numero;
  set numero(String numero) => _numero = numero;
  String get complemento => _complemento;
  set complemento(String complemento) => _complemento = complemento;
  String get bairro => _bairro;
  set bairro(String bairro) => _bairro = bairro;
  int get parceiroId => _parceiroId;
  set parceiroId(int parceiroId) => _parceiroId = parceiroId;
  int get cidadeEstrangeiroId => _cidadeEstrangeiroId;
  set cidadeEstrangeiroId(int cidadeEstrangeiroId) =>
      _cidadeEstrangeiroId = cidadeEstrangeiroId;

  EnderecoEditar.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _tipoEndereco = json['tipoEndereco'];
    _descricaoTipoEndereco = json['descricaoTipoEndereco'];
    _descricaoEnderecoOutros = json['descricaoEnderecoOutros'];
    _uf = json['uf'];
    _cidade = json['cidade'];
    _codigoIBGE = json['codigoIBGE'];
    _cep = json['cep'];
    _endereco = json['endereco'];
    _numero = json['numero'];
    _complemento = json['complemento'];
    _bairro = json['bairro'];
    _parceiroId = json['parceiroId'];
    _cidadeEstrangeiroId = json['cidadeEstrangeiroId'];
  }

  Map<String, dynamic> novoEnderecoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipoEndereco'] = this._tipoEndereco;
    data['descricaoEnderecoOutros'] = this._descricaoEnderecoOutros;
    data['uf'] = this._uf;
    data['cidade'] = this._cidade;
    data['codigoIBGE'] = this._codigoIBGE;
    data['cep'] = this._cep;
    data['endereco'] = this._endereco;
    data['numero'] = this._numero;
    data['complemento'] = this._complemento;
    data['bairro'] = this._bairro;
    data['parceiroId'] = this._parceiroId;
    data['cidadeEstrangeiroId'] = this._cidadeEstrangeiroId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['tipoEndereco'] = this._tipoEndereco;
    data['descricaoTipoEndereco'] = this._descricaoTipoEndereco;
    data['descricaoEnderecoOutros'] = this._descricaoEnderecoOutros;
    data['uf'] = this._uf;
    data['cidade'] = this._cidade;
    data['codigoIBGE'] = this._codigoIBGE;
    data['cep'] = this._cep;
    data['endereco'] = this._endereco;
    data['numero'] = this._numero;
    data['complemento'] = this._complemento;
    data['bairro'] = this._bairro;
    data['parceiroId'] = this._parceiroId;
    data['cidadeEstrangeiroId'] = this._cidadeEstrangeiroId;
    return data;
  }
}
