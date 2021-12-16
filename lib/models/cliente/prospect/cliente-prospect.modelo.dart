class ClienteProspectModelo {
  String nome;
  String cnpJCPF;
  int pessoa;
  int empresaId;
  String email;
  Telefone telefone;
  Telefone celular;

  ClienteProspectModelo(
      {this.nome,
      this.cnpJCPF,
      this.pessoa,
      this.empresaId,
      this.email,
      this.telefone,
      this.celular});

  ClienteProspectModelo.fromJson(Map<String, dynamic> json) {
    nome = json['nome'];
    cnpJCPF = json['cnpJ_CPF'];
    pessoa = json['pessoa'];
    empresaId = json['empresaId'];
    email = json['email'];
    telefone = json['telefone'] != null
        ? new Telefone.fromJson(json['telefone'])
        : null;
    celular =
        json['celular'] != null ? new Telefone.fromJson(json['celular']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nome'] = this.nome;
    data['cnpJ_CPF'] = this.cnpJCPF;
    data['pessoa'] = this.pessoa;
    data['empresaId'] = this.empresaId;
    data['email'] = this.email;
    if (this.telefone != null) {
      data['telefone'] = this.telefone.toJson();
    }
    if (this.celular != null) {
      data['celular'] = this.celular.toJson();
    }
    return data;
  }
}

class Telefone {
  String ddd;
  String ddi;
  String phone;

  Telefone({this.ddd, this.ddi, this.phone});

  Telefone.fromJson(Map<String, dynamic> json) {
    ddd = json['ddd'];
    ddi = json['ddi'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ddd'] = this.ddd;
    data['ddi'] = this.ddi;
    data['phone'] = this.phone;
    return data;
  }
}
