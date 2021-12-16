class EnderecoGrid {
  int id;
  int tipoEndereco;
  String descricaoTipoEndereco;
  String descricaoEnderecoOutros;
  String endereco;
  String numero;
  String cep;
  bool isSelected = false;

  EnderecoGrid(
      {this.id,
      this.tipoEndereco,
      this.descricaoTipoEndereco,
      this.descricaoEnderecoOutros,
      this.endereco,
      this.numero,
      this.cep});

  EnderecoGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tipoEndereco = json['tipoEndereco'];
    descricaoTipoEndereco = json['descricaoTipoEndereco'];
    descricaoEnderecoOutros = json['descricaoEnderecoOutros'];
    endereco = json['endereco'];
    numero = json['numero'];
    cep = json['cep'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['tipoEndereco'] = this.tipoEndereco;
    data['descricaoTipoEndereco'] = this.descricaoTipoEndereco;
    data['descricaoEnderecoOutros'] = this.descricaoEnderecoOutros;
    data['endereco'] = this.endereco;
    data['numero'] = this.numero;
    data['cep'] = this.cep;
    return data;
  }
}



// class EnderecoGrid {
//   int _id;
//   int _tipoEndereco;
//   String _descricaoTipoEndereco;
//   String _descricaoEnderecoOutros;
//   String _endereco;
//   String _numero;
//   String _cep;

//   EnderecoGrid(
//       {int id,
//       int tipoEndereco,
//       String descricaoTipoEndereco,
//       String descricaoEnderecoOutros,
//       String endereco,
//       String numero,
//       String cep}) {
//     this._id = id;
//     this._tipoEndereco = tipoEndereco;
//     this._descricaoTipoEndereco = descricaoTipoEndereco;
//     this._descricaoEnderecoOutros = descricaoEnderecoOutros;
//     this._endereco = endereco;
//     this._numero = numero;
//     this._cep = cep;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get tipoEndereco => _tipoEndereco;
//   set tipoEndereco(int tipoEndereco) => _tipoEndereco = tipoEndereco;
//   String get descricaoTipoEndereco => _descricaoTipoEndereco;
//   set descricaoTipoEndereco(String descricaoTipoEndereco) =>
//       _descricaoTipoEndereco = descricaoTipoEndereco;
//   String get descricaoEnderecoOutros => _descricaoEnderecoOutros;
//   set descricaoEnderecoOutros(String descricaoEnderecoOutros) =>
//       _descricaoEnderecoOutros = descricaoEnderecoOutros;
//   String get endereco => _endereco;
//   set endereco(String endereco) => _endereco = endereco;
//   String get numero => _numero;
//   set numero(String numero) => _numero = numero;
//   String get cep => _cep;
//   set cep(String cep) => _cep = cep;

//   EnderecoGrid.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _tipoEndereco = json['tipoEndereco'];
//     _descricaoTipoEndereco = json['descricaoTipoEndereco'];
//     _descricaoEnderecoOutros = json['descricaoEnderecoOutros'];
//     _endereco = json['endereco'];
//     _numero = json['numero'];
//     _cep = json['cep'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['tipoEndereco'] = this._tipoEndereco;
//     data['descricaoTipoEndereco'] = this._descricaoTipoEndereco;
//     data['descricaoEnderecoOutros'] = this._descricaoEnderecoOutros;
//     data['endereco'] = this._endereco;
//     data['numero'] = this._numero;
//     data['cep'] = this._cep;
//     return data;
//   }
// }
