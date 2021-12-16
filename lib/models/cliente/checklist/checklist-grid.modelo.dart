class CheckListGrid {
  int id;
  int sequencia;
  String descricao;
  bool isSelected = false;

  CheckListGrid({this.id, this.sequencia, this.descricao});

  CheckListGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sequencia = json['sequencia'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sequencia'] = this.sequencia;
    data['descricao'] = this.descricao;
    return data;
  }
}

// class CheckListGrid {
//   int _id;
//   int _sequencia;
//   String _descricao;

//   CheckListGrid({int id, int sequencia, String descricao}) {
//     this._id = id;
//     this._sequencia = sequencia;
//     this._descricao = descricao;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get sequencia => _sequencia;
//   set sequencia(int sequencia) => _sequencia = sequencia;
//   String get descricao => _descricao;
//   set descricao(String descricao) => _descricao = descricao;

//   CheckListGrid.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _sequencia = json['sequencia'];
//     _descricao = json['descricao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['sequencia'] = this._sequencia;
//     data['descricao'] = this._descricao;
//     return data;
//   }
// }
