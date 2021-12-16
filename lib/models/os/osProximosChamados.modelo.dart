class OsProximosChamados {
  int id;
  int saldoDiario;
  String mesDescricao;
  String diaDescricao;
  String dia;
  String mes;
  String ano;
  int date;

  OsProximosChamados(
      {this.id,
      this.saldoDiario,
      this.mesDescricao,
      this.diaDescricao,
      this.dia,
      this.mes,
      this.ano,
      this.date});

  OsProximosChamados.fromJson(Map<String, dynamic> json) {
    if(json['id'] == null) {
      id = int.parse('${json['dia']}${json['mes']}${json['ano']}');
    }
    else {
      id = json['id'];
    }
    saldoDiario = json['saldoDiario'];
    mesDescricao = json['mesDescricao'];
    diaDescricao = json['diaDescricao'];
    dia = json['dia'];
    mes = json['mes'];
    ano = json['ano'];
    if(json['date'] == null) {
      // date = DateTime.utc(int.parse(ano), int.parse(mes), int.parse(dia)).millisecondsSinceEpoch;
      date = DateTime(int.parse(ano), int.parse(mes), int.parse(dia)).millisecondsSinceEpoch;
    }
    else {
      date = json['date'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = int.parse('${this.dia}${this.mes}${this.ano}');
    data['saldoDiario'] = this.saldoDiario;
    data['mesDescricao'] = this.mesDescricao;
    data['diaDescricao'] = this.diaDescricao;
    data['dia'] = this.dia;
    data['mes'] = this.mes;
    data['ano'] = this.ano;
    // data['date'] = this.date;
    data['date'] = DateTime(int.parse(ano), int.parse(mes), int.parse(dia)).millisecondsSinceEpoch;
    // data['date'] = DateTime.utc(int.parse(ano), int.parse(mes), int.parse(dia)).millisecondsSinceEpoch;
    return data;
  }
}


// class OsProximosChamados {
//   int _saldoDiario;
//   String _mesDescricao;
//   String _diaDescricao;
//   String _dia;
//   String _mes;
//   String _ano;

//   OsProximosChamados(
//       {int saldoDiario,
//       String mesDescricao,
//       String diaDescricao,
//       String dia,
//       String mes,
//       String ano}) {
//     this._saldoDiario = saldoDiario;
//     this._mesDescricao = mesDescricao;
//     this._diaDescricao = diaDescricao;
//     this._dia = dia;
//     this._mes = mes;
//     this._ano = ano;
//   }

//   int get saldoDiario => _saldoDiario;
//   set saldoDiario(int saldoDiario) => _saldoDiario = saldoDiario;
//   String get mesDescricao => _mesDescricao;
//   set mesDescricao(String mesDescricao) => _mesDescricao = mesDescricao;
//   String get diaDescricao => _diaDescricao;
//   set diaDescricao(String diaDescricao) => _diaDescricao = diaDescricao;
//   String get dia => _dia;
//   set dia(String dia) => _dia = dia;
//   String get mes => _mes;
//   set mes(String mes) => _mes = mes;
//   String get ano => _ano;
//   set ano(String ano) => _ano = ano;

//   OsProximosChamados.fromJson(Map<String, dynamic> json) {
//     _saldoDiario = json['saldoDiario'];
//     _mesDescricao = json['mesDescricao'];
//     _diaDescricao = json['diaDescricao'];
//     _dia = json['dia'];
//     _mes = json['mes'];
//     _ano = json['ano'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['saldoDiario'] = this._saldoDiario;
//     data['mesDescricao'] = this._mesDescricao;
//     data['diaDescricao'] = this._diaDescricao;
//     data['dia'] = this._dia;
//     data['mes'] = this._mes;
//     data['ano'] = this._ano;
//     return data;
//   }
// }




// class OsProximosChamados {
//   int _saldoDiario;
//   String _mesDescricao;
//   int _dia;
//   String _diaDescricao;
//   int _ano;

//   OsProximosChamados(
//       {int saldoDiario,
//       String mesDescricao,
//       int dia,
//       String diaDescricao,
//       int ano}) {
//     this._saldoDiario = saldoDiario;
//     this._mesDescricao = mesDescricao;
//     this._dia = dia;
//     this._diaDescricao = diaDescricao;
//     this._ano = ano;
//   }

//   int get saldoDiario => _saldoDiario;
//   set saldoDiario(int saldoDiario) => _saldoDiario = saldoDiario;
//   String get mesDescricao => _mesDescricao;
//   set mesDescricao(String mesDescricao) => _mesDescricao = mesDescricao;
//   int get dia => _dia;
//   set dia(int dia) => _dia = dia;
//   String get diaDescricao => _diaDescricao;
//   set diaDescricao(String diaDescricao) => _diaDescricao = diaDescricao;
//   int get ano => _ano;
//   set ano(int ano) => _ano = ano;

//   OsProximosChamados.fromJson(Map<String, dynamic> json) {
//     _saldoDiario = json['saldoDiario'];
//     _mesDescricao = json['mesDescricao'];
//     _dia = json['dia'];
//     _diaDescricao = json['diaDescricao'];
//     _ano = json['ano'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['saldoDiario'] = this._saldoDiario;
//     data['mesDescricao'] = this._mesDescricao;
//     data['dia'] = this._dia;
//     data['diaDescricao'] = this._diaDescricao;
//     data['ano'] = this._ano;
//     return data;
//   }
// }




// class OsProximosChamados {
//   String _id;
//   bool _successo;
//   String _erroCodigo;
//   String _erroDescricao;
//   List<Entidade> _entidade;
//   List<Erros> _erros;

//   OsProximosChamados(
//       {String id,
//       bool successo,
//       String erroCodigo,
//       String erroDescricao,
//       List<Entidade> entidade,
//       List<Erros> erros}) {
//     this._id = id;
//     this._successo = successo;
//     this._erroCodigo = erroCodigo;
//     this._erroDescricao = erroDescricao;
//     this._entidade = entidade;
//     this._erros = erros;
//   }

//   String get id => _id;
//   set id(String id) => _id = id;
//   bool get successo => _successo;
//   set successo(bool successo) => _successo = successo;
//   String get erroCodigo => _erroCodigo;
//   set erroCodigo(String erroCodigo) => _erroCodigo = erroCodigo;
//   String get erroDescricao => _erroDescricao;
//   set erroDescricao(String erroDescricao) => _erroDescricao = erroDescricao;
//   List<Entidade> get entidade => _entidade;
//   set entidade(List<Entidade> entidade) => _entidade = entidade;
//   List<Erros> get erros => _erros;
//   set erros(List<Erros> erros) => _erros = erros;

//   OsProximosChamados.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _successo = json['successo'];
//     _erroCodigo = json['erroCodigo'];
//     _erroDescricao = json['erroDescricao'];
//     if (json['entidade'] != null) {
//       _entidade = new List<Entidade>();
//       json['entidade'].forEach((v) {
//         _entidade.add(new Entidade.fromJson(v));
//       });
//     }
//     if (json['erros'] != null) {
//       _erros = new List<Erros>();
//       json['erros'].forEach((v) {
//         _erros.add(new Erros.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['successo'] = this._successo;
//     data['erroCodigo'] = this._erroCodigo;
//     data['erroDescricao'] = this._erroDescricao;
//     if (this._entidade != null) {
//       data['entidade'] = this._entidade.map((v) => v.toJson()).toList();
//     }
//     if (this._erros != null) {
//       data['erros'] = this._erros.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Entidade {
//   int _saldoDiario;
//   String _mesDescricao;
//   int _dia;
//   String _diaDescricao;
//   int _ano;

//   Entidade(
//       {int saldoDiario,
//       String mesDescricao,
//       int dia,
//       String diaDescricao,
//       int ano}) {
//     this._saldoDiario = saldoDiario;
//     this._mesDescricao = mesDescricao;
//     this._dia = dia;
//     this._diaDescricao = diaDescricao;
//     this._ano = ano;
//   }

//   int get saldoDiario => _saldoDiario;
//   set saldoDiario(int saldoDiario) => _saldoDiario = saldoDiario;
//   String get mesDescricao => _mesDescricao;
//   set mesDescricao(String mesDescricao) => _mesDescricao = mesDescricao;
//   int get dia => _dia;
//   set dia(int dia) => _dia = dia;
//   String get diaDescricao => _diaDescricao;
//   set diaDescricao(String diaDescricao) => _diaDescricao = diaDescricao;
//   int get ano => _ano;
//   set ano(int ano) => _ano = ano;

//   Entidade.fromJson(Map<String, dynamic> json) {
//     _saldoDiario = json['saldoDiario'];
//     _mesDescricao = json['mesDescricao'];
//     _dia = json['dia'];
//     _diaDescricao = json['diaDescricao'];
//     _ano = json['ano'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['saldoDiario'] = this._saldoDiario;
//     data['mesDescricao'] = this._mesDescricao;
//     data['dia'] = this._dia;
//     data['diaDescricao'] = this._diaDescricao;
//     data['ano'] = this._ano;
//     return data;
//   }
// }

// class Erros {
//   String _descricao;
//   String _erroDescricao;

//   Erros({String descricao, String erroDescricao}) {
//     this._descricao = descricao;
//     this._erroDescricao = erroDescricao;
//   }

//   String get descricao => _descricao;
//   set descricao(String descricao) => _descricao = descricao;
//   String get erroDescricao => _erroDescricao;
//   set erroDescricao(String erroDescricao) => _erroDescricao = erroDescricao;

//   Erros.fromJson(Map<String, dynamic> json) {
//     _descricao = json['descricao'];
//     _erroDescricao = json['erroDescricao'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['descricao'] = this._descricao;
//     data['erroDescricao'] = this._erroDescricao;
//     return data;
//   }
// }
