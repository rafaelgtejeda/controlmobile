class GridFinalizacaoServicoXCheckListModelo {
  int id;
  String descricao;
  int obrigatorio;
  int status;
  int osxTecXServId;
  int servCheckListId;

  GridFinalizacaoServicoXCheckListModelo(
      {this.id,
      this.descricao,
      this.obrigatorio,
      this.status,
      this.osxTecXServId,
      this.servCheckListId});

  GridFinalizacaoServicoXCheckListModelo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    obrigatorio = json['obrigatorio'];
    status = json['status'];
    osxTecXServId = json['osxTecXServId'];
    servCheckListId = json['servCheckListId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['obrigatorio'] = this.obrigatorio;
    data['status'] = this.status;
    data['osxTecXServId'] = this.osxTecXServId;
    data['servCheckListId'] = this.servCheckListId;
    return data;
  }
}



class AtualizarStatusCheckXServicoModelo {
  int status;
  Data data;

  AtualizarStatusCheckXServicoModelo({this.status, this.data});

  AtualizarStatusCheckXServicoModelo.fromJson(Map<String, dynamic> json) {
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
  String descricao;
  int obrigatorio;
  int status;
  int osxTecXServId;
  int servCheckListId;

  Data(
      {this.id,
      this.descricao,
      this.obrigatorio,
      this.status,
      this.osxTecXServId,
      this.servCheckListId});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
    obrigatorio = json['obrigatorio'];
    status = json['status'];
    osxTecXServId = json['osxTecXServId'];
    servCheckListId = json['servCheckListId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    data['obrigatorio'] = this.obrigatorio;
    data['status'] = this.status;
    data['osxTecXServId'] = this.osxTecXServId;
    data['servCheckListId'] = this.servCheckListId;
    return data;
  }
}
