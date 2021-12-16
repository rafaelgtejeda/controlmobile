class OrcamentoModeloSave {
  int empresaId;
  int orcamentoId;
  int numero;
  int status;
  String dtLancamento;
  String dtValidade;
  int contatoId;
  int prospectId;
  int contratoId;
  bool gerarFinanceiro;
  String observacao;
  double subtotal;
  int tipoDesconto;
  String descTipoDesconto;
  double desconto;
  double vlrDesconto;
  double vlrFrete;
  double total;
  List<int> vendedores;
  List<Vencimentos> vencimentos;
  int tipo;
  OrcamentoXOS orcamentoXOS;
  OrcamentoXContrato orcamentoXContrato;
  List<Itens> itens;

  OrcamentoModeloSave(
      {this.empresaId,
      this.orcamentoId,
      this.numero,
      this.status,
      this.dtLancamento,
      this.dtValidade,
      this.contatoId,
      this.prospectId,
      this.contratoId,
      this.gerarFinanceiro,
      this.observacao,
      this.subtotal,
      this.tipoDesconto,
      this.descTipoDesconto,
      this.desconto,
      this.vlrDesconto,
      this.vlrFrete,
      this.total,
      this.vendedores,
      this.vencimentos,
      this.tipo,
      this.orcamentoXOS,
      this.orcamentoXContrato,
      this.itens});

  OrcamentoModeloSave.fromJson(Map<String, dynamic> json) {
    empresaId = json['empresaId'];
    orcamentoId = json['orcamentoId'];
    numero = json['numero'];
    status = json['status'];
    dtLancamento = json['dtLancamento'];
    dtValidade = json['dtValidade'];
    contatoId = json['contatoId'];
    prospectId = json['prospectId'];
    contratoId = json['contratoId'];
    gerarFinanceiro = json['gerarFinanceiro'];
    observacao = json['observacao'];
    subtotal = json['subtotal'];
    tipoDesconto = json['tipoDesconto'];
    descTipoDesconto = json['descTipoDesconto'];
    desconto = json['desconto'];
    vlrDesconto = json['vlrDesconto'];
    vlrFrete = json['vlrFrete'];
    total = json['total'];
    vendedores = json['vendedores'].cast<int>();
    if (json['vencimentos'] != null) {
      vencimentos = new List<Vencimentos>();
      json['vencimentos'].forEach((v) {
        vencimentos.add(new Vencimentos.fromJson(v));
      });
    }
    tipo = json['tipo'];
    orcamentoXOS = json['orcamentoXOS'] != null
        ? new OrcamentoXOS.fromJson(json['orcamentoXOS'])
        : null;
    orcamentoXContrato = json['orcamentoXContrato'] != null
        ? new OrcamentoXContrato.fromJson(json['orcamentoXContrato'])
        : null;
    if (json['itens'] != null) {
      itens = new List<Itens>();
      json['itens'].forEach((v) {
        itens.add(new Itens.fromJson(v));
      });
    }
  }

  Map<String, dynamic> novoOrcamentoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['empresaId'] = this.empresaId;
    data['numero'] = this.numero;
    data['status'] = this.status;
    data['dtLancamento'] = this.dtLancamento;
    data['dtValidade'] = this.dtValidade;
    data['contatoId'] = this.contatoId;
    data['prospectId'] = this.prospectId;
    data['contratoId'] = this.contratoId;
    data['gerarFinanceiro'] = this.gerarFinanceiro;
    data['observacao'] = this.observacao;
    data['subtotal'] = this.subtotal;
    data['tipoDesconto'] = this.tipoDesconto;
    data['descTipoDesconto'] = this.descTipoDesconto;
    data['desconto'] = this.desconto;
    data['vlrDesconto'] = this.vlrDesconto;
    data['vlrFrete'] = this.vlrFrete;
    data['total'] = this.total;
    data['vendedores'] = this.vendedores;
    if (this.vencimentos != null) {
      data['vencimentos'] = this.vencimentos.map((v) => v.toJson()).toList();
    }
    data['tipo'] = this.tipo;
    // if (this.orcamentoXOS != null) {
    //   data['orcamentoXOS'] = this.orcamentoXOS.toJson();
    // }
    // if (this.orcamentoXContrato != null) {
    //   data['orcamentoXContrato'] = this.orcamentoXContrato.toJson();
    // }
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['empresaId'] = this.empresaId;
    data['orcamentoId'] = this.orcamentoId;
    data['numero'] = this.numero;
    data['status'] = this.status;
    data['dtLancamento'] = this.dtLancamento;
    data['dtValidade'] = this.dtValidade;
    data['contatoId'] = this.contatoId;
    data['prospectId'] = this.prospectId;
    data['contratoId'] = this.contratoId;
    data['gerarFinanceiro'] = this.gerarFinanceiro;
    data['observacao'] = this.observacao;
    data['subtotal'] = this.subtotal;
    data['tipoDesconto'] = this.tipoDesconto;
    data['descTipoDesconto'] = this.descTipoDesconto;
    data['desconto'] = this.desconto;
    data['vlrDesconto'] = this.vlrDesconto;
    data['vlrFrete'] = this.vlrFrete;
    data['total'] = this.total;
    data['vendedores'] = this.vendedores;
    if (this.vencimentos != null) {
      data['vencimentos'] = this.vencimentos.map((v) => v.toJson()).toList();
    }
    data['tipo'] = this.tipo;
    // if (this.orcamentoXOS != null) {
    //   data['orcamentoXOS'] = this.orcamentoXOS.toJson();
    // }
    // if (this.orcamentoXContrato != null) {
    //   data['orcamentoXContrato'] = this.orcamentoXContrato.toJson();
    // }
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Vencimentos {
  int parcela;
  int formaPagamentoId;
  int condicaoId;
  String vencimento;
  double valor;

  Vencimentos(
      {this.parcela,
      this.formaPagamentoId,
      this.condicaoId,
      this.vencimento,
      this.valor});

  Vencimentos.fromJson(Map<String, dynamic> json) {
    parcela = json['parcela'];
    formaPagamentoId = json['formaPagamentoId'];
    condicaoId = json['condicaoId'];
    vencimento = json['vencimento'];
    valor = json['valor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['parcela'] = this.parcela;
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['condicaoId'] = this.condicaoId;
    data['vencimento'] = this.vencimento;
    data['valor'] = this.valor;
    return data;
  }
}

class OrcamentoXOS {
  int localOS;
  int tipoOS;
  int prioridadeOS;
  String previsaoOS;
  int produtoOS;
  String descOS;
  int numeroOS;
  bool numeracaoAutomatica;

  OrcamentoXOS(
      {this.localOS,
      this.tipoOS,
      this.prioridadeOS,
      this.previsaoOS,
      this.produtoOS,
      this.descOS,
      this.numeroOS,
      this.numeracaoAutomatica});

  OrcamentoXOS.fromJson(Map<String, dynamic> json) {
    localOS = json['localOS'];
    tipoOS = json['tipoOS'];
    prioridadeOS = json['prioridadeOS'];
    previsaoOS = json['previsaoOS'];
    produtoOS = json['produtoOS'];
    descOS = json['descOS'];
    numeroOS = json['numeroOS'];
    numeracaoAutomatica = json['numeracaoAutomatica'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['localOS'] = this.localOS;
    data['tipoOS'] = this.tipoOS;
    data['prioridadeOS'] = this.prioridadeOS;
    data['previsaoOS'] = this.previsaoOS;
    data['produtoOS'] = this.produtoOS;
    data['descOS'] = this.descOS;
    data['numeroOS'] = this.numeroOS;
    data['numeracaoAutomatica'] = this.numeracaoAutomatica;
    return data;
  }
}

class OrcamentoXContrato {
  int tipoManutencaoCont;
  String dtInicioCont;
  String dtTerminoCont;
  int formaPagamentoCont;
  int tipoDocumentoCont;
  int diaVencCont;
  int contaCorrenteCont;
  int convenioCont;
  int statusAssinaturaCont;
  String numero;

  OrcamentoXContrato(
      {this.tipoManutencaoCont,
      this.dtInicioCont,
      this.dtTerminoCont,
      this.formaPagamentoCont,
      this.tipoDocumentoCont,
      this.diaVencCont,
      this.contaCorrenteCont,
      this.convenioCont,
      this.statusAssinaturaCont,
      this.numero});

  OrcamentoXContrato.fromJson(Map<String, dynamic> json) {
    tipoManutencaoCont = json['tipoManutencaoCont'];
    dtInicioCont = json['dtInicioCont'];
    dtTerminoCont = json['dtTerminoCont'];
    formaPagamentoCont = json['formaPagamentoCont'];
    tipoDocumentoCont = json['tipoDocumentoCont'];
    diaVencCont = json['diaVencCont'];
    contaCorrenteCont = json['contaCorrenteCont'];
    convenioCont = json['convenioCont'];
    statusAssinaturaCont = json['statusAssinaturaCont'];
    numero = json['numero'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tipoManutencaoCont'] = this.tipoManutencaoCont;
    data['dtInicioCont'] = this.dtInicioCont;
    data['dtTerminoCont'] = this.dtTerminoCont;
    data['formaPagamentoCont'] = this.formaPagamentoCont;
    data['tipoDocumentoCont'] = this.tipoDocumentoCont;
    data['diaVencCont'] = this.diaVencCont;
    data['contaCorrenteCont'] = this.contaCorrenteCont;
    data['convenioCont'] = this.convenioCont;
    data['statusAssinaturaCont'] = this.statusAssinaturaCont;
    data['numero'] = this.numero;
    return data;
  }
}

class Itens {
  int produtoId;
  double quantidade;
  double prUnitario;
  double percDesc;
  double vlrDesc;
  double prUnitComDesc;
  double vlrTotal;
  double vlrTotComDesc;
  int tipo;
  bool comodato;
  bool locacaoBens;

  Itens(
      {this.produtoId,
      this.quantidade,
      this.prUnitario,
      this.percDesc,
      this.vlrDesc,
      this.prUnitComDesc,
      this.vlrTotal,
      this.vlrTotComDesc,
      this.tipo,
      this.comodato,
      this.locacaoBens});

  Itens.fromJson(Map<String, dynamic> json) {
    produtoId = json['produtoId'];
    quantidade = json['quantidade'];
    prUnitario = json['prUnitario'];
    percDesc = json['percDesc'];
    vlrDesc = json['vlrDesc'];
    prUnitComDesc = json['prUnitComDesc'];
    vlrTotal = json['vlrTotal'];
    vlrTotComDesc = json['vlrTotComDesc'];
    tipo = json['tipo'];
    comodato = json['comodato'];
    locacaoBens = json['locacaoBens'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['produtoId'] = this.produtoId;
    data['quantidade'] = this.quantidade;
    data['prUnitario'] = this.prUnitario;
    data['percDesc'] = this.percDesc;
    data['vlrDesc'] = this.vlrDesc;
    data['prUnitComDesc'] = this.prUnitComDesc;
    data['vlrTotal'] = this.vlrTotal;
    data['vlrTotComDesc'] = this.vlrTotComDesc;
    data['tipo'] = this.tipo;
    data['comodato'] = this.comodato;
    data['locacaoBens'] = this.locacaoBens;
    return data;
  }
}
