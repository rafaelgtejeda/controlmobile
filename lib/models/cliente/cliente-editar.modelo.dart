class ClienteEditar {
  int id;
  int empresaId;
  String cnpJCPF;
  String rg;
  String im;
  String ie;
  String nome;
  String nomeFantasia;
  String codigo;
  // int situacaoParceiro;
  int pessoa;
  int ramoAtividadeId;
  int regiaoId;
  int grupoContatoId;
  String dataCadastro;
  EnderecoPrincipal enderecoPrincipal;
  ContatoPrincipal contatoPrincipal;
  int tabelaPrecoId;
  int vendedorId;
  double totalLimite;
  int tipoLimite;
  double limiteConsumido;
  double limiteRestante;

  ClienteEditar(
      {this.id,
      this.empresaId,
      this.cnpJCPF,
      this.rg,
      this.im,
      this.ie,
      this.nome,
      this.nomeFantasia,
      this.codigo,
      // this.situacaoParceiro,
      this.pessoa,
      this.ramoAtividadeId,
      this.regiaoId,
      this.grupoContatoId,
      this.dataCadastro,
      this.enderecoPrincipal,
      this.contatoPrincipal,
      this.tabelaPrecoId,
      this.vendedorId,
      this.totalLimite,
      this.tipoLimite,
      this.limiteConsumido,
      this.limiteRestante});

  ClienteEditar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    empresaId = json['empresaId'];
    cnpJCPF = json['cnpJ_CPF'];
    rg = json['rg'];
    im = json['im'];
    ie = json['ie'];
    nome = json['nome'];
    nomeFantasia = json['nomeFantasia'];
    codigo = json['codigo'];
    // situacaoParceiro = json['situacaoParceiro'];
    pessoa = json['pessoa'];
    ramoAtividadeId = json['ramoAtividadeId'];
    regiaoId = json['regiaoId'];
    grupoContatoId = json['grupoContatoId'];
    dataCadastro = json['dataCadastro'];
    enderecoPrincipal = json['enderecoPrincipal'] != null
        ? new EnderecoPrincipal.fromJson(json['enderecoPrincipal'])
        : null;
    contatoPrincipal = json['contatoPrincipal'] != null
        ? new ContatoPrincipal.fromJson(json['contatoPrincipal'])
        : null;
    tabelaPrecoId = json['tabelaPrecoId'];
    vendedorId = json['vendedorId'];
    totalLimite = json['totalLimite'];
    tipoLimite = json['tipoLimite'];
    limiteConsumido = json['limiteConsumido'];
    limiteRestante = json['limiteRestante'];
  }

  Map<String, dynamic> novoClienteJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['empresaId'] = this.empresaId;
    data['cnpJ_CPF'] = this.cnpJCPF;
    data['rg'] = this.rg;
    data['im'] = this.im;
    data['ie'] = this.ie;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    data['codigo'] = this.codigo;
    // data['situacaoParceiro'] = this.situacaoParceiro;
    data['pessoa'] = this.pessoa;
    data['ramoAtividadeId'] = this.ramoAtividadeId;
    data['regiaoId'] = this.regiaoId;
    data['grupoContatoId'] = this.grupoContatoId;
    if (this.enderecoPrincipal != null) {
      data['enderecoPrincipal'] = this.enderecoPrincipal.toJson();
    }
    if (this.contatoPrincipal != null) {
      data['contatoPrincipal'] = this.contatoPrincipal.toJson();
    }
    data['tabelaPrecoId'] = this.tabelaPrecoId;
    data['vendedorId'] = this.vendedorId;
    data['totalLimite'] = this.totalLimite;
    data['tipoLimite'] = this.tipoLimite;
    data['limiteConsumido'] = this.limiteConsumido;
    data['limiteRestante'] = this.limiteRestante;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['empresaId'] = this.empresaId;
    data['cnpJ_CPF'] = this.cnpJCPF;
    data['rg'] = this.rg;
    data['im'] = this.im;
    data['ie'] = this.ie;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    data['codigo'] = this.codigo;
    // data['situacaoParceiro'] = this.situacaoParceiro;
    data['pessoa'] = this.pessoa;
    data['ramoAtividadeId'] = this.ramoAtividadeId;
    data['regiaoId'] = this.regiaoId;
    data['grupoContatoId'] = this.grupoContatoId;
    data['dataCadastro'] = this.dataCadastro;
    if (this.enderecoPrincipal != null) {
      data['enderecoPrincipal'] = this.enderecoPrincipal.toJson();
    }
    if (this.contatoPrincipal != null) {
      data['contatoPrincipal'] = this.contatoPrincipal.toJson();
    }
    data['tabelaPrecoId'] = this.tabelaPrecoId;
    data['vendedorId'] = this.vendedorId;
    data['totalLimite'] = this.totalLimite;
    data['tipoLimite'] = this.tipoLimite;
    data['limiteConsumido'] = this.limiteConsumido;
    data['limiteRestante'] = this.limiteRestante;
    return data;
  }
}

