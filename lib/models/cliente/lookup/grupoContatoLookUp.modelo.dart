class GrupoContatoLookUp {
  int id;
  String descricao;

  GrupoContatoLookUp({this.id, this.descricao});

  GrupoContatoLookUp.fromJson(Map<String, dynamic> json) {
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

class GrupoContatoCadastro {
  int id;
  String descricao;
  int empresaId;

  GrupoContatoCadastro({this.id, this.descricao, this.empresaId});

  GrupoContatoCadastro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    empresaId = json['empresaid'];
  }

  Map<String, dynamic> novoGrupoContatoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['descricao'] = this.descricao;
    data['empresaid'] = this.empresaId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['empresaid'] = this.empresaId;
    return data;
  }
}


// class GrupoContatoLookUp {
//   String id;
//   bool successo;
//   String erroCodigo;
//   String erroDescricao;
//   List<Entidade> entidade;
//   List<Erros> erros;

//   GrupoContatoLookUp(
//       {this.id,
//       this.successo,
//       this.erroCodigo,
//       this.erroDescricao,
//       this.entidade,
//       this.erros});

//   GrupoContatoLookUp.fromJson(Map<String, dynamic> json) {
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
