class RamoAtividadeLookUp {
  int id;
  String descricao;
  int codigo;

  RamoAtividadeLookUp({this.id, this.descricao, this.codigo});

  RamoAtividadeLookUp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    codigo = json['codigo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['codigo'] = this.codigo;
    return data;
  }
}

class RamoAtividadeUltimoCodigo {
  int codigo;

  RamoAtividadeUltimoCodigo({this.codigo});

  RamoAtividadeUltimoCodigo.fromJson(Map<String, dynamic> json) {
    codigo = json['codigo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codigo'] = this.codigo;
    return data;
  }
}

class RamoAtividadeCadastro {
  int id;
  int idLegado;
  String codigo;
  String descricao;
  int empresaId;

  RamoAtividadeCadastro(
      {this.id, this.idLegado, this.codigo, this.descricao, this.empresaId});

  RamoAtividadeCadastro.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idLegado = json['idLegado'];
    codigo = json['codigo'];
    descricao = json['descricao'];
    empresaId = json['empresaId'];
  }

  Map<String, dynamic> novoRamoAtividadeJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['empresaId'] = this.empresaId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idLegado'] = this.idLegado;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['empresaId'] = this.empresaId;
    return data;
  }
}



// class RamoAtividadeLookUp {
//   String id;
//   bool successo;
//   String erroCodigo;
//   String erroDescricao;
//   List<Entidade> entidade;
//   List<Erros> erros;

//   RamoAtividadeLookUp(
//       {this.id,
//       this.successo,
//       this.erroCodigo,
//       this.erroDescricao,
//       this.entidade,
//       this.erros});

//   RamoAtividadeLookUp.fromJson(Map<String, dynamic> json) {
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
//   String codigo;

//   Entidade({this.id, this.descricao, this.codigo});

//   Entidade.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     descricao = json['descricao'];
//     codigo = json['codigo'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['descricao'] = this.descricao;
//     data['codigo'] = this.codigo;
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
