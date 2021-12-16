class CartaoCreditoGrid {
  int id;
  String titular;
  String bandeira;
  String numero;
  bool isSelected = false;

  CartaoCreditoGrid({this.id, this.titular, this.bandeira, this.numero});

  CartaoCreditoGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    titular = json['titular'];
    bandeira = json['bandeira'];
    numero = json['numero'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['titular'] = this.titular;
    data['bandeira'] = this.bandeira;
    data['numero'] = this.numero;
    return data;
  }
}

// class CartaoCreditoGrid {
//   int _id;
//   String _titular;
//   String _bandeira;
//   String _numero;

//   CartaoCreditoGrid({int id, String titular, String bandeira, String numero}) {
//     this._id = id;
//     this._titular = titular;
//     this._bandeira = bandeira;
//     this._numero = numero;
//   }

//   int get id => _id;
//   set id(int id) => _id = id;
//   String get titular => _titular;
//   set titular(String titular) => _titular = titular;
//   String get bandeira => _bandeira;
//   set bandeira(String bandeira) => _bandeira = bandeira;
//   String get numero => _numero;
//   set numero(String numero) => _numero = numero;

//   CartaoCreditoGrid.fromJson(Map<String, dynamic> json) {
//     _id = json['id'];
//     _titular = json['titular'];
//     _bandeira = json['bandeira'];
//     _numero = json['numero'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['id'] = this._id;
//     data['titular'] = this._titular;
//     data['bandeira'] = this._bandeira;
//     data['numero'] = this._numero;
//     return data;
//   }
// }
