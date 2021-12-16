class CidadeEstrangeiraLookUp {
  int id;
  String descricao;
  String cidade;
  String estado;
  String pais;

  CidadeEstrangeiraLookUp(
      {this.id, this.descricao, this.cidade, this.estado, this.pais});

  CidadeEstrangeiraLookUp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    cidade = json['cidade'];
    estado = json['estado'];
    pais = json['pais'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['cidade'] = this.cidade;
    data['estado'] = this.estado;
    data['pais'] = this.pais;
    return data;
  }
}
