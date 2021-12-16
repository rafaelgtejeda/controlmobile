class AtualizarChecklistOSGrid {
  int osId;
  List<Itens> itens;

  AtualizarChecklistOSGrid({this.osId, this.itens});

  AtualizarChecklistOSGrid.fromJson(Map<String, dynamic> json) {
    osId = json['osId'];
    if (json['itens'] != null) {
      itens = new List<Itens>();
      json['itens'].forEach((v) {
        itens.add(new Itens.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['osId'] = this.osId;
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Itens {
  int id;
  bool status;

  Itens({this.id, this.status});

  Itens.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status'] = this.status;
    return data;
  }
}