class EnderecoPrincipal {
  String cep;
  String codigoIBGE;
  String endereco;
  String numero;
  String bairro;
  String complemento;
  String cidade;
  String uf;
  int cidadeEstrangeiroId;

  EnderecoPrincipal(
      {this.cep,
      this.codigoIBGE,
      this.endereco,
      this.numero,
      this.bairro,
      this.complemento,
      this.cidade,
      this.uf,
      this.cidadeEstrangeiroId});

  EnderecoPrincipal.fromJson(Map<String, dynamic> json) {
    cep = json['cep'];
    codigoIBGE = json['codigoIBGE'];
    endereco = json['endereco'];
    numero = json['numero'];
    bairro = json['bairro'];
    complemento = json['complemento'];
    cidade = json['cidade'];
    uf = json['uf'];
    cidadeEstrangeiroId = json['cidadeEstrangeiroId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cep'] = this.cep;
    data['codigoIBGE'] = this.codigoIBGE;
    data['endereco'] = this.endereco;
    data['numero'] = this.numero;
    data['bairro'] = this.bairro;
    data['complemento'] = this.complemento;
    data['cidade'] = this.cidade;
    data['uf'] = this.uf;
    data['cidadeEstrangeiroId'] = this.cidadeEstrangeiroId;
    return data;
  }
}

class ContatoPrincipal {
  String email;
  Telefone telefone;
  Telefone telefone2;
  Telefone celular;

  ContatoPrincipal({this.email, this.telefone, this.telefone2, this.celular});

