class InformacaoParcelaSend {
  int formaPagamentoId;
  int condicaoPagamentoId;
  double valor;
  int parceiroId;
  int empresaId;
  int registroId;

  InformacaoParcelaSend(
      {this.formaPagamentoId,
      this.condicaoPagamentoId,
      this.valor,
      this.parceiroId,
      this.empresaId,
      this.registroId});

  InformacaoParcelaSend.fromJson(Map<String, dynamic> json) {
    formaPagamentoId = json['formaPagamentoId'];
    condicaoPagamentoId = json['condicaoPagamentoId'];
    valor = json['valor'];
    parceiroId = json['parceiroId'];
    empresaId = json['empresaId'];
    registroId = json['registroId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['condicaoPagamentoId'] = this.condicaoPagamentoId;
    data['valor'] = this.valor;
    data['parceiroId'] = this.parceiroId;
    data['empresaId'] = this.empresaId;
    data['registroId'] = this.registroId;
    return data;
  }
}
