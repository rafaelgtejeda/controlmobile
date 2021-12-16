class FinalizarTecnicoOSModelo {
  int osId;
  int osxTecId;
  int tecnicoId;
  int status;
  double latitude;
  double longitude;
  String nome;
  String cpf;
  String descricao;
  List<Arquivos> arquivos;

  FinalizarTecnicoOSModelo(
      {this.osId,
      this.osxTecId,
      this.tecnicoId,
      this.status,
      this.latitude,
      this.longitude,
      this.nome,
      this.cpf,
      this.descricao,
      this.arquivos});

  FinalizarTecnicoOSModelo.fromJson(Map<String, dynamic> json) {
    osId = json['osId'];
    osxTecId = json['osxTecId'];
    tecnicoId = json['tecnicoId'];
    status = json['status'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    nome = json['nome'];
    cpf = json['cpf'];
    descricao = json['descricao'];
    if (json['arquivos'] != null) {
      arquivos = new List<Arquivos>();
      json['arquivos'].forEach((v) {
        arquivos.add(new Arquivos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['osId'] = this.osId;
    data['osxTecId'] = this.osxTecId;
    data['tecnicoId'] = this.tecnicoId;
    data['status'] = this.status;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['nome'] = this.nome;
    data['cpf'] = this.cpf;
    data['descricao'] = this.descricao;
    if (this.arquivos != null) {
      data['arquivos'] = this.arquivos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Arquivos {
  String arquivo;
  String fileName;
  String contentType;
  double size;
  int tipo;

  Arquivos(
      {this.arquivo, this.fileName, this.contentType, this.size, this.tipo});

  Arquivos.fromJson(Map<String, dynamic> json) {
    arquivo = json['arquivo'];
    fileName = json['fileName'];
    contentType = json['contentType'];
    size = json['size'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['arquivo'] = this.arquivo;
    data['fileName'] = this.fileName;
    data['contentType'] = this.contentType;
    data['size'] = this.size;
    data['tipo'] = this.tipo;
    return data;
  }
}
