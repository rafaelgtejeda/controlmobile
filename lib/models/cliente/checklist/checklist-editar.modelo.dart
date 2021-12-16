class CheckListEditar {
  int id;
  int sequencia;
  String descricao;
  int parceiroId;

  CheckListEditar({this.id, this.sequencia, this.descricao, this.parceiroId});

  CheckListEditar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequencia = json['sequencia'];
    descricao = json['descricao'];
    parceiroId = json['parceiroId'];
  }

  Map<String, dynamic> novoCheckListJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sequencia'] = this.sequencia;
    data['descricao'] = this.descricao;
    data['parceiroId'] = this.parceiroId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sequencia'] = this.sequencia;
    data['descricao'] = this.descricao;
    data['parceiroId'] = this.parceiroId;
    return data;
  }
}

// class CheckListEditar {
//   int _id;
//   int _sequencia;
//   String _descricao;
//   int _parceiroId;

//   CheckListEditar({int id, int sequencia, String descricao, int parceiroId}) {
//     this._id = id;
//     this._sequencia = sequencia;
//     this._descricao = descricao;
//     this._parceiroId = parceiroId;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get sequencia => _sequencia;
//   set sequencia(int sequencia) => _sequencia = sequencia;
//   String get descricao => _descricao;
//   set descricao(String descricao) => _descricao = descricao;
//   int get parceiroId => _parceiroId;
//   set parceiroId(int parceiroId) => _parceiroId = parceiroId;

//   CheckListEditar.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _sequencia = json['sequencia'];
//     _descricao = json['descricao'];
//     _parceiroId = json['parceiroId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['sequencia'] = this._sequencia;
//     data['descricao'] = this._descricao;
//     data['parceiroId'] = this._parceiroId;
//     return data;
//   }
// }
