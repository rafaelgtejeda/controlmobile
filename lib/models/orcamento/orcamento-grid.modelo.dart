
class OrcamentoGrid {
  int id;
  String data;
  int numero;
  int status;
  double valor;
  String vendedor;
  String cliente;
  bool isSelected = false;
  bool offline = false;
  int offlineId;

  OrcamentoGrid(
      {this.id,
      this.data,
      this.status,
      this.valor,
      this.vendedor,
      this.cliente});

  OrcamentoGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'];
    numero = json['numero'];
    status = json['status'];
    valor = json['valor'];
    vendedor = json['vendedor'];
    cliente = json['cliente'];
  }

  OrcamentoGrid.fromJsonOffline(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'];
    numero = json['numero'];
    status = json['status'];
    valor = json['valor'];
    vendedor = json['vendedor'];
    cliente = json['cliente'];
    offline = json['offline'];
    offlineId = json['offlineId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['data'] = this.data;
    data['status'] = this.status;
    data['numero'] = this.numero;
    data['valor'] = this.valor;
    data['vendedor'] = this.vendedor;
    data['cliente'] = this.cliente;
    return data;
  }

  Map<String, dynamic> toJsonOffline() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['data'] = this.data;
    data['status'] = this.status;
    data['numero'] = this.numero;
    data['valor'] = this.valor;
    data['vendedor'] = this.vendedor;
    data['cliente'] = this.cliente;
    data['offline'] = this.offline;
    data['offlineId'] = this.offlineId;
    return data;
  }
}
