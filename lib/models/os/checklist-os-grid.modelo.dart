class ChecklistOSGrid {
  int id;
  String descricao;
  bool status = false;

  ChecklistOSGrid({this.id, this.descricao});

  ChecklistOSGrid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricao = json['descricao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricao'] = this.descricao;
    return data;
  }
}
