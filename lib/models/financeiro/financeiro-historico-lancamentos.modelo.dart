class FinanceiroHistoricoLancamentosModelo {
  double totalReceitasMes1;
  double totalReceitasMes2;
  double totalReceitasMes3;
  double totalReceitasMes4;
  double totalDespesasMes1;
  double totalDespesasMes2;
  double totalDespesasMes3;
  double totalDespesasMes4;
  int mes1;
  int mes2;
  int mes3;
  int mes4;

  FinanceiroHistoricoLancamentosModelo(
      {this.totalReceitasMes1,
      this.totalReceitasMes2,
      this.totalReceitasMes3,
      this.totalReceitasMes4,
      this.totalDespesasMes1,
      this.totalDespesasMes2,
      this.totalDespesasMes3,
      this.totalDespesasMes4,
      this.mes1,
      this.mes2,
      this.mes3,
      this.mes4});

  FinanceiroHistoricoLancamentosModelo.fromJson(Map<String, dynamic> json) {
    totalReceitasMes1 = json['totalReceitasMes1'];
    totalReceitasMes2 = json['totalReceitasMes2'];
    totalReceitasMes3 = json['totalReceitasMes3'];
    totalReceitasMes4 = json['totalReceitasMes4'];
    totalDespesasMes1 = json['totalDespesasMes1'];
    totalDespesasMes2 = json['totalDespesasMes2'];
    totalDespesasMes3 = json['totalDespesasMes3'];
    totalDespesasMes4 = json['totalDespesasMes4'];
    mes1 = json['mes1'];
    mes2 = json['mes2'];
    mes3 = json['mes3'];
    mes4 = json['mes4'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalReceitasMes1'] = this.totalReceitasMes1;
    data['totalReceitasMes2'] = this.totalReceitasMes2;
    data['totalReceitasMes3'] = this.totalReceitasMes3;
    data['totalReceitasMes4'] = this.totalReceitasMes4;
    data['totalDespesasMes1'] = this.totalDespesasMes1;
    data['totalDespesasMes2'] = this.totalDespesasMes2;
    data['totalDespesasMes3'] = this.totalDespesasMes3;
    data['totalDespesasMes4'] = this.totalDespesasMes4;
    data['mes1'] = this.mes1;
    data['mes2'] = this.mes2;
    data['mes3'] = this.mes3;
    data['mes4'] = this.mes4;
    return data;
  }
}
