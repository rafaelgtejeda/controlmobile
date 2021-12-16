class ParametroModelo {
  int id;
  int param;
  String valor;
  int empresaId;

  ParametroModelo({this.id, this.param, this.valor, this.empresaId});

  ParametroModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    param = json['param'];
    valor = json['valor'];
    empresaId = json['empresaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['param'] = this.param;
    data['valor'] = this.valor;
    data['empresaId'] = this.empresaId;
    return data;
  }
}
