class ParqueEditar {
  int _id;
  String _descricaoProduto;
  String _descricaoMarca;
  String _descricaoModelo;
  String _numeroDeSerie;
  double _quantidade;
  String _observacao;
  String _dataInstalacao;
  int _produtoId;
  int _parceiroId;
  int _empresaId;
  String _descricaoEquipamento;

  ParqueEditar(
      {int id,
      String descricaoProduto,
      String descricaoMarca,
      String descricaoModelo,
      String numeroDeSerie,
      double quantidade,
      String observacao,
      String dataInstalacao,
      int produtoId,
      int parceiroId,
      int empresaId,
      String descricaoEquipamento}) {
    this._id = id;
    this._descricaoProduto = descricaoProduto;
    this._descricaoMarca = descricaoMarca;
    this._descricaoModelo = descricaoModelo;
    this._numeroDeSerie = numeroDeSerie;
    this._quantidade = quantidade;
    this._observacao = observacao;
    this._dataInstalacao = dataInstalacao;
    this._produtoId = produtoId;
    this._parceiroId = parceiroId;
    this._empresaId = empresaId;
    this._descricaoEquipamento = descricaoEquipamento;
  }

  int get id => _id;
  set id(int id) => _id = id;
  String get descricaoProduto => _descricaoProduto;
  set descricaoProduto(String descricaoProduto) =>
      _descricaoProduto = descricaoProduto;
  String get descricaoMarca => _descricaoMarca;
  set descricaoMarca(String descricaoMarca) => _descricaoMarca = descricaoMarca;
  String get descricaoModelo => _descricaoModelo;
  set descricaoModelo(String descricaoModelo) =>
      _descricaoModelo = descricaoModelo;
  String get numeroDeSerie => _numeroDeSerie;
  set numeroDeSerie(String numeroDeSerie) => _numeroDeSerie = numeroDeSerie;
  double get quantidade => _quantidade;
  set quantidade(double quantidade) => _quantidade = quantidade;
  String get observacao => _observacao;
  set observacao(String observacao) => _observacao = observacao;
  String get dataInstalacao => _dataInstalacao;
  set dataInstalacao(String dataInstalacao) => _dataInstalacao = dataInstalacao;
  int get produtoId => _produtoId;
  set produtoId(int produtoId) => _produtoId = produtoId;
  int get parceiroId => _parceiroId;
  set parceiroId(int parceiroId) => _parceiroId = parceiroId;
  int get empresaId => _empresaId;
  set empresaId(int empresaId) => _empresaId = empresaId;
  String get descricaoEquipamento => _descricaoEquipamento;
  set descricaoEquipamento(String descricaoEquipamento) =>
      _descricaoEquipamento = descricaoEquipamento;

  ParqueEditar.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _descricaoProduto = json['descricaoProduto'];
    _descricaoMarca = json['descricaoMarca'];
    _descricaoModelo = json['descricaoModelo'];
    _numeroDeSerie = json['numeroDeSerie'];
    _quantidade = json['quantidade'];
    _observacao = json['observacao'];
    _dataInstalacao = json['dataInstalacao'];
    _produtoId = json['produtoId'];
    _parceiroId = json['parceiroId'];
    _empresaId = json['empresaId'];
    _descricaoEquipamento = json['descricaoEquipamento'];
  }

  Map<String, dynamic> novoParqueTecnologicoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descricaoProduto'] = this._descricaoProduto;
    data['descricaoMarca'] = this._descricaoMarca;
    data['descricaoModelo'] = this._descricaoModelo;
    data['numeroDeSerie'] = this._numeroDeSerie;
    data['quantidade'] = this._quantidade;
    data['observacao'] = this._observacao;
    data['dataInstalacao'] = this._dataInstalacao;
    data['produtoId'] = this._produtoId;
    data['parceiroId'] = this._parceiroId;
    data['empresaId'] = this._empresaId;
    data['descricaoEquipamento'] = this._descricaoEquipamento;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['descricaoProduto'] = this._descricaoProduto;
    data['descricaoMarca'] = this._descricaoMarca;
    data['descricaoModelo'] = this._descricaoModelo;
    data['numeroDeSerie'] = this._numeroDeSerie;
    data['quantidade'] = this._quantidade;
    data['observacao'] = this._observacao;
    data['dataInstalacao'] = this._dataInstalacao;
    data['produtoId'] = this._produtoId;
    data['parceiroId'] = this._parceiroId;
    data['empresaId'] = this._empresaId;
    data['descricaoEquipamento'] = this._descricaoEquipamento;
    return data;
  }
}
