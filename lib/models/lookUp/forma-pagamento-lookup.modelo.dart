class FormaPagamentoLookup {
  int id;
  int codigo;
  String descricao;
  List<Condicoes> condicoes;

  FormaPagamentoLookup({this.id, this.codigo, this.descricao, this.condicoes});

  FormaPagamentoLookup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    codigo = json['codigo'];
    descricao = json['descricao'];
    if (json['condicoes'] != null) {
      condicoes = new List<Condicoes>();
      json['condicoes'].forEach((v) {
        condicoes.add(new Condicoes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    if (this.condicoes != null) {
      data['condicoes'] = this.condicoes.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Condicoes {
  int id;
  String descricao;

  Condicoes({this.id, this.descricao});

  Condicoes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    return data;
  }
}
