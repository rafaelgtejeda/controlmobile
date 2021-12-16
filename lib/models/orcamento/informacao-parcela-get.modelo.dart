class InformacaoParcelaRetorno {
  String vencimento;
  double valor;
  String descricaoFormaPagamento;
  int formaPagamentoId;
  int condicaoPagamentoId;

  InformacaoParcelaRetorno(
      {this.vencimento,
      this.valor,
      this.descricaoFormaPagamento,
      this.formaPagamentoId,
      this.condicaoPagamentoId});

  InformacaoParcelaRetorno.fromJson(Map<String, dynamic> json) {
    vencimento = json['vencimento'];
    valor = json['valor'];
    descricaoFormaPagamento = json['descricaoFormaPagamento'];
    formaPagamentoId = json['formaPagamentoId'];
    condicaoPagamentoId = json['condicaoPagamentoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vencimento'] = this.vencimento;
    data['valor'] = this.valor;
    data['descricaoFormaPagamento'] = this.descricaoFormaPagamento;
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['condicaoPagamentoId'] = this.condicaoPagamentoId;
    return data;
  }
}
