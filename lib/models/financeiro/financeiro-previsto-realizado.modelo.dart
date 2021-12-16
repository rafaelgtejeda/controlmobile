class FinanceiroPrevistoRealizadoModelo {
  double receitaBruta;
  double totalPrevistoReceita;
  double totalRealizadoDespesa;
  double totalPrevistoDespesa;
  double totalFaltaReceita;
  double totalFaltaDespesa;
  double totalGeralRealizado;
  double totalGeralPrevisto;
  double percentualRealizadoReceita;
  double percentualRealizadoDespesa;

  FinanceiroPrevistoRealizadoModelo(
      {this.receitaBruta,
      this.totalPrevistoReceita,
      this.totalRealizadoDespesa,
      this.totalPrevistoDespesa,
      this.totalFaltaReceita,
      this.totalFaltaDespesa,
      this.totalGeralRealizado,
      this.totalGeralPrevisto,
      this.percentualRealizadoReceita,
      this.percentualRealizadoDespesa});

  FinanceiroPrevistoRealizadoModelo.fromJson(Map<String, dynamic> json) {
    receitaBruta = json['receitaBruta'];
    totalPrevistoReceita = json['totalPrevistoReceita'];
    totalRealizadoDespesa = json['totalRealizadoDespesa'];
    totalPrevistoDespesa = json['totalPrevistoDespesa'];
    totalFaltaReceita = json['totalFaltaReceita'];
    totalFaltaDespesa = json['totalFaltaDespesa'];
    totalGeralRealizado = json['totalGeralRealizado'];
    totalGeralPrevisto = json['totalGeralPrevisto'];
    percentualRealizadoReceita = json['percentualRealizadoReceita'];
    percentualRealizadoDespesa = json['percentualRealizadoDespesa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['receitaBruta'] = this.receitaBruta;
    data['totalPrevistoReceita'] = this.totalPrevistoReceita;
    data['totalRealizadoDespesa'] = this.totalRealizadoDespesa;
    data['totalPrevistoDespesa'] = this.totalPrevistoDespesa;
    data['totalFaltaReceita'] = this.totalFaltaReceita;
    data['totalFaltaDespesa'] = this.totalFaltaDespesa;
    data['totalGeralRealizado'] = this.totalGeralRealizado;
    data['totalGeralPrevisto'] = this.totalGeralPrevisto;
    data['percentualRealizadoReceita'] = this.percentualRealizadoReceita;
    data['percentualRealizadoDespesa'] = this.percentualRealizadoDespesa;
    return data;
  }
}
