class ContatoGrid {
  int id;
  String nome;
  String email;
  Telefone telefone;
  Telefone celular;
  bool principal;
  bool boleto;
  bool notaFiscal;
  bool isSelected = false;

  ContatoGrid(
      {this.id,
      this.nome,
      this.email,
      this.telefone,
      this.celular,
      this.principal,
      this.boleto,
      this.notaFiscal});

  ContatoGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    email = json['email'];
    telefone = json['telefone'] != null
        ? new Telefone.fromJson(json['telefone'])
        : null;
    celular =
        json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
    principal = json['principal'];
    boleto = json['boleto'];
    notaFiscal = json['notaFiscal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['email'] = this.email;
    if (this.telefone != null) {
      data['telefone'] = this.telefone.toJson();
    }
    if (this.celular != null) {
      data['celular'] = this.celular.toJson();
    }
    data['principal'] = this.principal;
    data['boleto'] = this.boleto;
    data['notaFiscal'] = this.notaFiscal;
    return data;
  }
}

class Telefone {
  String ddd;
  String ddi;
  String phone;

  Telefone({this.ddd, this.ddi, this.phone});

  Telefone.fromJson(Map<String, dynamic> json) {
    ddd = json['ddd'];
    ddi = json['ddi'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ddd'] = this.ddd;
    data['ddi'] = this.ddi;
    data['phone'] = this.phone;
    return data;
  }
}



// class ContatoGrid {
//   int _id;
//   String _nome;
//   String _email;
//   Telefone _telefone;
//   Telefone _celular;
//   bool _principal;
//   bool _boleto;
//   bool _notaFiscal;

//   ContatoGrid(
//       {int id,
//       String nome,
//       String email,
//       Telefone telefone,
//       Telefone celular,
//       bool principal,
//       bool boleto,
//       bool notaFiscal}) {
//     this._id = id;
//     this._nome = nome;
//     this._email = email;
//     this._telefone = telefone;
//     this._celular = celular;
//     this._principal = principal;
//     this._boleto = boleto;
//     this._notaFiscal = notaFiscal;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get nome => _nome;
//   set nome(String nome) => _nome = nome;
//   String get email => _email;
//   set email(String email) => _email = email;
//   Telefone get telefone => _telefone;
//   set telefone(Telefone telefone) => _telefone = telefone;
//   Telefone get celular => _celular;
//   set celular(Telefone celular) => _celular = celular;
//   bool get principal => _principal;
//   set principal(bool principal) => _principal = principal;
//   bool get boleto => _boleto;
//   set boleto(bool boleto) => _boleto = boleto;
//   bool get notaFiscal => _notaFiscal;
//   set notaFiscal(bool notaFiscal) => _notaFiscal = notaFiscal;

//   ContatoGrid.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _nome = json['nome'];
//     _email = json['email'];
//     _telefone = json['telefone'] != null
//         ? new Telefone.fromJson(json['telefone'])
//         : null;
//     _celular =
//         json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
//     _principal = json['principal'];
//     _boleto = json['boleto'];
//     _notaFiscal = json['notaFiscal'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['nome'] = this._nome;
//     data['email'] = this._email;
//     if (this._telefone != null) {
//       data['telefone'] = this._telefone.toJson();
//     }
//     if (this._celular != null) {
//       data['celular'] = this._celular.toJson();
//     }
//     data['principal'] = this._principal;
//     data['boleto'] = this._boleto;
//     data['notaFiscal'] = this._notaFiscal;
//     return data;
//   }
// }

// class Telefone {
//   String _ddd;
//   String _ddi;
//   String _phone;

//   Telefone({String ddd, String ddi, String phone}) {
//     this._ddd = ddd;
//     this._ddi = ddi;
//     this._phone = phone;
//   }

//   String get ddd => _ddd;
//   set ddd(String ddd) => _ddd = ddd;
//   String get ddi => _ddi;
//   set ddi(String ddi) => _ddi = ddi;
//   String get phone => _phone;
//   set phone(String phone) => _phone = phone;

//   Telefone.fromJson(Map<String, dynamic> json) {
//     _ddd = json['ddd'];
//     _ddi = json['ddi'];
//     _phone = json['phone'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['ddd'] = this._ddd;
//     data['ddi'] = this._ddi;
//     data['phone'] = this._phone;
//     return data;
//   }
// }
