class ParqueGrid {
  int id;
  String descricaoProduto;
  String descricaoMarca;
  String descricaoModelo;
  String descricaoEquipamento;
  String numeroDeSerie;
  double quantidade;
  String observacao;
  String dataInstalacao;
  bool isSelected = false;

  ParqueGrid(
      {this.id,
      this.descricaoProduto,
      this.descricaoMarca,
      this.descricaoModelo,
      this.descricaoEquipamento,
      this.numeroDeSerie,
      this.quantidade,
      this.observacao,
      this.dataInstalacao});

  ParqueGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricaoProduto = json['descricaoProduto'];
    descricaoMarca = json['descricaoMarca'];
    descricaoModelo = json['descricaoModelo'];
    descricaoEquipamento = json['descricaoEquipamento'];
    numeroDeSerie = json['numeroDeSerie'];
    quantidade = json['quantidade'];
    observacao = json['observacao'];
    dataInstalacao = json['dataInstalacao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricaoProduto'] = this.descricaoProduto;
    data['descricaoMarca'] = this.descricaoMarca;
    data['descricaoModelo'] = this.descricaoModelo;
    data['descricaoEquipamento'] = this.descricaoEquipamento;
    data['numeroDeSerie'] = this.numeroDeSerie;
    data['quantidade'] = this.quantidade;
    data['observacao'] = this.observacao;
    data['dataInstalacao'] = this.dataInstalacao;
    return data;
  }
}



// class ParqueGrid {
//   int _id;
//   String _descricaoProduto;
//   String _descricaoMarca;
//   String _descricaoModelo;
//   String _descricaoEquipamento;
//   String _numeroDeSerie;
//   double _quantidade;
//   String _observacao;
//   String _dataInstalacao;

//   ParqueGrid(
//       {int id,
//       String descricaoProduto,
//       String descricaoMarca,
//       String descricaoModelo,
//       String descricaoEquipamento,
//       String numeroDeSerie,
//       double quantidade,
//       String observacao,
//       String dataInstalacao}) {
//     this._id = id;
//     this._descricaoProduto = descricaoProduto;
//     this._descricaoMarca = descricaoMarca;
//     this._descricaoModelo = descricaoModelo;
//     this._descricaoEquipamento = descricaoEquipamento;
//     this._numeroDeSerie = numeroDeSerie;
//     this._quantidade = quantidade;
//     this._observacao = observacao;
//     this._dataInstalacao = dataInstalacao;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get descricaoProduto => _descricaoProduto;
//   set descricaoProduto(String descricaoProduto) =>
//       _descricaoProduto = descricaoProduto;
//   String get descricaoMarca => _descricaoMarca;
//   set descricaoMarca(String descricaoMarca) => _descricaoMarca = descricaoMarca;
//   String get descricaoModelo => _descricaoModelo;
//   set descricaoModelo(String descricaoModelo) =>
//       _descricaoModelo = descricaoModelo;
//   String get descricaoEquipamento => _descricaoEquipamento;
//   set descricaoEquipamento(String descricaoEquipamento) =>
//       _descricaoEquipamento = descricaoEquipamento;
//   String get numeroDeSerie => _numeroDeSerie;
//   set numeroDeSerie(String numeroDeSerie) => _numeroDeSerie = numeroDeSerie;
//   double get quantidade => _quantidade;
//   set quantidade(double quantidade) => _quantidade = quantidade;
//   String get observacao => _observacao;
//   set observacao(String observacao) => _observacao = observacao;
//   String get dataInstalacao => _dataInstalacao;
//   set dataInstalacao(String dataInstalacao) => _dataInstalacao = dataInstalacao;

//   ParqueGrid.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _descricaoProduto = json['descricaoProduto'];
//     _descricaoMarca = json['descricaoMarca'];
//     _descricaoModelo = json['descricaoModelo'];
//     _descricaoEquipamento = json['descricaoEquipamento'];
//     _numeroDeSerie = json['numeroDeSerie'];
//     _quantidade = json['quantidade'];
//     _observacao = json['observacao'];
//     _dataInstalacao = json['dataInstalacao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['descricaoProduto'] = this._descricaoProduto;
//     data['descricaoMarca'] = this._descricaoMarca;
//     data['descricaoModelo'] = this._descricaoModelo;
//     data['descricaoEquipamento'] = this._descricaoEquipamento;
//     data['numeroDeSerie'] = this._numeroDeSerie;
//     data['quantidade'] = this._quantidade;
//     data['observacao'] = this._observacao;
//     data['dataInstalacao'] = this._dataInstalacao;
//     return data;
//   }
// }
