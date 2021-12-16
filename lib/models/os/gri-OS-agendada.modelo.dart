class GridOSAgendadaModelo {
  int id;
  int osId;
  int numeroOS;
  int status;
  String descStatus;
  int statusTecnico;
  String descStatusTecnico;
  String descTipo;
  String horaInicio;
  String horaFim;
  String endereco;
  String numero;
  String complemento;
  String bairro;
  String estado;
  String cidade;
  String cep;
  String nomeCliente;
  String nomeFantasiaCliente;
  String data;

  GridOSAgendadaModelo(
      {this.id,
      this.osId,
      this.numeroOS,
      this.status,
      this.descStatus,
      this.statusTecnico,
      this.descStatusTecnico,
      this.descTipo,
      this.horaInicio,
      this.horaFim,
      this.endereco,
      this.numero,
      this.complemento,
      this.bairro,
      this.estado,
      this.cidade,
      this.cep,
      this.nomeCliente,
      this.nomeFantasiaCliente,
      this.data});

  GridOSAgendadaModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    osId = json['osId'];
    numeroOS = json['numeroOS'];
    status = json['status'];
    descStatus = json['descStatus'];
    statusTecnico = json['statusTecnico'];
    descStatusTecnico = json['descStatusTecnico'];
    descTipo = json['descTipo'];
    horaInicio = json['horaInicio'];
    horaFim = json['horaFim'];
    endereco = json['endereco'];
    numero = json['numero'];
    complemento = json['complemento'];
    bairro = json['bairro'];
    estado = json['estado'];
    cidade = json['cidade'];
    cep = json['cep'];
    nomeCliente = json['nomeCliente'];
    nomeFantasiaCliente = json['nomeFantasiaCliente'];
    DateTime _dataConvertida = DateTime.parse(json['data']);
    data = DateTime(_dataConvertida.year, _dataConvertida.month, _dataConvertida.day).toIso8601String();
    // data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['osId'] = this.osId;
    data['numeroOS'] = this.numeroOS;
    data['status'] = this.status;
    data['descStatus'] = this.descStatus;
    data['statusTecnico'] = this.statusTecnico;
    data['descStatusTecnico'] = this.descStatusTecnico;
    data['descTipo'] = this.descTipo;
    data['horaInicio'] = this.horaInicio;
    data['horaFim'] = this.horaFim;
    data['endereco'] = this.endereco;
    data['numero'] = this.numero;
    data['complemento'] = this.complemento;
    data['bairro'] = this.bairro;
    data['estado'] = this.estado;
    data['cidade'] = this.cidade;
    data['cep'] = this.cep;
    data['nomeCliente'] = this.nomeCliente;
    data['nomeFantasiaCliente'] = this.nomeFantasiaCliente;
    // DateTime _dataConvertida = DateTime.parse(this.data);
    // data['data'] = DateTime(_dataConvertida.year, _dataConvertida.month, _dataConvertida.day).toIso8601String();
    data['data'] = this.data;
    return data;
  }
}



// class GridOSAgendada {
  
//   int _id;
//   int _osId;
//   int _numeroOS;
//   String _descStatus;
//   String _descStatusTecnico;
//   String _descTipo;
//   String _horaInicio;
//   String _horaFim;
//   String _endereco;
//   String _numero;
//   String _complemento;
//   String _bairro;
//   String _estado;
//   String _cidade;
//   String _cep;
//   String _nomeCliente;
//   String _nomeFantasiaCliente;

