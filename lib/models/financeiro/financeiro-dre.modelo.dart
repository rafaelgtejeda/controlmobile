class FinanceiroDREModelo {
  double receitaBruta;
  double impostos;
  double despesasVariaveis;
  double despesasFixas;
  double pessoas;
  double devolucoes;
  double lucroBruto;
  double lucroOperacional;
  double lucroLiquido;

  FinanceiroDREModelo(
      {this.receitaBruta,
      this.impostos,
      this.despesasVariaveis,
      this.despesasFixas,
      this.pessoas,
      this.devolucoes,
      this.lucroBruto,
      this.lucroOperacional,
      this.lucroLiquido});

  FinanceiroDREModelo.fromJson(Map<String, dynamic> json) {
    receitaBruta = json['receitaBruta'];
    impostos = json['impostos'];
    despesasVariaveis = json['despesasVariaveis'];
    despesasFixas = json['despesasFixas'];
    pessoas = json['pessoas'];
    devolucoes = json['devolucoes'];
    lucroBruto = json['lucroBruto'];
    lucroOperacional = json['lucroOperacional'];
    lucroLiquido = json['lucroLiquido'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['receitaBruta'] = this.receitaBruta;
    data['impostos'] = this.impostos;
    data['despesasVariaveis'] = this.despesasVariaveis;
    data['despesasFixas'] = this.despesasFixas;
    data['pessoas'] = this.pessoas;
    data['devolucoes'] = this.devolucoes;
    data['lucroBruto'] = this.lucroBruto;
    data['lucroOperacional'] = this.lucroOperacional;
    data['lucroLiquido'] = this.lucroLiquido;
    return data;
  }
}
