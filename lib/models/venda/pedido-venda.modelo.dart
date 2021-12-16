class PedidoVendaGrid {
  int id;
  int numero;
  String dataOrcamento;
  int status;
  double valor;
  String vendedor;
  String cliente;

  PedidoVendaGrid(
      {this.id,
      this.numero,
      this.dataOrcamento,
      this.status,
      this.valor,
      this.vendedor,
      this.cliente});

  PedidoVendaGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    numero = json['numero'];
    dataOrcamento = json['dataOrcamento'];
    status = json['status'];
    valor = json['valor'];
    vendedor = json['vendedor'];
    cliente = json['cliente'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['numero'] = this.numero;
    data['dataOrcamento'] = this.dataOrcamento;
    data['status'] = this.status;
    data['valor'] = this.valor;
    data['vendedor'] = this.vendedor;
    data['cliente'] = this.cliente;
    return data;
  }
}
