import 'package:flutter/foundation.dart';

class MaterialServicoGrid {

  List<MaterialServico> lista;
  Sumario sumario;

  MaterialServicoGrid({this.lista, this.sumario});

  MaterialServicoGrid.fromJson(Map<String, dynamic> json) {
    if (json['lista'] != null) {
      lista = new List<MaterialServico>();
      json['lista'].forEach((v) {
        lista.add(new MaterialServico.fromJson(v));
      });
    }
    
    sumario = json['sumario'] != null ? new Sumario.fromJson(json['sumario']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.lista != null) {
      data['lista'] = this.lista.map((v) => v.toJson()).toList();
    }
    if (this.sumario != null) {
      data['sumario'] = this.sumario.toJson();
    }
    return data;
  }
}

class MaterialServico {

  int id;
  int osId;
  String descricao;
  int produtoId;
  int produtoTipo;
  double quantidade;
  String codigoUnidade;
  double valorTotal;
  double valor;
  bool cobrar;
  bool locacao;
  bool isSelected = false;

  MaterialServico(
      {
      this.id,
      this.osId,
      this.descricao,
      this.produtoId,
      this.produtoTipo,
      this.quantidade,
      this.codigoUnidade,
      this.valorTotal,
      this.valor,
      this.cobrar,
      this.locacao
      });

  MaterialServico.fromJson(Map<String, dynamic> json) {
    
    id = json['id'];
    if(json['osId'] != null) {
      osId = json['osId'];
    }
    descricao = json['descricao'];
    produtoId = json['produtoId'];
    produtoTipo = json['produtoTipo'];
    quantidade = json['quantidade'];
    codigoUnidade = json['codigoUnidade'];
    valor = json['valor'];
    valorTotal = json['valorTotal'];

    if(json['cobrar'] is !bool) {
      if(json['cobrar'] == 'true') {
        cobrar = true;
      }
      else {
        cobrar = false;
      }
    }
    else {
      cobrar = json['cobrar'];
    }

    if(json['locacao'] is !bool) {
      if(json['locacao'] == 'true') {
        locacao = true;
      }
      else {
        locacao = false;
      }
    }
    else {
      locacao = json['locacao'];
    }
  }

  Map<String, dynamic> toJson({bool offline = false}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if(this.osId != null) {
      data['osId'] = this.osId;
    }
    data['descricao'] = this.descricao;
    data['produtoId'] = this.produtoId;
    data['produtoTipo'] = this.produtoTipo;
    data['quantidade'] = this.quantidade;
    data['codigoUnidade'] = this.codigoUnidade;
    data['valor'] = this.valor;
    data['valorTotal'] = this.valorTotal;
    if(offline) {
      data['cobrar'] = this.cobrar.toString();
      data['locacao'] = this.locacao.toString();
    }
    else {
      data['cobrar'] = this.cobrar;
      data['locacao'] = this.locacao;
    }
    return data;
  }
}

class Sumario {
  int osId;
  double totalCobrar;
  double total;

  Sumario({this.osId, this.totalCobrar, this.total});

  Sumario.fromJson(Map<String, dynamic> json) {
    if(json['osId'] != null) {
      osId = json['osId'];
    }
    totalCobrar = json['totalCobrar'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.osId != null) {
      data['osId'] = this.osId;
    }
    data['totalCobrar'] = this.totalCobrar;
    data['total'] = this.total;
    return data;
  }
}

class MaterialServicoSave {
  int id;
  int osId;
  int produtoId;
  int produtoTipo;
  String descricao;
  String descricaoResumida;
  double quantidade;
  double valor;
  bool cobrar;
  String unidadeMedida;
  bool locacao;

  MaterialServicoSave(
      {this.id,
      this.osId,
      this.produtoId,
      this.produtoTipo,
      this.descricao,
      this.descricaoResumida,
      this.quantidade,
      this.valor,
      this.cobrar,
      this.unidadeMedida,
      this.locacao});

  MaterialServicoSave.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    osId = json['osId'];
    produtoId = json['produtoId'];
    // produtoTipo = json['produtoTipo'];
    descricao = json['descricao'];
    descricaoResumida = json['descricaoResumida'];
    quantidade = json['quantidade'];
    valor = json['valor'];
    cobrar = json['cobrar'];
    unidadeMedida = json['unidadeMedida'];
    locacao = json['locacao'];
  }

  Map<String, dynamic> novoMaterialServicoJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['osId'] = this.osId;
    data['produtoId'] = this.produtoId;
    // data['produtoTipo'] = this.produtoTipo;
    data['descricao'] = this.descricao;
    data['descricaoResumida'] = this.descricaoResumida;
    data['quantidade'] = this.quantidade;
    data['valor'] = this.valor;
    data['cobrar'] = this.cobrar;
    data['unidadeMedida'] = this.unidadeMedida;
    data['locacao'] = this.locacao;
    return data;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['osId'] = this.osId;
    data['produtoId'] = this.produtoId;
    data['descricao'] = this.descricao;
    data['descricaoResumida'] = this.descricaoResumida;
    data['quantidade'] = this.quantidade;
    data['valor'] = this.valor;
    data['cobrar'] = this.cobrar;
    data['unidadeMedida'] = this.unidadeMedida;
    data['locacao'] = this.locacao;
    return data;
  }
}
