class LimiteCreditoGrid {
  List<Lista> lista;
  Sumario sumario;

  LimiteCreditoGrid({this.lista, this.sumario});

  LimiteCreditoGrid.fromJson(Map<String, dynamic> json) {
    if (json['lista'] != null) {
      lista = new List<Lista>();
      json['lista'].forEach((v) {
        lista.add(new Lista.fromJson(v));
      });
    }
    sumario =
        json['sumario'] != null ? new Sumario.fromJson(json['sumario']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lista != null) {
      data['lista'] = this.lista.map((v) => v.toJson()).toList();
    }
    if (this.sumario != null) {
      data['sumario'] = this.sumario.toJson();
    }
    return data;
  }
}

class Lista {
  int id;
  int codigo;
  String descricao;
  double limiteProprio;
  double limiteTerceiro;
  double limiteConsumido;
  double limiteRestante;
  bool isSelected = false;

  Lista(
      {this.id,
      this.codigo,
      this.descricao,
      this.limiteProprio,
      this.limiteTerceiro,
      this.limiteConsumido,
      this.limiteRestante});

  Lista.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codigo = json['codigo'];
    descricao = json['descricao'];
    limiteProprio = json['limiteProprio'];
    limiteTerceiro = json['limiteTerceiro'];
    limiteConsumido = json['limiteConsumido'];
    limiteRestante = json['limiteRestante'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['limiteProprio'] = this.limiteProprio;
    data['limiteTerceiro'] = this.limiteTerceiro;
    data['limiteConsumido'] = this.limiteConsumido;
    data['limiteRestante'] = this.limiteRestante;
    return data;
  }
}

class Sumario {
  double totalLimiteProprio;
  double totalLimiteTerceiro;
  double totalLimiteConsumido;
  double totalLimiteRestante;

  Sumario(
      {this.totalLimiteProprio,
      this.totalLimiteTerceiro,
      this.totalLimiteConsumido,
      this.totalLimiteRestante});

