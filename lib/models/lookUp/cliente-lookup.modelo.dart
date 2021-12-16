class ClienteLookup {
  int id;
  int empresaId;
  String nome;
  String nomeFantasia;

  ClienteLookup({this.id, this.empresaId, this.nome, this.nomeFantasia});

  ClienteLookup.fromJson(Map<String, dynamic> json) {
    if(json['empresaId'] != null){
      empresaId = json['empresaId'];
    }
    id = json['id'];
    nome = json['nome'];
    nomeFantasia = json['nomeFantasia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['empresaId'] = this.empresaId;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    return data;
  }
}
