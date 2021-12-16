class DashboardVendasModelo {
  double totalVendas;
  double totalVendasPdv;
  double totalOrcamento;

  DashboardVendasModelo(
      {this.totalVendas, this.totalVendasPdv, this.totalOrcamento});

  DashboardVendasModelo.fromJson(Map<String, dynamic> json) {
    totalVendas = json['totalVendas'];
    totalVendasPdv = json['totalVendasPdv'];
    totalOrcamento = json['totalOrcamento'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalVendas'] = this.totalVendas;
    data['totalVendasPdv'] = this.totalVendasPdv;
    data['totalOrcamento'] = this.totalOrcamento;
    return data;
  }

  clear() {
    this.totalVendas = 0;
    this.totalVendasPdv = 0;
    this.totalOrcamento = 0;
  }
}