  Sumario.fromJson(Map<String, dynamic> json) {
    totalLimiteProprio = json['totalLimiteProprio'];
    totalLimiteTerceiro = json['totalLimiteTerceiro'];
    totalLimiteConsumido = json['totalLimiteConsumido'];
    totalLimiteRestante = json['totalLimiteRestante'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalLimiteProprio'] = this.totalLimiteProprio;
    data['totalLimiteTerceiro'] = this.totalLimiteTerceiro;
    data['totalLimiteConsumido'] = this.totalLimiteConsumido;
    data['totalLimiteRestante'] = this.totalLimiteRestante;
    return data;
  }
}



// class LimiteCreditoGrid {
//   List<Lista> _lista;
//   Sumario _sumario;

//   LimiteCreditoGrid({List<Lista> lista, Sumario sumario}) {
//     this._lista = lista;
//     this._sumario = sumario;
//   }

//   List<Lista> get lista => _lista;
//   set lista(List<Lista> lista) => _lista = lista;
//   Sumario get sumario => _sumario;
//   set sumario(Sumario sumario) => _sumario = sumario;

//   LimiteCreditoGrid.fromJson(Map<String, dynamic> json) {
//     if (json['lista'] != null) {
//       _lista = new List<Lista>();
//       json['lista'].forEach((v) {
//         _lista.add(new Lista.fromJson(v));
//       });
//     }
//     _sumario =
//         json['sumario'] != null ? new Sumario.fromJson(json['sumario']) : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this._lista != null) {
//       data['lista'] = this._lista.map((v) => v.toJson()).toList();
//     }
//     if (this._sumario != null) {
//       data['sumario'] = this._sumario.toJson();
//     }
//     return data;
//   }
// }

// class Lista {
//   int _id;
//   int _codigo;
//   String _descricao;
//   double _limiteProprio;
//   double _limiteTerceiro;
//   double _limiteConsumido;
//   double _limiteRestante;

//   Lista(
//       {int id,
//       int codigo,
//       String descricao,
//       double limiteProprio,
//       double limiteTerceiro,
//       double limiteConsumido,
//       double limiteRestante}) {
//     this._id = id;
//     this._codigo = codigo;
//     this._descricao = descricao;
//     this._limiteProprio = limiteProprio;
//     this._limiteTerceiro = limiteTerceiro;
//     this._limiteConsumido = limiteConsumido;
//     this._limiteRestante = limiteRestante;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   int get codigo => _codigo;
//   set codigo(int codigo) => _codigo = codigo;
//   String get descricao => _descricao;
//   set descricao(String descricao) => _descricao = descricao;
//   double get limiteProprio => _limiteProprio;
//   set limiteProprio(double limiteProprio) => _limiteProprio = limiteProprio;
//   double get limiteTerceiro => _limiteTerceiro;
//   set limiteTerceiro(double limiteTerceiro) => _limiteTerceiro = limiteTerceiro;
//   double get limiteConsumido => _limiteConsumido;
//   set limiteConsumido(double limiteConsumido) =>
//       _limiteConsumido = limiteConsumido;
//   double get limiteRestante => _limiteRestante;
//   set limiteRestante(double limiteRestante) => _limiteRestante = limiteRestante;

//   Lista.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _codigo = json['codigo'];
//     _descricao = json['descricao'];
//     _limiteProprio = json['limiteProprio'];
//     _limiteTerceiro = json['limiteTerceiro'];
//     _limiteConsumido = json['limiteConsumido'];
//     _limiteRestante = json['limiteRestante'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['codigo'] = this._codigo;
//     data['descricao'] = this._descricao;
//     data['limiteProprio'] = this._limiteProprio;
//     data['limiteTerceiro'] = this._limiteTerceiro;
//     data['limiteConsumido'] = this._limiteConsumido;
//     data['limiteRestante'] = this._limiteRestante;
//     return data;
//   }
// }

// class Sumario {
//   double _totalLimiteProprio;
//   double _totalLimiteTerceiro;
//   double _totalLimiteConsumido;
//   double _totalLimiteRestante;

//   Sumario(
//       {double totalLimiteProprio,
//       double totalLimiteTerceiro,
//       double totalLimiteConsumido,
//       double totalLimiteRestante}) {
//     this._totalLimiteProprio = totalLimiteProprio;
//     this._totalLimiteTerceiro = totalLimiteTerceiro;
//     this._totalLimiteConsumido = totalLimiteConsumido;
//     this._totalLimiteRestante = totalLimiteRestante;
//   }

//   double get totalLimiteProprio => _totalLimiteProprio;
//   set totalLimiteProprio(double totalLimiteProprio) =>
//       _totalLimiteProprio = totalLimiteProprio;
//   double get totalLimiteTerceiro => _totalLimiteTerceiro;
//   set totalLimiteTerceiro(double totalLimiteTerceiro) =>
//       _totalLimiteTerceiro = totalLimiteTerceiro;
//   double get totalLimiteConsumido => _totalLimiteConsumido;
//   set totalLimiteConsumido(double totalLimiteConsumido) =>
//       _totalLimiteConsumido = totalLimiteConsumido;
//   double get totalLimiteRestante => _totalLimiteRestante;
//   set totalLimiteRestante(double totalLimiteRestante) =>
//       _totalLimiteRestante = totalLimiteRestante;

//   Sumario.fromJson(Map<String, dynamic> json) {
//     _totalLimiteProprio = json['totalLimiteProprio'];
//     _totalLimiteTerceiro = json['totalLimiteTerceiro'];
//     _totalLimiteConsumido = json['totalLimiteConsumido'];
//     _totalLimiteRestante = json['totalLimiteRestante'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['totalLimiteProprio'] = this._totalLimiteProprio;
//     data['totalLimiteTerceiro'] = this._totalLimiteTerceiro;
//     data['totalLimiteConsumido'] = this._totalLimiteConsumido;
//     data['totalLimiteRestante'] = this._totalLimiteRestante;
//     return data;
//   }
// }

