class TabelaPrecoLookUp {
  int id;
  int codigo;
  String descricao;

  TabelaPrecoLookUp({this.id, this.codigo, this.descricao});

  TabelaPrecoLookUp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codigo = json['codigo'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    return data;
  }
}

// class TabelaPrecoLookUp {
//   String id;
//   bool successo;
//   String erroCodigo;
//   String erroDescricao;
//   List<Entidade> entidade;
//   List<Erros> erros;

//   TabelaPrecoLookUp(
//       {this.id,
//       this.successo,
//       this.erroCodigo,
//       this.erroDescricao,
//       this.entidade,
//       this.erros});

//   TabelaPrecoLookUp.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     successo = json['successo'];
//     erroCodigo = json['erroCodigo'];
//     erroDescricao = json['erroDescricao'];
//     if (json['entidade'] != null) {
//       entidade = new List<Entidade>();
//       json['entidade'].forEach((v) {
//         entidade.add(new Entidade.fromJson(v));
//       });
//     }
//     if (json['erros'] != null) {
//       erros = new List<Erros>();
//       json['erros'].forEach((v) {
//         erros.add(new Erros.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['successo'] = this.successo;
//     data['erroCodigo'] = this.erroCodigo;
//     data['erroDescricao'] = this.erroDescricao;
//     if (this.entidade != null) {
//       data['entidade'] = this.entidade.map((v) => v.toJson()).toList();
//     }
//     if (this.erros != null) {
//       data['erros'] = this.erros.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Entidade {
//   int id;
//   int codigo;
//   String descricao;

//   Entidade({this.id, this.codigo, this.descricao});

//   Entidade.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     codigo = json['codigo'];
//     descricao = json['descricao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['codigo'] = this.codigo;
//     data['descricao'] = this.descricao;
//     return data;
//   }
// }

// class Erros {
//   String descricao;
//   String erroDescricao;

//   Erros({this.descricao, this.erroDescricao});

//   Erros.fromJson(Map<String, dynamic> json) {
//     descricao = json['descricao'];
//     erroDescricao = json['erroDescricao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['descricao'] = this.descricao;
//     data['erroDescricao'] = this.erroDescricao;
//     return data;
//   }
// }
