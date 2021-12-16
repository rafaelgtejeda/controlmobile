class EmailSMS {
  int empresaId;
  int area;
  bool customizado;
  int manutencaoId;

  EmailSMS({this.empresaId, this.area, this.customizado, this.manutencaoId});

  EmailSMS.fromJson(Map<String, dynamic> json) {
    empresaId = json['empresaId'];
    area = json['area'];
    customizado = json['customizado'];
    manutencaoId = json['manutencaoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['empresaId'] = this.empresaId;
    data['area'] = this.area;
    data['customizado'] = this.customizado;
    data['manutencaoId'] = this.manutencaoId;
    return data;
  }
}
