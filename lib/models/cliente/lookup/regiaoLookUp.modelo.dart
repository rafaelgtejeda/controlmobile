class RegiaoLookUp {
  int id;
  String descricao;

  RegiaoLookUp({this.id, this.descricao});

  RegiaoLookUp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    return data;
  }
}

class RegiaoCadastro {
  int id;
  String descricao;
  int empresaId;

  RegiaoCadastro({this.id, this.descricao, this.empresaId});

  RegiaoCadastro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    empresaId = json['empresaId'];
  }

  Map<String, dynamic> novaRegiaoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descricao'] = this.descricao;
    data['empresaId'] = this.empresaId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['empresaId'] = this.empresaId;
    return data;
  }
}


// class RegiaoLookUp {
//   String id;
//   bool successo;
//   String erroCodigo;
//   String erroDescricao;
//   List<Entidade> entidade;
//   List<Erros> erros;

//   RegiaoLookUp(
//       {this.id,
//       this.successo,
//       this.erroCodigo,
//       this.erroDescricao,
//       this.entidade,
//       this.erros});

//   RegiaoLookUp.fromJson(Map<String, dynamic> json) {
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
//   String descricao;

//   Entidade({this.id, this.descricao});

//   Entidade.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     descricao = json['descricao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
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
