class EmpresaEUsuario {
  List<Empresa> empresas;
  Usuario usuario;

  EmpresaEUsuario({this.empresas, this.usuario});

  EmpresaEUsuario.fromJson(Map<String, dynamic> json) {
    if (json['empresas'] != null) {
      empresas = new List<Empresa>();
      json['empresas'].forEach((v) {
        empresas.add(new Empresa.fromJson(v));
      });
    }
    usuario =
        json['usuario'] != null ? new Usuario.fromJson(json['usuario']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.empresas != null) {
      data['empresas'] = this.empresas.map((v) => v.toJson()).toList();
    }
    if (this.usuario != null) {
      data['usuario'] = this.usuario.toJson();
    }
    return data;
  }
}

class Empresa {
  int id;
  String nome;
  String nomeFantasia;
  String timestamp = DateTime.now().toIso8601String();

  Empresa({
    this.id,
    this.nome,
    this.nomeFantasia,
    this.timestamp
  });

  Empresa.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    nomeFantasia = json['nomeFantasia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    data['nomeFantasia'] = this.nomeFantasia;
    return data;
  }

  // to map
  Map<String, dynamic> toMap(Empresa empresaHiveModelo) {
    Map<String, dynamic> empresaMap = Map();
    empresaMap["empresa_id"] = empresaHiveModelo.id;
    empresaMap["empresa_nome"] = empresaHiveModelo.nome;
    empresaMap["empresa_nomeFantasia"] = empresaHiveModelo.nomeFantasia;
    empresaMap["timestamp"] = empresaHiveModelo.timestamp;
    return empresaMap;
  }

  Empresa.fromMap(Map empresaMap) {
    this.id = empresaMap["empresa_id"];
    this.nome = empresaMap["empresa_nome"];
    this.id = empresaMap["empresa_nomeFantasia"];
    this.timestamp = empresaMap["timestamp"];
  }
}

class Usuario {
  String nomeUsuario;
  String fotoPerfil;
  String idioma;

  Usuario({this.nomeUsuario, this.fotoPerfil, this.idioma});

  Usuario.fromJson(Map<String, dynamic> json) {
    nomeUsuario = json['nomeUsuario'];
    fotoPerfil = json['fotoPerfil'];
    idioma = json['idioma'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nomeUsuario'] = this.nomeUsuario;
    data['fotoPerfil'] = this.fotoPerfil;
    data['idioma'] = this.idioma;
    return data;
  }
}
