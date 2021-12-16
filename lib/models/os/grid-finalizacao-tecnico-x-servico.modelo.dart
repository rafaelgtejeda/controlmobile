class GridFinalizacaoTecnicoXServicoModelo {
  int id;
  int osXMatId;
  int osxTecId;
  int servicoId;
  String codigo;
  String descricao;
  int status;
  int checkListTotal;
  int checkListPendente;
  String dataStatus;
  double quantidade;
  int tecnicoId;

  GridFinalizacaoTecnicoXServicoModelo(
      {this.id,
      this.osXMatId,
      this.osxTecId,
      this.servicoId,
      this.codigo,
      this.descricao,
      this.status,
      this.checkListTotal,
      this.checkListPendente,
      this.dataStatus,
      this.quantidade,
      this.tecnicoId});

  GridFinalizacaoTecnicoXServicoModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    osXMatId = json['osXMatId'];
    osxTecId = json['osxTecId'];
    servicoId = json['servicoId'];
    codigo = json['codigo'];
    descricao = json['descricao'];
    status = json['status'];
    checkListTotal = json['checkListTotal'];
    checkListPendente = json['checkListPendente'];
    dataStatus = json['dataStatus'];
    quantidade = json['quantidade'];
    tecnicoId = json['tecnicoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['osXMatId'] = this.osXMatId;
    data['osxTecId'] = this.osxTecId;
    data['servicoId'] = this.servicoId;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['status'] = this.status;
    data['checkListTotal'] = this.checkListTotal;
    data['checkListPendente'] = this.checkListPendente;
    data['dataStatus'] = this.dataStatus;
    data['quantidade'] = this.quantidade;
    data['tecnicoId'] = this.tecnicoId;
    return data;
  }
}



class AtualizarStatusServicoXTecnicoModelo {
  int status;
  Data data;

  AtualizarStatusServicoXTecnicoModelo({this.status, this.data});

  AtualizarStatusServicoXTecnicoModelo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  int id;
  int osXMatId;
  int osxTecId;
  int servicoId;
  String codigo;
  String descricao;
  int status;
  int checkListTotal;
  int checkListPendente;
  String dataStatus;
  double quantidade;
  int tecnicoId;

  Data(
      {this.id,
      this.osXMatId,
      this.osxTecId,
      this.servicoId,
      this.codigo,
      this.descricao,
      this.status,
      this.checkListTotal,
      this.checkListPendente,
      this.dataStatus,
      this.quantidade,
      this.tecnicoId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    osXMatId = json['osXMatId'];
    osxTecId = json['osxTecId'];
    servicoId = json['servicoId'];
    codigo = json['codigo'];
    descricao = json['descricao'];
    status = json['status'];
    checkListTotal = json['checkListTotal'];
    checkListPendente = json['checkListPendente'];
    dataStatus = json['dataStatus'];
    quantidade = json['quantidade'];
    tecnicoId = json['tecnicoId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['osXMatId'] = this.osXMatId;
    data['osxTecId'] = this.osxTecId;
    data['servicoId'] = this.servicoId;
    data['codigo'] = this.codigo;
    data['descricao'] = this.descricao;
    data['status'] = this.status;
    data['checkListTotal'] = this.checkListTotal;
    data['checkListPendente'] = this.checkListPendente;
    data['dataStatus'] = this.dataStatus;
    data['quantidade'] = this.quantidade;
    data['tecnicoId'] = this.tecnicoId;
    return data;
  }
}
