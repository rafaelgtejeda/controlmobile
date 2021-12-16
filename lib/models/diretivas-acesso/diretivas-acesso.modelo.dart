import 'dart:convert';

class DiretivasAcessoModelo {
  int id;
  String nome;
  String nomeFantasia;
  List<int> diretivas;

  DiretivasAcessoModelo(
      {this.id, this.nome, this.nomeFantasia, this.diretivas});

  DiretivasAcessoModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    nomeFantasia = json['nomeFantasia'];
    diretivas = json['diretivas'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    data['diretivas'] = this.diretivas;
    return data;
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    data['diretivas'] = json.encode(this.diretivas);
    return data;
  }
}
