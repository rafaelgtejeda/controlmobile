class VendedoresLookUp {
  int id;
  String nome;
  String email;

  VendedoresLookUp({this.id, this.nome, this.email});

  VendedoresLookUp.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['email'] = this.email;
    return data;
  }
}
