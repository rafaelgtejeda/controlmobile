class ProdutoLookUp {
  List<Produto> lista;
  bool pesquisaIdentica;

  ProdutoLookUp({this.lista, this.pesquisaIdentica});

  ProdutoLookUp.fromJson(Map<String, dynamic> json) {
    if (json['lista'] != null) {
      lista = new List<Produto>();
      json['lista'].forEach((v) {
        lista.add(new Produto.fromJson(v));
      });
    }
    pesquisaIdentica = json['pesquisaIdentica'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lista != null) {
      data['lista'] = this.lista.map((v) => v.toJson()).toList();
    }
    data['pesquisaIdentica'] = this.pesquisaIdentica;
    return data;
  }
}

class Produto {
  int id;
  int empresaId;
  String codigo;
  String descricao;
  String descricaoResumida;
  String marca;
  double saldoEstoque;
  double valorVenda;
  String unidadeMedida;
  bool locacaoBens;
  int tipo;
  int situacao;

  Produto(
      {this.id,
      this.empresaId,
      this.codigo,
      this.descricao,
      this.descricaoResumida,
      this.marca,
      this.saldoEstoque,
      this.valorVenda,
      this.unidadeMedida,
      this.locacaoBens,
      this.tipo,
      this.situacao});

  Produto.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if(json['empresaId'] != null){
      empresaId = json['empresaId'];
    }
    codigo = json['codigo'];
    descricao = json['descricao'];
    descricaoResumida = json['descricaoResumida'];
    marca = json['marca'];
    saldoEstoque = json['saldoEstoque'];
    valorVenda = json['valorVenda'];
    unidadeMedida = json['unidadeMedida'];
    if(json['locacaoBens'] == 0) {
      locacaoBens = false;
    }
    else if(json['locacaoBens'] == 1) {
      locacaoBens = true;
    }
    else {
      locacaoBens = json['locacaoBens'];
    }
    tipo = json['tipo'];
    situacao = json['situacao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['empresaId'] = this.empresaId;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['descricaoResumida'] = this.descricaoResumida;
    data['marca'] = this.marca;
    data['saldoEstoque'] = this.saldoEstoque;
    data['valorVenda'] = this.valorVenda;
    data['unidadeMedida'] = this.unidadeMedida;
    data['locacaoBens'] = this.locacaoBens;
    data['tipo'] = this.tipo;
    data['situacao'] = this.situacao;
    return data;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['empresaId'] = this.empresaId;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['descricaoResumida'] = this.descricaoResumida;
    data['marca'] = this.marca;
    data['saldoEstoque'] = this.saldoEstoque;
    data['valorVenda'] = this.valorVenda;
    data['unidadeMedida'] = this.unidadeMedida;
    data['locacaoBens'] = this.locacaoBens ? 1 : 0;
    data['tipo'] = this.tipo;
    data['situacao'] = this.situacao;
    return data;
  }
}


// class ProdutoLookUp {
//   List<Lista> _lista;
//   bool _pesquisaIdentica;

//   ProdutoLookUp({List<Lista> lista, bool pesquisaIdentica}) {
//     this._lista = lista;
//     this._pesquisaIdentica = pesquisaIdentica;
//   }

//   List<Lista> get lista => _lista;
//   set lista(List<Lista> lista) => _lista = lista;
//   bool get pesquisaIdentica => _pesquisaIdentica;
//   set pesquisaIdentica(bool pesquisaIdentica) =>
//       _pesquisaIdentica = pesquisaIdentica;

//   ProdutoLookUp.fromJson(Map<String, dynamic> json) {
//     if (json['lista'] != null) {
//       _lista = new List<Lista>();
//       json['lista'].forEach((v) {
//         _lista.add(new Lista.fromJson(v));
//       });
//     }
//     _pesquisaIdentica = json['pesquisaIdentica'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this._lista != null) {
//       data['lista'] = this._lista.map((v) => v.toJson()).toList();
//     }
//     data['pesquisaIdentica'] = this._pesquisaIdentica;
//     return data;
//   }
// }

// class Lista {

//   int _id;
//   int _empresaId;
//   int _tipo;
//   String _codigo;
//   String _descricao;
//   String _descricaoResumida;
//   String _marca;
//   double _saldoEstoque;
//   double _valorVenda;
//   String _unidadeMedida;
//   bool _locacaoBens;

//   Lista(
//       {
//       int id,
//       int empresaId,
//       int tipo,
//       String codigo,
//       String descricao,
//       String descricaoResumida,
//       String marca,
//       double saldoEstoque,
//       double valorVenda,
//       String unidadeMedida,
//       bool locacaoBens}) {
//     this._id = id;
//     this._empresaId = empresaId;
//     this._tipo = tipo;
//     this._codigo = codigo;
//     this._descricao = descricao;
//     this._descricaoResumida = descricaoResumida;
//     this._marca = marca;
//     this._saldoEstoque = saldoEstoque;
//     this._valorVenda = valorVenda;
//     this._unidadeMedida = unidadeMedida;
//     this._locacaoBens = locacaoBens;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get empresaId => _empresaId;
//   set empresaId(int empresaIdd) => _empresaId = empresaId;
//   int get tipo => _tipo;
//   set tipo(int tipo) => _tipo = tipo;
//   String get codigo => _codigo;
//   set codigo(String codigo) => _codigo = codigo;
//   String get descricao => _descricao;
//   set descricao(String descricao) => _descricao = descricao;
//   String get descricaoResumida => _descricaoResumida;
//   set descricaoResumida(String descricaoResumida) =>
//       _descricaoResumida = descricaoResumida;
//   String get marca => _marca;
//   set marca(String marca) => _marca = marca;
//   double get saldoEstoque => _saldoEstoque;
//   set saldoEstoque(double saldoEstoque) => _saldoEstoque = saldoEstoque;
//   double get valorVenda => _valorVenda;
//   set valorVenda(double valorVenda) => _valorVenda = valorVenda;
//   String get unidadeMedida => _unidadeMedida;
//   set unidadeMedida(String unidadeMedida) => _unidadeMedida = unidadeMedida;
//   bool get locacaoBens => _locacaoBens;
//   set locacaoBens(bool locacaoBens) => _locacaoBens = locacaoBens;

//   Lista.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     if(json['empresaId'] != null){
//       empresaId = json['empresaId'];
//     }
//     _tipo = json['tipo'];
//     _codigo = json['codigo'];
//     _descricao = json['descricao'];
//     _descricaoResumida = json['descricaoResumida'];
//     _marca = json['marca'];
//     _saldoEstoque = json['saldoEstoque'];
//     _valorVenda = json['valorVenda'];
//     _unidadeMedida = json['unidadeMedida'];
//     _locacaoBens = json['locacaoBens'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['empresaId'] = this._empresaId;
//     data['tipo'] = this._tipo;
//     data['codigo'] = this._codigo;
//     data['descricao'] = this._descricao;
//     data['descricaoResumida'] = this._descricaoResumida;
//     data['marca'] = this._marca;
//     data['saldoEstoque'] = this._saldoEstoque;
//     data['valorVenda'] = this._valorVenda;
//     data['unidadeMedida'] = this._unidadeMedida;
//     data['locacaoBens'] = this._locacaoBens;
//     return data;
//   }
// }
