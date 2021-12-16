class AtualizaStatusOSModelo {
  int osId;
  int osxTecId;
  int tecnicoId;
  int status;

  AtualizaStatusOSModelo(
      {this.osId, this.osxTecId, this.tecnicoId, this.status});

  AtualizaStatusOSModelo.fromJson(Map<String, dynamic> json) {
    osId = json['osId'];
    osxTecId = json['osxTecId'];
    tecnicoId = json['tecnicoId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['osId'] = this.osId;
    data['osxTecId'] = this.osxTecId;
    data['tecnicoId'] = this.tecnicoId;
    data['status'] = this.status;
    return data;
  }
}
