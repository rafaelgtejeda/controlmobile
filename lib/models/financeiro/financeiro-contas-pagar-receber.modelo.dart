class FinanceiroContasReceberPagarModelo {
  ContasAReceber contasAReceber;
  ContasAPagar contasAPagar;

  FinanceiroContasReceberPagarModelo({this.contasAReceber, this.contasAPagar});

  FinanceiroContasReceberPagarModelo.fromJson(Map<String, dynamic> json) {
    contasAReceber = json['contasAReceber'] != null
        ? new ContasAReceber.fromJson(json['contasAReceber'])
        : null;
    contasAPagar = json['contasAPagar'] != null
        ? new ContasAPagar.fromJson(json['contasAPagar'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contasAReceber != null) {
      data['contasAReceber'] = this.contasAReceber.toJson();
    }
    if (this.contasAPagar != null) {
      data['contasAPagar'] = this.contasAPagar.toJson();
    }
    return data;
  }
}

class ContasAReceber {
  List<AReceber> aReceber;
  List<Recebido> recebido;

  ContasAReceber({this.aReceber, this.recebido});

  ContasAReceber.fromJson(Map<String, dynamic> json) {
    if (json['aReceber'] != null) {
      aReceber = new List<AReceber>();
      json['aReceber'].forEach((v) {
        aReceber.add(new AReceber.fromJson(v));
      });
    }
    if (json['recebido'] != null) {
      recebido = new List<Recebido>();
      json['recebido'].forEach((v) {
        recebido.add(new Recebido.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aReceber != null) {
      data['aVencer'] = this.aReceber.map((v) => v.toJson()).toList();
    }
    if (this.recebido != null) {
      data['recebido'] = this.recebido.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AReceber {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  AReceber(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  AReceber.fromJson(Map<String, dynamic> json) {
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

class Recebido {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  Recebido(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  Recebido.fromJson(Map<String, dynamic> json) {
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

class ContasAPagar {
  List<APagar> aPagar;
  List<Pago> pago;

  ContasAPagar({this.aPagar, this.pago});

  ContasAPagar.fromJson(Map<String, dynamic> json) {
    if (json['aPagar'] != null) {
      aPagar = new List<APagar>();
      json['aPagar'].forEach((v) {
        aPagar.add(new APagar.fromJson(v));
      });
    }
    if (json['pago'] != null) {
      pago = new List<Pago>();
      json['pago'].forEach((v) {
        pago.add(new Pago.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aPagar != null) {
      data['aPagar'] = this.aPagar.map((v) => v.toJson()).toList();
    }
    if (this.pago != null) {
      data['pago'] = this.pago.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class APagar {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  APagar(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  APagar.fromJson(Map<String, dynamic> json) {
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

class Pago {
  int id;
  String descricao;
  double valorFinal;
  String vencimento;
  bool baixaTotal;
  String parceiroNome;
  int tipoCategoria;

  Pago(
      {this.id,
      this.descricao,
      this.valorFinal,
      this.vencimento,
      this.baixaTotal,
      this.parceiroNome,
      this.tipoCategoria});

  Pago.fromJson(Map<String, dynamic> json) {
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

