class OrcamentoModeloGet {
  int id;
  double desconto;
  String dataLancamento;
  String dataValidade;
  String observacao;
  int contatoId;
  String contato;
  double subTotal;
  String tipoDesconto;
  double total;
  double vlrDesconto;
  double vlrFrete;
  String status;
  int tipo;
  List<Itens> itens;
  List<Vencimentos> vencimentos;
  List<Vendedores> vendedores;

  OrcamentoModeloGet(
      {this.id,
      this.desconto,
      this.dataLancamento,
      this.dataValidade,
      this.observacao,
      this.contatoId,
      this.contato,
      this.subTotal,
      this.tipoDesconto,
      this.total,
      this.vlrDesconto,
      this.vlrFrete,
      this.status,
      this.tipo,
      this.itens,
      this.vencimentos,
      this.vendedores});

  OrcamentoModeloGet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    desconto = json['desconto'];
    dataLancamento = json['dataLancamento'];
    dataValidade = json['dataValidade'];
    observacao = json['observacao'];
    contatoId = json['contatoId'];
    contato = json['contato'];
    subTotal = json['subTotal'];
    tipoDesconto = json['tipoDesconto'];
    total = json['total'];
    vlrDesconto = json['vlrDesconto'];
    vlrFrete = json['vlrFrete'];
    status = json['status'];
    tipo = json['tipo'];
    if (json['itens'] != null) {
      itens = new List<Itens>();
      json['itens'].forEach((v) {
        itens.add(new Itens.fromJson(v));
      });
    }
    if (json['vencimentos'] != null) {
      vencimentos = new List<Vencimentos>();
      json['vencimentos'].forEach((v) {
        vencimentos.add(new Vencimentos.fromJson(v));
      });
    }
    if (json['vendedores'] != null) {
      vendedores = new List<Vendedores>();
      json['vendedores'].forEach((v) {
        vendedores.add(new Vendedores.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['desconto'] = this.desconto;
    data['dataLancamento'] = this.dataLancamento;
    data['dataValidade'] = this.dataValidade;
    data['observacao'] = this.observacao;
    data['contatoId'] = this.contatoId;
    data['contato'] = this.contato;
    data['subTotal'] = this.subTotal;
    data['tipoDesconto'] = this.tipoDesconto;
    data['total'] = this.total;
    data['vlrDesconto'] = this.vlrDesconto;
    data['vlrFrete'] = this.vlrFrete;
    data['status'] = this.status;
    data['tipo'] = this.tipo;
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    if (this.vencimentos != null) {
      data['vencimentos'] = this.vencimentos.map((v) => v.toJson()).toList();
    }
    if (this.vendedores != null) {
      data['vendedores'] = this.vendedores.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Itens {
  int id;
  int produtoId;
  String produto;
  String unidadeMedida;
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
  int indiceGeral;
  bool isSelected = false;

  Itens(
      {this.id,
      this.produtoId,
      this.produto,
      this.unidadeMedida,
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
    id = json['id'];
    produtoId = json['produtoId'];
    produto = json['produto'];
    unidadeMedida = json['unidadeMedida'];
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
    data['id'] = this.id;
    data['produtoId'] = this.produtoId;
    data['produto'] = this.produto;
    data['unidadeMedida'] = this.unidadeMedida;
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

class Vencimentos {
  int formaPagamentoId;
  int condicaoPagamentoId;
  String formaPagamento;
  int parcela;
  double valor;
  String vencimento;
  bool isSelected = false;

  Vencimentos({this.formaPagamentoId, this.condicaoPagamentoId,this.formaPagamento, this.parcela, this.valor, this.vencimento});

  Vencimentos.fromJson(Map<String, dynamic> json) {
    formaPagamentoId = json['formaPagamentoId'];
    condicaoPagamentoId = json['condicaoPagamentoId'];
    formaPagamento = json['formaPagamento'];
    parcela = json['parcela'];
    valor = json['valor'];
    vencimento = json['vencimento'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['formaPagamentoId'] = this.formaPagamentoId;
    data['condicaoPagamentoId'] = this.condicaoPagamentoId;
    data['formaPagamento'] = this.formaPagamento;
    data['parcela'] = this.parcela;
    data['valor'] = this.valor;
    data['vencimento'] = this.vencimento;
    return data;
  }
}

class Vendedores {
  int id;
  String nome;

  Vendedores({this.id, this.nome});

  Vendedores.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    return data;
  }
}
