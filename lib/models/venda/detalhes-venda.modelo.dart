class DetalhesVendaModelo {
  int id;
  double desconto;
  String dataLancamento;
  String dataConcluido;
  String observacao;
  String cliente;
  double subtotal;
  double total;
  double vlrDesconto;
  String tipoDesconto;
  List<Itens> itens;
  List<Vencimentos> vencimentos;
  List<Vendedores> vendedores;

  DetalhesVendaModelo(
      {this.id,
      this.desconto,
      this.dataLancamento,
      this.dataConcluido,
      this.observacao,
      this.cliente,
      this.subtotal,
      this.total,
      this.vlrDesconto,
      this.tipoDesconto,
      this.itens,
      this.vencimentos,
      this.vendedores});

  DetalhesVendaModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    desconto = json['desconto'];
    dataLancamento = json['dataLancamento'];
    dataConcluido = json['dataConcluido'];
    observacao = json['observacao'];
    cliente = json['cliente'];
    subtotal = json['subtotal'];
    total = json['total'];
    vlrDesconto = json['vlrDesconto'];
    tipoDesconto = json['tipoDesconto'];
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
    data['dataConcluido'] = this.dataConcluido;
    data['observacao'] = this.observacao;
    data['cliente'] = this.cliente;
    data['subtotal'] = this.subtotal;
    data['total'] = this.total;
    data['vlrDesconto'] = this.vlrDesconto;
    data['tipoDesconto'] = this.tipoDesconto;
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
  String produto;
  double quantidade;
  double prUnitario;
  double percDesconto;
  double vlrDesc;
  double prUnitComDesc;
  double vlrTotal;
  double vlrTotComDesc;

  Itens(
      {this.id,
      this.produto,
      this.quantidade,
      this.prUnitario,
      this.percDesconto,
      this.vlrDesc,
      this.prUnitComDesc,
      this.vlrTotal,
      this.vlrTotComDesc});

  Itens.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    produto = json['produto'];
    quantidade = json['quantidade'];
    prUnitario = json['prUnitario'];
    percDesconto = json['percDesconto'];
    vlrDesc = json['vlrDesc'];
    prUnitComDesc = json['prUnitComDesc'];
    vlrTotal = json['vlrTotal'];
    vlrTotComDesc = json['vlrTotComDesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['produto'] = this.produto;
    data['quantidade'] = this.quantidade;
    data['prUnitario'] = this.prUnitario;
    data['percDesconto'] = this.percDesconto;
    data['vlrDesc'] = this.vlrDesc;
    data['prUnitComDesc'] = this.prUnitComDesc;
    data['vlrTotal'] = this.vlrTotal;
    data['vlrTotComDesc'] = this.vlrTotComDesc;
    return data;
  }
}

class Vencimentos {
  String formaPagamento;
  int parcela;
  double valor;
  String vencimento;

  Vencimentos({this.formaPagamento, this.parcela, this.valor, this.vencimento});

  Vencimentos.fromJson(Map<String, dynamic> json) {
    formaPagamento = json['formaPagamento'];
    parcela = json['parcela'];
    valor = json['valor'];
    vencimento = json['vencimento'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