//   GridOSAgendada(
//       {int id,
//       int osId,
//       int numeroOS,
//       String descStatus,
//       String descStatusTecnico,
//       String descTipo,
//       String horaInicio,
//       String horaFim,
//       String endereco,
//       String numero,
//       String complemento,
//       String bairro,
//       String estado,
//       String cidade,
//       String cep,
//       String nomeCliente,
//       String nomeFantasiaCliente}) {
//     this._id = id;
//     this._osId = osId;
//     this._numeroOS = numeroOS;
//     this._descStatus = descStatus;
//     this._descStatusTecnico = descStatusTecnico;
//     this._descTipo = descTipo;
//     this._horaInicio = horaInicio;
//     this._horaFim = horaFim;
//     this._endereco = endereco;
//     this._numero = numero;
//     this._complemento = complemento;
//     this._bairro = bairro;
//     this._estado = estado;
//     this._cidade = cidade;
//     this._cep = cep;
//     this._nomeCliente = nomeCliente;
//     this._nomeFantasiaCliente = nomeFantasiaCliente;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get osId => _osId;
//   set osId(int osId) => _osId = osId;
//   int get numeroOS => _numeroOS;
//   set numeroOS(int numeroOS) => _numeroOS = numeroOS;
//   String get descStatus => _descStatus;
//   set descStatus(String descStatus) => _descStatus = descStatus;
//   String get descStatusTecnico => _descStatusTecnico;
//   set descStatusTecnico(String descStatusTecnico) =>
//       _descStatusTecnico = descStatusTecnico;
//   String get descTipo => _descTipo;
//   set descTipo(String descTipo) => _descTipo = descTipo;
//   String get horaInicio => _horaInicio;
//   set horaInicio(String horaInicio) => _horaInicio = horaInicio;
//   String get horaFim => _horaFim;
//   set horaFim(String horaFim) => _horaFim = horaFim;
//   String get endereco => _endereco;
//   set endereco(String endereco) => _endereco = endereco;
//   String get numero => _numero;
//   set numero(String numero) => _numero = numero;
//   String get complemento => _complemento;
//   set complemento(String complemento) => _complemento = complemento;
//   String get bairro => _bairro;
//   set bairro(String bairro) => _bairro = bairro;
//   String get estado => _estado;
//   set estado(String estado) => _estado = estado;
//   String get cidade => _cidade;
//   set cidade(String cidade) => _cidade = cidade;
//   String get cep => _cep;
//   set cep(String cep) => _cep = cep;
//   String get nomeCliente => _nomeCliente;
//   set nomeCliente(String nomeCliente) => _nomeCliente = nomeCliente;
//   String get nomeFantasiaCliente => _nomeFantasiaCliente;
//   set nomeFantasiaCliente(String nomeFantasiaCliente) =>
//       _nomeFantasiaCliente = nomeFantasiaCliente;

//   GridOSAgendada.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _osId = json['osId'];
//     _numeroOS = json['numeroOS'];
//     _descStatus = json['descStatus'];
//     _descStatusTecnico = json['descStatusTecnico'];
//     _descTipo = json['descTipo'];
//     _horaInicio = json['horaInicio'];
//     _horaFim = json['horaFim'];
//     _endereco = json['endereco'];
//     _numero = json['numero'];
//     _complemento = json['complemento'];
//     _bairro = json['bairro'];
//     _estado = json['estado'];
//     _cidade = json['cidade'];
//     _cep = json['cep'];
//     _nomeCliente = json['nomeCliente'];
//     _nomeFantasiaCliente = json['nomeFantasiaCliente'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['osId'] = this._osId;
//     data['numeroOS'] = this._numeroOS;
//     data['descStatus'] = this._descStatus;
//     data['descStatusTecnico'] = this._descStatusTecnico;
//     data['descTipo'] = this._descTipo;
//     data['horaInicio'] = this._horaInicio;
//     data['horaFim'] = this._horaFim;
//     data['endereco'] = this._endereco;
//     data['numero'] = this._numero;
//     data['complemento'] = this._complemento;
//     data['bairro'] = this._bairro;
//     data['estado'] = this._estado;
//     data['cidade'] = this._cidade;
//     data['cep'] = this._cep;
//     data['nomeCliente'] = this._nomeCliente;
//     data['nomeFantasiaCliente'] = this._nomeFantasiaCliente;
//     return data;
//   }
// }
