class CartaoCreditoEditar {
  int id;
  String numero;
  String titular;
  String validadeMes;
  String validadeAno;
  String codigoSeguranca;
  int bandeira;
  bool principal;
  String dataNascimento;
  int parceiroId;

  CartaoCreditoEditar(
      {this.id,
      this.numero,
      this.titular,
      this.validadeMes,
      this.validadeAno,
      this.codigoSeguranca,
      this.bandeira,
      this.principal,
      this.dataNascimento,
      this.parceiroId});

  CartaoCreditoEditar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    titular = json['titular'];
    validadeMes = json['validadeMes'];
    validadeAno = json['validadeAno'];
    codigoSeguranca = json['codigoSeguranca'];
    bandeira = json['bandeira'];
    principal = json['principal'];
    dataNascimento = json['dataNascimento'];
    parceiroId = json['parceiroId'];
  }

  Map<String, dynamic> novoCartaoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['numero'] = this.numero;
    data['titular'] = this.titular;
    data['validadeMes'] = this.validadeMes;
    data['validadeAno'] = this.validadeAno;
    data['codigoSeguranca'] = this.codigoSeguranca;
    data['bandeira'] = this.bandeira;
    // data['principal'] = this.principal;
    data['dataNascimento'] = this.dataNascimento;
    data['parceiroId'] = this.parceiroId;
    return data;
  }

  // Map<String, dynamic> novoCartaoJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['numero'] = this.numero;
  //   data['titular'] = this.titular;
  //   data['validadeMes'] = this.validadeMes;
  //   data['validadeAno'] = this.validadeAno;
  //   data['codigoSeguranca'] = this.codigoSeguranca;
  //   data['bandeira'] = this.bandeira;
  //   data['principal'] = this.principal;
  //   data['dataNascimento'] = this.dataNascimento;
  //   data['parceiroId'] = this.parceiroId;
  //   return data;
  // }

  Map<String, dynamic> cartaoEditadoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    // data['numero'] = this.numero;
    data['titular'] = this.titular;
    data['validadeMes'] = this.validadeMes;
    data['validadeAno'] = this.validadeAno;
    data['codigoSeguranca'] = this.codigoSeguranca;
    data['bandeira'] = this.bandeira;
    // data['principal'] = this.principal;
    data['dataNascimento'] = this.dataNascimento;
    data['parceiroId'] = this.parceiroId;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['titular'] = this.titular;
    data['validadeMes'] = this.validadeMes;
    data['validadeAno'] = this.validadeAno;
    data['codigoSeguranca'] = this.codigoSeguranca;
    data['bandeira'] = this.bandeira;
    data['principal'] = this.principal;
    data['dataNascimento'] = this.dataNascimento;
    data['parceiroId'] = this.parceiroId;
    return data;
  }
}

// class CartaoCreditoEditar {
//   int _id;
//   String _numero;
//   String _titular;
//   String _validadeMes;
//   String _validadeAno;
//   String _codigoSeguranca;
//   int _bandeira;
//   bool _principal;
//   String _dataNascimento;
//   int _parceiroId;

//   CartaoCreditoEditar(
//       {int id,
//       String numero,
//       String titular,
//       String validadeMes,
//       String validadeAno,
//       String codigoSeguranca,
//       int bandeira,
//       bool principal,
//       String dataNascimento,
//       int parceiroId}) {
//     this._id = id;
//     this._numero = numero;
//     this._titular = titular;
//     this._validadeMes = validadeMes;
//     this._validadeAno = validadeAno;
//     this._codigoSeguranca = codigoSeguranca;
//     this._bandeira = bandeira;
//     this._principal = principal;
//     this._dataNascimento = dataNascimento;
//     this._parceiroId = parceiroId;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get numero => _numero;
//   set numero(String numero) => _numero = numero;
//   String get titular => _titular;
//   set titular(String titular) => _titular = titular;
//   String get validadeMes => _validadeMes;
//   set validadeMes(String validadeMes) => _validadeMes = validadeMes;
//   String get validadeAno => _validadeAno;
//   set validadeAno(String validadeAno) => _validadeAno = validadeAno;
//   String get codigoSeguranca => _codigoSeguranca;
//   set codigoSeguranca(String codigoSeguranca) =>
//       _codigoSeguranca = codigoSeguranca;
//   int get bandeira => _bandeira;
//   set bandeira(int bandeira) => _bandeira = bandeira;
//   bool get principal => _principal;
//   set principal(bool principal) => _principal = principal;
//   String get dataNascimento => _dataNascimento;
//   set dataNascimento(String dataNascimento) => _dataNascimento = dataNascimento;
//   int get parceiroId => _parceiroId;
//   set parceiroId(int parceiroId) => _parceiroId = parceiroId;

//   CartaoCreditoEditar.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _numero = json['numero'];
//     _titular = json['titular'];
//     _validadeMes = json['validadeMes'];
//     _validadeAno = json['validadeAno'];
//     _codigoSeguranca = json['codigoSeguranca'];
//     _bandeira = json['bandeira'];
//     _principal = json['principal'];
//     _dataNascimento = json['dataNascimento'];
//     _parceiroId = json['parceiroId'];
//   }

//   Map<String, dynamic> novoCartaoJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['numero'] = this._numero;
//     data['titular'] = this._titular;
//     data['validadeMes'] = this._validadeMes;
//     data['validadeAno'] = this._validadeAno;
//     data['codigoSeguranca'] = this._codigoSeguranca;
//     data['bandeira'] = this._bandeira;
//     data['principal'] = this._principal;
//     data['dataNascimento'] = this._dataNascimento;
//     data['parceiroId'] = this._parceiroId;
//     return data;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['numero'] = this._numero;
//     data['titular'] = this._titular;
//     data['validadeMes'] = this._validadeMes;
//     data['validadeAno'] = this._validadeAno;
//     data['codigoSeguranca'] = this._codigoSeguranca;
//     data['bandeira'] = this._bandeira;
//     data['principal'] = this._principal;
//     data['dataNascimento'] = this._dataNascimento;
//     data['parceiroId'] = this._parceiroId;
//     return data;
//   }
// }
