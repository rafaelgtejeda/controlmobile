// class LimiteCreditoEditar {
//   int id;
//   int parceiroId;
//   int formaPagamentoId;
//   double valorLimiteProprio;
//   double valorLimiteTerceiro;
//   List<String> docs;

//   LimiteCreditoEditar(
//       {this.id,
//       this.parceiroId,
//       this.formaPagamentoId,
//       this.valorLimiteProprio,
//       this.valorLimiteTerceiro,
//       this.docs});

//   LimiteCreditoEditar.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     formaPagamentoId = json['formaPagamentoId'];
//     valorLimiteProprio = json['limiteProprio'];
//     valorLimiteTerceiro = json['limiteTerceiro'];
//     docs = json['docs'].cast<String>();
//   }

//   // LimiteCreditoEditar.fromJson(Map<String, dynamic> json) {
//   //   id = json['id'];
//   //   parceiroId = json['parceiroId'];
//   //   formaPagamentoId = json['formaPagamentoId'];
//   //   valorLimiteProprio = json['valorLimiteProprio'];
//   //   valorLimiteTerceiro = json['valorLimiteTerceiro'];
//   //   docs = json['docs'].cast<String>();
//   // }

//   Map<String, dynamic> novoLimiteCreditoJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['parceiroId'] = this.parceiroId;
//     data['formaPagamentoId'] = this.formaPagamentoId;
//     data['valorLimiteProprio'] = this.valorLimiteProprio;
//     data['valorLimiteTerceiro'] = this.valorLimiteTerceiro;
//     data['docs'] = this.docs;
//     return data;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this.id;
//     data['parceiroId'] = this.parceiroId;
//     data['formaPagamentoId'] = this.formaPagamentoId;
//     data['valorLimiteProprio'] = this.valorLimiteProprio;
//     data['valorLimiteTerceiro'] = this.valorLimiteTerceiro;
//     data['docs'] = this.docs;
//     return data;
//   }
// }



// class LimiteCreditoEditar {
//   int _id;
//   int _parceiroId;
//   int _formaPagamentoId;
//   double _valorLimiteProprio;
//   double _valorLimiteTerceiro;
//   List<String> _docs;

//   LimiteCreditoEditar(
//       {int id,
//       int parceiroId,
//       int formaPagamentoId,
//       double valorLimiteProprio,
//       double valorLimiteTerceiro,
//       List<String> docs}) {
//     this._id = id;
//     this._parceiroId = parceiroId;
//     this._formaPagamentoId = formaPagamentoId;
//     this._valorLimiteProprio = valorLimiteProprio;
//     this._valorLimiteTerceiro = valorLimiteTerceiro;
//     this._docs = docs;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get parceiroId => _parceiroId;
//   set parceiroId(int parceiroId) => _parceiroId = parceiroId;
//   int get formaPagamentoId => _formaPagamentoId;
//   set formaPagamentoId(int formaPagamentoId) =>
//       _formaPagamentoId = formaPagamentoId;
//   double get valorLimiteProprio => _valorLimiteProprio;
//   set valorLimiteProprio(double valorLimiteProprio) =>
//       _valorLimiteProprio = valorLimiteProprio;
//   double get valorLimiteTerceiro => _valorLimiteTerceiro;
//   set valorLimiteTerceiro(double valorLimiteTerceiro) =>
//       _valorLimiteTerceiro = valorLimiteTerceiro;
//   List<String> get docs => _docs;
//   set docs(List<String> docs) => _docs = docs;

//   LimiteCreditoEditar.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _parceiroId = json['parceiroId'];
//     _formaPagamentoId = json['formaPagamentoId'];
//     _valorLimiteProprio = json['valorLimiteProprio'];
//     _valorLimiteTerceiro = json['valorLimiteTerceiro'];
//     _docs = json['docs'].cast<String>();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['parceiroId'] = this._parceiroId;
//     data['formaPagamentoId'] = this._formaPagamentoId;
//     data['valorLimiteProprio'] = this._valorLimiteProprio;
//     data['valorLimiteTerceiro'] = this._valorLimiteTerceiro;
//     data['docs'] = this._docs;
//     return data;
//   }
// }


class LimiteCreditoEditarGet {
  int id;
  double limiteProprio;
  double limiteTerceiro;
  List<Docs> docs;
  int formaPagamentoId;

  LimiteCreditoEditarGet(
      {this.id,
      this.limiteProprio,
      this.limiteTerceiro,
      this.docs,
      this.formaPagamentoId});

  LimiteCreditoEditarGet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    limiteProprio = json['limiteProprio'];
    limiteTerceiro = json['limiteTerceiro'];
    if (json['docs'] != null) {
      docs = new List<Docs>();
      json['docs'].forEach((v) {
        docs.add(new Docs.fromJson(v));
      });
    }
    formaPagamentoId = json['formaPagamentoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['limiteProprio'] = this.limiteProprio;
    data['limiteTerceiro'] = this.limiteTerceiro;
    if (this.docs != null) {
      data['docs'] = this.docs.map((v) => v.toJson()).toList();
    }
    data['formaPagamentoId'] = this.formaPagamentoId;
    return data;
  }
}

class Docs {
  int id;
  String numeroDocumento;

  Docs({this.id, this.numeroDocumento});

  Docs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numeroDocumento = json['numeroDocumento'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numeroDocumento'] = this.numeroDocumento;
    return data;
  }
}



// class LimiteCreditoEditarGet {
//   int _id;
//   int _limiteProprio;
//   int _limiteTerceiro;
//   List<Docs> _docs;
//   int _formaPagamentoId;

