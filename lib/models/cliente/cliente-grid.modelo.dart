class ClienteGrid {
  List<Lista> lista;
  Sumario sumario;

  ClienteGrid({this.lista, this.sumario});

  ClienteGrid.fromJson(Map<String, dynamic> json) {
    if (json['lista'] != null) {
      lista = new List<Lista>();
      json['lista'].forEach((v) {
        lista.add(new Lista.fromJson(v));
      });
    }
    sumario =
        json['sumario'] != null ? new Sumario.fromJson(json['sumario']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lista != null) {
      data['lista'] = this.lista.map((v) => v.toJson()).toList();
    }
    if (this.sumario != null) {
      data['sumario'] = this.sumario.toJson();
    }
    return data;
  }
}

class Lista {
  int id;
  String nome;
  String nomeFantasia;
  String codigoCliente;
  String cnpJCPF;
  bool isSelected = false;

  Lista(
      {this.id,
      this.nome,
      this.nomeFantasia,
      this.codigoCliente,
      this.cnpJCPF});

  Lista.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    nomeFantasia = json['nomeFantasia'];
    codigoCliente = json['codigoCliente'];
    cnpJCPF = json['cnpJ_CPF'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    data['codigoCliente'] = this.codigoCliente;
    data['cnpJ_CPF'] = this.cnpJCPF;
    return data;
  }
}

class Sumario {
  int contador;

  Sumario({this.contador});

  Sumario.fromJson(Map<String, dynamic> json) {
    contador = json['contador'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contador'] = this.contador;
    return data;
  }
}
