class LancamentosPrevistosModelo {
  List<Lancamento> lancamentoAVencer;
  List<Lancamento> lancamentoVencidos;

  LancamentosPrevistosModelo({this.lancamentoAVencer, this.lancamentoVencidos});

  LancamentosPrevistosModelo.fromJson(Map<String, dynamic> json) {
    if (json['lancamentoAVencer'] != null) {
      lancamentoAVencer = new List<Lancamento>();
      json['lancamentoAVencer'].forEach((v) {
        lancamentoAVencer.add(new Lancamento.fromJson(v));
      });
    }
    if (json['lancamentoVencidos'] != null) {
      lancamentoVencidos = new List<Lancamento>();
      json['lancamentoVencidos'].forEach((v) {
        lancamentoVencidos.add(new Lancamento.fromJson(v));
      });
    }
  }

  LancamentosPrevistosModelo.fromJsonReceita(Map<String, dynamic> json) {
    if (json['lancamentoAReceber'] != null) {
      lancamentoAVencer = new List<Lancamento>();
      json['lancamentoAReceber'].forEach((v) {
        lancamentoAVencer.add(new Lancamento.fromJson(v));
      });
    }
    if (json['lancamentoRecebido'] != null) {
      lancamentoVencidos = new List<Lancamento>();
      json['lancamentoRecebido'].forEach((v) {
        lancamentoVencidos.add(new Lancamento.fromJson(v));
      });
    }
  }

  LancamentosPrevistosModelo.fromJsonDespesa(Map<String, dynamic> json) {
    if (json['lancamentoAPagar'] != null) {
      lancamentoAVencer = new List<Lancamento>();
      json['lancamentoAPagar'].forEach((v) {
        lancamentoAVencer.add(new Lancamento.fromJson(v));
      });
    }
    if (json['lancamentoPago'] != null) {
      lancamentoVencidos = new List<Lancamento>();
      json['lancamentoPago'].forEach((v) {
        lancamentoVencidos.add(new Lancamento.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lancamentoAVencer != null) {
      data['lancamentoAVencer'] =
          this.lancamentoAVencer.map((v) => v.toJson()).toList();
    }
    if (this.lancamentoVencidos != null) {
      data['lancamentoVencidos'] =
          this.lancamentoVencidos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lancamento {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  Lancamento(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  Lancamento.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    valorFinal = json['valorFinal'];
    vencimento = json['vencimento'];
    baixaTotal = json['baixaTotal'];
    parceiroNome = json['parceiroNome'];
    tipoCategoria = json['tipoCategoria'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['valorFinal'] = this.valorFinal;
    data['vencimento'] = this.vencimento;
    data['baixaTotal'] = this.baixaTotal;
    data['parceiroNome'] = this.parceiroNome;
    data['tipoCategoria'] = this.tipoCategoria;
    return data;
  }
}



class LancamentoAVencer {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  LancamentoAVencer(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  LancamentoAVencer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    valorFinal = json['valorFinal'];
    vencimento = json['vencimento'];
    baixaTotal = json['baixaTotal'];
    parceiroNome = json['parceiroNome'];
    tipoCategoria = json['tipoCategoria'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['valorFinal'] = this.valorFinal;
    data['vencimento'] = this.vencimento;
    data['baixaTotal'] = this.baixaTotal;
    data['parceiroNome'] = this.parceiroNome;
    data['tipoCategoria'] = this.tipoCategoria;
    return data;
  }
}

class LancamentoVencidos {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  LancamentoVencidos(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  LancamentoVencidos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    valorFinal = json['valorFinal'];
    vencimento = json['vencimento'];
    baixaTotal = json['baixaTotal'];
    parceiroNome = json['parceiroNome'];
    tipoCategoria = json['tipoCategoria'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['valorFinal'] = this.valorFinal;
    data['vencimento'] = this.vencimento;
    data['baixaTotal'] = this.baixaTotal;
    data['parceiroNome'] = this.parceiroNome;
    data['tipoCategoria'] = this.tipoCategoria;
    return data;
  }
}
