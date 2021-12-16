class ContatoEditar {
  int _id;
  String _nome;
  String _email;
  Telefone _telefone;
  Telefone _telefone2;
  Telefone _celular;
  bool _principal;
  bool _boleto;
  bool _notaFiscal;
  int _parceiroId;

  ContatoEditar(
      {int id,
      String nome,
      String email,
      Telefone telefone,
      Telefone telefone2,
      Telefone celular,
      bool principal,
      bool boleto,
      bool notaFiscal,
      int parceiroId}) {
    this._id = id;
    this._nome = nome;
    this._email = email;
    this._telefone = telefone;
    this._telefone2 = telefone2;
    this._celular = celular;
    this._principal = principal;
    this._boleto = boleto;
    this._notaFiscal = notaFiscal;
    this._parceiroId = parceiroId;
  }

  int get id => _id;
  set id(int id) => _id = id;
  String get nome => _nome;
  set nome(String nome) => _nome = nome;
  String get email => _email;
  set email(String email) => _email = email;
  Telefone get telefone => _telefone;
  set telefone(Telefone telefone) => _telefone = telefone;
  Telefone get telefone2 => _telefone2;
  set telefone2(Telefone telefone2) => _telefone2 = telefone2;
  Telefone get celular => _celular;
  set celular(Telefone celular) => _celular = celular;
  bool get principal => _principal;
  set principal(bool principal) => _principal = principal;
  bool get boleto => _boleto;
  set boleto(bool boleto) => _boleto = boleto;
  bool get notaFiscal => _notaFiscal;
  set notaFiscal(bool notaFiscal) => _notaFiscal = notaFiscal;
  int get parceiroId => _parceiroId;
  set parceiroId(int parceiroId) => _parceiroId = parceiroId;

  ContatoEditar.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _nome = json['nome'];
    _email = json['email'];
    _telefone = json['telefone'] != null
        ? new Telefone.fromJson(json['telefone'])
        : null;
    _telefone2 = json['telefone2'] != null
        ? new Telefone.fromJson(json['telefone2'])
        : null;
    _celular =
        json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
    _principal = json['principal'];
    _boleto = json['boleto'];
    _notaFiscal = json['notaFiscal'];
    _parceiroId = json['parceiroId'];
  }

  Map<String, dynamic> novoContatoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this._nome;
    data['email'] = this._email;
    if (this._telefone != null) {
      data['telefone'] = this._telefone.toJson();
    }
    if (this._telefone2 != null) {
      data['telefone2'] = this._telefone2.toJson();
    }
    if (this._celular != null) {
      data['celular'] = this._celular.toJson();
    }
    // data['principal'] = this._principal;
    data['favorito'] = this._principal;
    data['boleto'] = this._boleto;
    data['nf'] = this._notaFiscal;
    // data['notaFiscal'] = this._notaFiscal;
    data['parceiroId'] = this._parceiroId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this._id;
    data['nome'] = this._nome;
    data['email'] = this._email;
    if (this._telefone != null) {
      data['telefone'] = this._telefone.toJson();
    }
    if (this._telefone2 != null) {
      data['telefone2'] = this._telefone2.toJson();
    }
    if (this._celular != null) {
      data['celular'] = this._celular.toJson();
    }
    // data['principal'] = this._principal;
    data['favorito'] = this._principal;
    data['boleto'] = this._boleto;
    data['nf'] = this._notaFiscal;
    // data['notaFiscal'] = this._notaFiscal;
    data['parceiroId'] = this._parceiroId;
    return data;
  }
}

class Telefone {
  String _ddd;
  String _ddi;
  String _phone;

  Telefone({String ddd, String ddi, String phone}) {
    this._ddd = ddd;
    this._ddi = ddi;
    this._phone = phone;
  }

  String get ddd => _ddd;
  set ddd(String ddd) => _ddd = ddd;
  String get ddi => _ddi;
  set ddi(String ddi) => _ddi = ddi;
  String get phone => _phone;
  set phone(String phone) => _phone = phone;

  Telefone.fromJson(Map<String, dynamic> json) {
    _ddd = json['ddd'];
    _ddi = json['ddi'];
    _phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ddd'] = this._ddd;
    data['ddi'] = this._ddi;
    data['phone'] = this._phone;
    return data;
  }
}
