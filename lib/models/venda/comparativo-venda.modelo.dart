class ComparativoVendaModelo {
  int mes;
  int ano;
  double total;

  ComparativoVendaModelo({this.mes, this.ano, this.total});

  ComparativoVendaModelo.fromJson(Map<String, dynamic> json) {
    mes = json['mes'];
    ano = json['ano'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mes'] = this.mes;
    data['ano'] = this.ano;
    data['total'] = this.total;
    return data;
  }
}
