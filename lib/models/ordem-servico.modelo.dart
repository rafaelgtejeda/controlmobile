class OrdemServicoGrid {
  List<GridOSItem> gridOSItem;

  OrdemServicoGrid({this.gridOSItem});

  OrdemServicoGrid.fromJson(Map<String, dynamic> json) {
    if (json['gridOSItem'] != null) {
      gridOSItem = new List<GridOSItem>();
      json['gridOSItem'].forEach((v) {
        gridOSItem.add(new GridOSItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.gridOSItem != null) {
      data['gridOSItem'] = this.gridOSItem.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GridOSItem {
  int id;
  String data;
  int quantidade;
  int status;

  GridOSItem({this.id, this.data, this.quantidade, this.status});

  GridOSItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    data = json['data'];
    quantidade = json['quantidade'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['data'] = this.data;
    data['quantidade'] = this.quantidade;
    data['status'] = this.status;
    return data;
  }
}