//   LimiteCreditoEditarGet(
//       {int id,
//       int limiteProprio,
//       int limiteTerceiro,
//       List<Docs> docs,
//       int formaPagamentoId}) {
//     this._id = id;
//     this._limiteProprio = limiteProprio;
//     this._limiteTerceiro = limiteTerceiro;
//     this._docs = docs;
//     this._formaPagamentoId = formaPagamentoId;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get limiteProprio => _limiteProprio;
//   set limiteProprio(int limiteProprio) => _limiteProprio = limiteProprio;
//   int get limiteTerceiro => _limiteTerceiro;
//   set limiteTerceiro(int limiteTerceiro) => _limiteTerceiro = limiteTerceiro;
//   List<Docs> get docs => _docs;
//   set docs(List<Docs> docs) => _docs = docs;
//   int get formaPagamentoId => _formaPagamentoId;
//   set formaPagamentoId(int formaPagamentoId) =>
//       _formaPagamentoId = formaPagamentoId;

//   LimiteCreditoEditarGet.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _limiteProprio = json['limiteProprio'];
//     _limiteTerceiro = json['limiteTerceiro'];
//     if (json['docs'] != null) {
//       _docs = new List<Docs>();
//       json['docs'].forEach((v) {
//         _docs.add(new Docs.fromJson(v));
//       });
//     }
//     _formaPagamentoId = json['formaPagamentoId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['limiteProprio'] = this._limiteProprio;
//     data['limiteTerceiro'] = this._limiteTerceiro;
//     if (this._docs != null) {
//       data['docs'] = this._docs.map((v) => v.toJson()).toList();
//     }
//     data['formaPagamentoId'] = this._formaPagamentoId;
//     return data;
//   }
// }

// class Docs {
//   int _id;
//   String _numeroDocumento;

//   Docs({int id, String numeroDocumento}) {
//     this._id = id;
//     this._numeroDocumento = numeroDocumento;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get numeroDocumento => _numeroDocumento;
//   set numeroDocumento(String numeroDocumento) =>
//       _numeroDocumento = numeroDocumento;

//   Docs.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _numeroDocumento = json['numeroDocumento'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['numeroDocumento'] = this._numeroDocumento;
//     return data;
//   }
// }



class LimiteCreditoEditarSave {
  int id;
  int parceiroId;
  int formaPagamentoId;
  double valorLimiteProprio;
  double valorLimiteTerceiro;
  List<String> docs;

  LimiteCreditoEditarSave(
      {this.id,
      this.parceiroId,
      this.formaPagamentoId,
      this.valorLimiteProprio,
      this.valorLimiteTerceiro,
      this.docs});

  LimiteCreditoEditarSave.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parceiroId = json['parceiroId'];
    formaPagamentoId = json['formaPagamentoId'];
    valorLimiteProprio = json['valorLimiteProprio'];
    valorLimiteTerceiro = json['valorLimiteTerceiro'];
    docs = json['docs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['parceiroId'] = this.parceiroId;
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['valorLimiteProprio'] = this.valorLimiteProprio;
    data['valorLimiteTerceiro'] = this.valorLimiteTerceiro;
    data['docs'] = this.docs;
    return data;
  }

  Map<String, dynamic> novoLimiteCreditoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['id'] = this.id;
    data['parceiroId'] = this.parceiroId;
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['valorLimiteProprio'] = this.valorLimiteProprio;
    data['valorLimiteTerceiro'] = this.valorLimiteTerceiro;
    data['docs'] = this.docs;
    return data;
  }
}


// class LimiteCreditoEditarSave {
//   int _id;
//   int _parceiroId;
//   int _formaPagamentoId;
//   int _valorLimiteProprio;
//   int _valorLimiteTerceiro;
//   List<String> _docs;

//   LimiteCreditoEditarSave(
//       {int id,
//       int parceiroId,
//       int formaPagamentoId,
//       int valorLimiteProprio,
//       int valorLimiteTerceiro,
//       List<String> docs}) {
//     this._id = id;
//     this._parceiroId = parceiroId;
//     this._formaPagamentoId = formaPagamentoId;
//     this._valorLimiteProprio = valorLimiteProprio;
//     this._valorLimiteTerceiro = valorLimiteTerceiro;
//     this._docs = docs;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get parceiroId => _parceiroId;
//   set parceiroId(int parceiroId) => _parceiroId = parceiroId;
//   int get formaPagamentoId => _formaPagamentoId;
//   set formaPagamentoId(int formaPagamentoId) =>
//       _formaPagamentoId = formaPagamentoId;
//   int get valorLimiteProprio => _valorLimiteProprio;
//   set valorLimiteProprio(int valorLimiteProprio) =>
//       _valorLimiteProprio = valorLimiteProprio;
//   int get valorLimiteTerceiro => _valorLimiteTerceiro;
//   set valorLimiteTerceiro(int valorLimiteTerceiro) =>
//       _valorLimiteTerceiro = valorLimiteTerceiro;
//   List<String> get docs => _docs;
//   set docs(List<String> docs) => _docs = docs;

//   LimiteCreditoEditarSave.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _parceiroId = json['parceiroId'];
//     _formaPagamentoId = json['formaPagamentoId'];
//     _valorLimiteProprio = json['valorLimiteProprio'];
//     _valorLimiteTerceiro = json['valorLimiteTerceiro'];
//     _docs = json['docs'].cast<String>();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['parceiroId'] = this._parceiroId;
//     data['formaPagamentoId'] = this._formaPagamentoId;
//     data['valorLimiteProprio'] = this._valorLimiteProprio;
//     data['valorLimiteTerceiro'] = this._valorLimiteTerceiro;
//     data['docs'] = this._docs;
//     return data;
//   }
// }