  ContatoPrincipal.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    telefone = json['telefone'] != null
        ? new Telefone.fromJson(json['telefone'])
        : null;
    telefone2 = json['telefone2'] != null
        ? new Telefone.fromJson(json['telefone2'])
        : null;
    celular =
        json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this.email;
    if (this.telefone != null) {
      data['telefone'] = this.telefone.toJson();
    }
    if (this.telefone2 != null) {
      data['telefone2'] = this.telefone2.toJson();
    }
    if (this.celular != null) {
      data['celular'] = this.celular.toJson();
    }
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


// class ClienteEditar {
//   int _id;
//   int _empresaId;
//   String _cnpJCPF;
//   String _rg;
//   String _im;
//   String _ie;
//   String _nome;
//   String _nomeFantasia;
//   String _codigo;
//   int _situacaoParceiro;
//   int _pessoa;
//   int _ramoAtividadeId;
//   int _regiaoId;
//   int _grupoContatoId;
//   String _dataCadastro;
//   EnderecoPrincipal _enderecoPrincipal;
//   ContatoPrincipal _contatoPrincipal;
//   int _tabelaPrecoId;
//   int _vendedorId;
//   double _totalLimite;
//   int _tipoLimite;
//   double _limiteConsumido;
//   double _limiteRestante;

//   ClienteEditar(
//       {int id,
//       int empresaId,
//       String cnpJCPF,
//       String rg,
//       String im,
//       String ie,
//       String nome,
//       String nomeFantasia,
//       String codigo,
//       int situacaoParceiro,
//       int pessoa,
//       int ramoAtividadeId,
//       int regiaoId,
//       int grupoContatoId,
//       String dataCadastro,
//       EnderecoPrincipal enderecoPrincipal,
//       ContatoPrincipal contatoPrincipal,
//       int tabelaPrecoId,
//       int vendedorId,
//       double totalLimite,
//       int tipoLimite,
//       double limiteConsumido,
//       double limiteRestante}) {
//     this._id = id;
//     this._empresaId = empresaId;
//     this._cnpJCPF = cnpJCPF;
//     this._rg = rg;
//     this._im = im;
//     this._ie = ie;
//     this._nome = nome;
//     this._nomeFantasia = nomeFantasia;
//     this._codigo = codigo;
//     this._situacaoParceiro = situacaoParceiro;
//     this._pessoa = pessoa;
//     this._ramoAtividadeId = ramoAtividadeId;
//     this._regiaoId = regiaoId;
//     this._grupoContatoId = grupoContatoId;
//     this._dataCadastro = dataCadastro;
//     this._enderecoPrincipal = enderecoPrincipal;
//     this._contatoPrincipal = contatoPrincipal;
//     this._tabelaPrecoId = tabelaPrecoId;
//     this._vendedorId = vendedorId;
//     this._totalLimite = totalLimite;
//     this._tipoLimite = tipoLimite;
//     this._limiteConsumido = limiteConsumido;
//     this._limiteRestante = limiteRestante;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get empresaId => _empresaId;
//   set empresaId(int empresaId) => _empresaId = empresaId;
//   String get cnpJCPF => _cnpJCPF;
//   set cnpJCPF(String cnpJCPF) => _cnpJCPF = cnpJCPF;
//   String get rg => _rg;
//   set rg(String rg) => _rg = rg;
//   String get im => _im;
//   set im(String im) => _im = im;
//   String get ie => _ie;
//   set ie(String ie) => _ie = ie;
//   String get nome => _nome;
//   set nome(String nome) => _nome = nome;
//   String get nomeFantasia => _nomeFantasia;
//   set nomeFantasia(String nomeFantasia) => _nomeFantasia = nomeFantasia;
//   String get codigo => _codigo;
//   set codigo(String codigo) => _codigo = codigo;
//   int get situacaoParceiro => _situacaoParceiro;
//   set situacaoParceiro(int situacaoParceiro) =>
//       _situacaoParceiro = situacaoParceiro;
//   int get pessoa => _pessoa;
//   set pessoa(int pessoa) => _pessoa = pessoa;
//   int get ramoAtividadeId => _ramoAtividadeId;
//   set ramoAtividadeId(int ramoAtividadeId) =>
//       _ramoAtividadeId = ramoAtividadeId;
//   int get regiaoId => _regiaoId;
//   set regiaoId(int regiaoId) => _regiaoId = regiaoId;
//   int get grupoContatoId => _grupoContatoId;
//   set grupoContatoId(int grupoContatoId) => _grupoContatoId = grupoContatoId;
//   String get dataCadastro => _dataCadastro;
//   set dataCadastro(String dataCadastro) => _dataCadastro = dataCadastro;
//   EnderecoPrincipal get enderecoPrincipal => _enderecoPrincipal;
//   set enderecoPrincipal(EnderecoPrincipal enderecoPrincipal) =>
//       _enderecoPrincipal = enderecoPrincipal;
//   ContatoPrincipal get contatoPrincipal => _contatoPrincipal;
//   set contatoPrincipal(ContatoPrincipal contatoPrincipal) =>
//       _contatoPrincipal = contatoPrincipal;
//   int get tabelaPrecoId => _tabelaPrecoId;
//   set tabelaPrecoId(int tabelaPrecoId) => _tabelaPrecoId = tabelaPrecoId;
//   int get vendedorId => _vendedorId;
//   set vendedorId(int vendedorId) => _vendedorId = vendedorId;
//   double get totalLimite => _totalLimite;
//   set totalLimite(double totalLimite) => _totalLimite = totalLimite;
//   int get tipoLimite => _tipoLimite;
//   set tipoLimite(int tipoLimite) => _tipoLimite = tipoLimite;
//   double get limiteConsumido => _limiteConsumido;
//   set limiteConsumido(double limiteConsumido) =>
//       _limiteConsumido = limiteConsumido;
//   double get limiteRestante => _limiteRestante;
//   set limiteRestante(double limiteRestante) => _limiteRestante = limiteRestante;

//   ClienteEditar.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _empresaId = json['empresaId'];
//     _cnpJCPF = json['cnpJ_CPF'];
//     _rg = json['rg'];
//     _im = json['im'];
//     _ie = json['ie'];
//     _nome = json['nome'];
//     _nomeFantasia = json['nomeFantasia'];
//     _codigo = json['codigo'];
//     _situacaoParceiro = json['situacaoParceiro'];
//     _pessoa = json['pessoa'];
//     _ramoAtividadeId = json['ramoAtividadeId'];
//     _regiaoId = json['regiaoId'];
//     _grupoContatoId = json['grupoContatoId'];
//     _dataCadastro = json['dataCadastro'];
//     _enderecoPrincipal = json['enderecoPrincipal'] != null
//         ? new EnderecoPrincipal.fromJson(json['enderecoPrincipal'])
//         : null;
//     _contatoPrincipal = json['contatoPrincipal'] != null
//         ? new ContatoPrincipal.fromJson(json['contatoPrincipal'])
//         : null;
//     _tabelaPrecoId = json['tabelaPrecoId'];
//     _vendedorId = json['vendedorId'];
//     _totalLimite = json['totalLimite'];
//     _tipoLimite = json['tipoLimite'];
//     _limiteConsumido = json['limiteConsumido'];
//     _limiteRestante = json['limiteRestante'];
//   }

//   Map<String, dynamic> novoClienteJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['empresaId'] = this._empresaId;
//     data['cnpJ_CPF'] = this._cnpJCPF;
//     data['rg'] = this._rg;
//     data['im'] = this._im;
//     data['ie'] = this._ie;
//     data['nome'] = this._nome;
//     data['nomeFantasia'] = this._nomeFantasia;
//     data['codigo'] = this._codigo;
//     data['situacaoParceiro'] = this._situacaoParceiro;
//     data['pessoa'] = this._pessoa;
//     data['ramoAtividadeId'] = this._ramoAtividadeId;
//     data['regiaoId'] = this._regiaoId;
//     data['grupoContatoId'] = this._grupoContatoId;
//     if (this._enderecoPrincipal != null) {
//       data['enderecoPrincipal'] = this._enderecoPrincipal.toJson();
//     }
//     if (this._contatoPrincipal != null) {
//       data['contatoPrincipal'] = this._contatoPrincipal.toJson();
//     }
//     data['tabelaPrecoId'] = this._tabelaPrecoId;
//     data['vendedorId'] = this._vendedorId;
//     data['totalLimite'] = this._totalLimite;
//     data['tipoLimite'] = this._tipoLimite;
//     data['limiteConsumido'] = this._limiteConsumido;
//     data['limiteRestante'] = this._limiteRestante;
//     return data;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['empresaId'] = this._empresaId;
//     data['cnpJ_CPF'] = this._cnpJCPF;
//     data['rg'] = this._rg;
//     data['im'] = this._im;
//     data['ie'] = this._ie;
//     data['nome'] = this._nome;
//     data['nomeFantasia'] = this._nomeFantasia;
//     data['codigo'] = this._codigo;
//     data['situacaoParceiro'] = this._situacaoParceiro;
//     data['pessoa'] = this._pessoa;
//     data['ramoAtividadeId'] = this._ramoAtividadeId;
//     data['regiaoId'] = this._regiaoId;
//     data['grupoContatoId'] = this._grupoContatoId;
//     data['dataCadastro'] = this._dataCadastro;
//     if (this._enderecoPrincipal != null) {
//       data['enderecoPrincipal'] = this._enderecoPrincipal.toJson();
//     }
//     if (this._contatoPrincipal != null) {
//       data['contatoPrincipal'] = this._contatoPrincipal.toJson();
//     }
//     data['tabelaPrecoId'] = this._tabelaPrecoId;
//     data['vendedorId'] = this._vendedorId;
//     data['totalLimite'] = this._totalLimite;
//     data['tipoLimite'] = this._tipoLimite;
//     data['limiteConsumido'] = this._limiteConsumido;
//     data['limiteRestante'] = this._limiteRestante;
//     return data;
//   }
// }

// class EnderecoPrincipal {
//   String _cep;
//   String _codigoIBGE;
//   String _endereco;
//   String _numero;
//   String _bairro;
//   String _complemento;
//   String _cidade;
//   String _uf;
//   int _cidadeEstrangeiroId;

//   EnderecoPrincipal(
//       {String cep,
//       String codigoIBGE,
//       String endereco,
//       String numero,
//       String bairro,
//       String complemento,
//       String cidade,
//       String uf,
//       int cidadeEstrangeiroId}) {
//     this._cep = cep;
//     this._codigoIBGE = codigoIBGE;
//     this._endereco = endereco;
//     this._numero = numero;
//     this._bairro = bairro;
//     this._complemento = complemento;
//     this._cidade = cidade;
//     this._uf = uf;
//     this._cidadeEstrangeiroId = cidadeEstrangeiroId;
//   }

//   String get cep => _cep;
//   set cep(String cep) => _cep = cep;
//   String get codigoIBGE => _codigoIBGE;
//   set codigoIBGE(String codigoIBGE) => _codigoIBGE = codigoIBGE;
//   String get endereco => _endereco;
//   set endereco(String endereco) => _endereco = endereco;
//   String get numero => _numero;
//   set numero(String numero) => _numero = numero;
//   String get bairro => _bairro;
//   set bairro(String bairro) => _bairro = bairro;
//   String get complemento => _complemento;
//   set complemento(String complemento) => _complemento = complemento;
//   String get cidade => _cidade;
//   set cidade(String cidade) => _cidade = cidade;
//   String get uf => _uf;
//   set uf(String uf) => _uf = uf;
//   int get cidadeEstrangeiroId => _cidadeEstrangeiroId;
//   set cidadeEstrangeiroId(int cidadeEstrangeiroId) =>
//       _cidadeEstrangeiroId = cidadeEstrangeiroId;

//   EnderecoPrincipal.fromJson(Map<String, dynamic> json) {
//     _cep = json['cep'];
//     _codigoIBGE = json['codigoIBGE'];
//     _endereco = json['endereco'];
//     _numero = json['numero'];
//     _bairro = json['bairro'];
//     _complemento = json['complemento'];
//     _cidade = json['cidade'];
//     _uf = json['uf'];
//     _cidadeEstrangeiroId = json['cidadeEstrangeiroId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['cep'] = this._cep;
//     data['codigoIBGE'] = this._codigoIBGE;
//     data['endereco'] = this._endereco;
//     data['numero'] = this._numero;
//     data['bairro'] = this._bairro;
//     data['complemento'] = this._complemento;
//     data['cidade'] = this._cidade;
//     data['uf'] = this._uf;
//     data['cidadeEstrangeiroId'] = this._cidadeEstrangeiroId;
//     return data;
//   }
// }

// class ContatoPrincipal {
//   String _email;
//   Telefone _telefone;
//   Telefone _telefone2;
//   Telefone _celular;

//   ContatoPrincipal(
//       {String email, Telefone telefone, Telefone telefone2, Telefone celular}) {
//     this._email = email;
//     this._telefone = telefone;
//     this._telefone2 = telefone2;
//     this._celular = celular;
//   }

//   String get email => _email;
//   set email(String email) => _email = email;
//   Telefone get telefone => _telefone;
//   set telefone(Telefone telefone) => _telefone = telefone;
//   Telefone get telefone2 => _telefone2;
//   set telefone2(Telefone telefone2) => _telefone2 = telefone2;
//   Telefone get celular => _celular;
//   set celular(Telefone celular) => _celular = celular;

//   ContatoPrincipal.fromJson(Map<String, dynamic> json) {
//     _email = json['email'];
//     _telefone = json['telefone'] != null
//         ? new Telefone.fromJson(json['telefone'])
//         : null;
//     _telefone2 = json['telefone2'] != null
//         ? new Telefone.fromJson(json['telefone2'])
//         : null;
//     _celular =
//         json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['email'] = this._email;
//     if (this._telefone != null) {
//       data['telefone'] = this._telefone.toJson();
//     }
//     if (this._telefone2 != null) {
//       data['telefone2'] = this._telefone2.toJson();
//     }
//     if (this._celular != null) {
//       data['celular'] = this._celular.toJson();
//     }
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
