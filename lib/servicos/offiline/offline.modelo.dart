class Offline {
  int id;
  String endpoint;
  String parameter;
  String object;
  String entryDate;
  String updated;

  Offline(
      {this.id,
      this.endpoint,
      this.parameter,
      this.object,
      this.entryDate,
      this.updated});

  Offline.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    endpoint = json['endpoint'];
    parameter = json['parameter'];
    object = json['object'];
    entryDate = json['entryDate'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['endpoint'] = this.endpoint;
    data['parameter'] = this.parameter;
    data['object'] = this.object;
    data['entryDate'] = this.entryDate;
    data['updated'] = this.updated;
    return data;
  }
}

class OfflineSalvar {
  int id;
  String endpoint;
  String parameters;
  String method;
  String object;
  String entryDate;
  String updated;

  OfflineSalvar(
      {this.id,
      this.endpoint,
      this.parameters,
      this.method,
      this.object,
      this.entryDate,
      this.updated});

  OfflineSalvar.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    endpoint = json['endpoint'];
    parameters = json['parameters'];
    method = json['method'];
    object = json['object'];
    entryDate = json['entryDate'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.id != null) {
      data['id'] = this.id;
    }
    data['endpoint'] = this.endpoint;
    data['parameters'] = this.parameters;
    data['method'] = this.method;
    data['object'] = this.object;
    // data['entryDate'] = this.entryDate;
    data['entryDate'] = DateTime.now().toString();
    if(this.updated != null) {
      data['updated'] = this.updated;
    }
    return data;
  }
}

class OfflineExibicao {
  int id;
  String endpoint;
  String object;
  String entryDate;
  String updated;

  OfflineExibicao(
      {this.id,
      this.endpoint,
      this.object,
      this.entryDate,
      this.updated});

  OfflineExibicao.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    endpoint = json['endpoint'];
    object = json['object'];
    entryDate = json['entryDate'];
    updated = json['updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['endpoint'] = this.endpoint;
    data['object'] = this.object;
    data['entryDate'] = this.entryDate;
    data['updated'] = this.updated;
    return data;
  }
}
