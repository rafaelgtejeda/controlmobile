class OSConfig {
  bool cpfObrigatorio;
  bool fotoObrigatoria;
  bool servicoPorTecnico;

  OSConfig({this.cpfObrigatorio, this.fotoObrigatoria, this.servicoPorTecnico});

  OSConfig.fromJson(Map<String, dynamic> json) {
    cpfObrigatorio = json['cpfObrigatorio'];
    fotoObrigatoria = json['fotoObrigatoria'];
    servicoPorTecnico = json['servicoPorTecnico'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cpfObrigatorio'] = this.cpfObrigatorio;
    data['fotoObrigatoria'] = this.fotoObrigatoria;
    data['servicoPorTecnico'] = this.servicoPorTecnico;
    return data;
  }
}


class OSConfigMaterial {
  bool cobrar;

  OSConfigMaterial({this.cobrar});

  OSConfigMaterial.fromJson(Map<String, dynamic> json) {
    cobrar = json['cobrar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cobrar'] = this.cobrar;
    return data;
  }
}
