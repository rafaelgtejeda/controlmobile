class AssinarOrcamentoModelo {
  String arquivo;
  String fileName;
  String contentType;
  double size;
  int orcamentoId;
  int empresaId;

  AssinarOrcamentoModelo(
      {this.arquivo,
      this.fileName,
      this.contentType,
      this.size,
      this.orcamentoId,
      this.empresaId});

  AssinarOrcamentoModelo.fromJson(Map<String, dynamic> json) {
    arquivo = json['arquivo'];
    fileName = json['fileName'];
    contentType = json['contentType'];
    size = json['size'];
    orcamentoId = json['orcamentoId'];
    empresaId = json['empresaId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['arquivo'] = this.arquivo;
    data['fileName'] = this.fileName;
    data['contentType'] = this.contentType;
    data['size'] = this.size;
    data['orcamentoId'] = this.orcamentoId;
    data['empresaId'] = this.empresaId;
    return data;
  }
}
