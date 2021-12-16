class FinanceiroDashboard {
  double saldoTotalContas;
  double contasAReceber;
  double contasAPagar;
  double receitaBruta;
  double totalPrevistoReceita;
  double totalPrevistoDespesa;
  double totalRealizadoDespesa;
  double totalFaltaReceita;
  double totalFaltaDespesa;
  double totalGeralPrevisto;
  double totalGeralRealizado;

  FinanceiroDashboard(
      {this.saldoTotalContas,
      this.contasAReceber,
      this.contasAPagar,
      this.receitaBruta,
      this.totalPrevistoReceita,
      this.totalPrevistoDespesa,
      this.totalRealizadoDespesa,
      this.totalFaltaReceita,
      this.totalFaltaDespesa,
      this.totalGeralPrevisto,
      this.totalGeralRealizado});

  FinanceiroDashboard.fromJson(Map<String, dynamic> json) {
    saldoTotalContas = json['saldoTotalContas'];
    contasAReceber = json['contasAReceber'];
    contasAPagar = json['contasAPagar'];
    receitaBruta = json['receitaBruta'];
    totalPrevistoReceita = json['totalPrevistoReceita'];
    totalPrevistoDespesa = json['totalPrevistoDespesa'];
    totalRealizadoDespesa = json['totalRealizadoDespesa'];
    totalFaltaReceita = json['totalFaltaReceita'];
    totalFaltaDespesa = json['totalFaltaDespesa'];
    totalGeralPrevisto = json['totalGeralPrevisto'];
    totalGeralRealizado = json['totalGeralRealizado'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['saldoTotalContas'] = this.saldoTotalContas;
    data['contasAReceber'] = this.contasAReceber;
    data['contasAPagar'] = this.contasAPagar;
    data['receitaBruta'] = this.receitaBruta;
    data['totalPrevistoReceita'] = this.totalPrevistoReceita;
    data['totalPrevistoDespesa'] = this.totalPrevistoDespesa;
    data['totalRealizadoDespesa'] = this.totalRealizadoDespesa;
    data['totalFaltaReceita'] = this.totalFaltaReceita;
    data['totalFaltaDespesa'] = this.totalFaltaDespesa;
    data['totalGeralPrevisto'] = this.totalGeralPrevisto;
    data['totalGeralRealizado'] = this.totalGeralRealizado;
    return data;
  }

  clear() {
    this.saldoTotalContas = 0;
    this.contasAReceber = 0;
    this.contasAPagar = 0;
    this.receitaBruta = 0;
    this.totalPrevistoReceita = 0;
    this.totalPrevistoDespesa = 0;
    this.totalRealizadoDespesa = 0;
    this.totalFaltaReceita = 0;
    this.totalFaltaDespesa = 0;
    this.totalGeralPrevisto = 0;
    this.totalGeralRealizado = 0;
  }
}
