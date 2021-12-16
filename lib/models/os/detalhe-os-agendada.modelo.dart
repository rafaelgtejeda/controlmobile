class DetalheOSAgendada {
  int id;
  int osId;
  int numeroOS;
  String descricaoStatus;
  String descricaoStatusTecnico;
  int tipo;
  String descricaoTipo;
  double latitude;
  double longitude;
  String endereco;
  String numero;
  String complemento;
  String bairro;
  String estado;
  String cidade;
  String cep;
  int clienteId;
  String codigoCliente;
  String nomeCliente;
  String nomeFantasiaCliente;
  String dataInicio;
  String dataFim;
  String ddI1;
  String ddD1;
  String telefone1;
  String telefoneCliente;
  String ddiC1;
  String dddC1;
  String celular1;
  String celularCliente;
  int atendenteId;
  String nomeAtendente;
  String dataAtendimento;
  List<Equipamentos> equipamentos;
  List<ServicosContrato> servicosContrato;
  String descricaoDetalhada;
  String emailCliente;
  String nomeContato;
  String ddI1Contato;
  String ddD1Contato;
  String telefone1Contato;
  String telefoneContato;
  String ddiC1Contato;
  String dddC1Contato;
  String celular1Contato;
  String celularContato;
  String emailContato;
  int empresaId;
  int statusOS;
  int statusTecnico;

  DetalheOSAgendada(
      {this.id,
      this.osId,
      this.numeroOS,
      this.descricaoStatus,
      this.descricaoStatusTecnico,
      this.tipo,
      this.descricaoTipo,
      this.latitude,
      this.longitude,
      this.endereco,
      this.numero,
      this.complemento,
      this.bairro,
      this.estado,
      this.cidade,
      this.cep,
      this.clienteId,
      this.codigoCliente,
      this.nomeCliente,
      this.nomeFantasiaCliente,
      this.dataInicio,
      this.dataFim,
      this.ddI1,
      this.ddD1,
      this.telefone1,
      this.telefoneCliente,
      this.ddiC1,
      this.dddC1,
      this.celular1,
      this.celularCliente,
      this.atendenteId,
      this.nomeAtendente,
      this.dataAtendimento,
      this.equipamentos,
      this.servicosContrato,
      this.descricaoDetalhada,
      this.emailCliente,
      this.nomeContato,
      this.ddI1Contato,
      this.ddD1Contato,
      this.telefone1Contato,
      this.telefoneContato,
      this.ddiC1Contato,
      this.dddC1Contato,
      this.celular1Contato,
      this.celularContato,
      this.emailContato,
      this.empresaId,
      this.statusOS,
      this.statusTecnico});

  DetalheOSAgendada.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    osId = json['osId'];
    numeroOS = json['numeroOS'];
    descricaoStatus = json['descricaoStatus'];
    descricaoStatusTecnico = json['descricaoStatusTecnico'];
    tipo = json['tipo'];
    descricaoTipo = json['descricaoTipo'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    endereco = json['endereco'];
    numero = json['numero'];
    complemento = json['complemento'];
    bairro = json['bairro'];
    estado = json['estado'];
    cidade = json['cidade'];
    cep = json['cep'];
    clienteId = json['clienteId'];
    codigoCliente = json['codigoCliente'];
    nomeCliente = json['nomeCliente'];
    nomeFantasiaCliente = json['nomeFantasiaCliente'];
    dataInicio = json['dataInicio'];
    dataFim = json['dataFim'];
    ddI1 = json['ddI1'];
    ddD1 = json['ddD1'];
    telefone1 = json['telefone1'];
    telefoneCliente = json['telefoneCliente'];
    ddiC1 = json['ddiC1'];
    dddC1 = json['dddC1'];
    celular1 = json['celular1'];
    celularCliente = json['celularCliente'];
    atendenteId = json['atendenteId'];
    nomeAtendente = json['nomeAtendente'];
    dataAtendimento = json['dataAtendimento'];
    if (json['equipamentos'] != null) {
      equipamentos = new List<Equipamentos>();
      json['equipamentos'].forEach((v) {
        equipamentos.add(new Equipamentos.fromJson(v));
      });
    }
    if (json['servicosContrato'] != null) {
      servicosContrato = new List<ServicosContrato>();
      json['servicosContrato'].forEach((v) {
        servicosContrato.add(new ServicosContrato.fromJson(v));
      });
    }
    descricaoDetalhada = json['descricaoDetalhada'];
    emailCliente = json['emailCliente'];
    nomeContato = json['nomeContato'];
    ddI1Contato = json['ddI1Contato'];
    ddD1Contato = json['ddD1Contato'];
    telefone1Contato = json['telefone1Contato'];
    telefoneContato = json['telefoneContato'];
    ddiC1Contato = json['ddiC1Contato'];
    dddC1Contato = json['dddC1Contato'];
    celular1Contato = json['celular1Contato'];
    celularContato = json['celularContato'];
    emailContato = json['emailContato'];
    empresaId = json['empresaId'];
    statusTecnico = json['statusTecnico'];
    statusOS = json['statusOS'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['osId'] = this.osId;
    data['numeroOS'] = this.numeroOS;
    data['descricaoStatus'] = this.descricaoStatus;
    data['descricaoStatusTecnico'] = this.descricaoStatusTecnico;
    data['tipo'] = this.tipo;
    data['descricaoTipo'] = this.descricaoTipo;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['endereco'] = this.endereco;
    data['numero'] = this.numero;
    data['complemento'] = this.complemento;
    data['bairro'] = this.bairro;
    data['estado'] = this.estado;
    data['cidade'] = this.cidade;
    data['cep'] = this.cep;
    data['clienteId'] = this.clienteId;
    data['codigoCliente'] = this.codigoCliente;
    data['nomeCliente'] = this.nomeCliente;
    data['nomeFantasiaCliente'] = this.nomeFantasiaCliente;
    data['dataInicio'] = this.dataInicio;
    data['dataFim'] = this.dataFim;
    data['ddI1'] = this.ddI1;
    data['ddD1'] = this.ddD1;
    data['telefone1'] = this.telefone1;
    data['telefoneCliente'] = this.telefoneCliente;
    data['ddiC1'] = this.ddiC1;
    data['dddC1'] = this.dddC1;
    data['celular1'] = this.celular1;
    data['celularCliente'] = this.celularCliente;
    data['atendenteId'] = this.atendenteId;
    data['nomeAtendente'] = this.nomeAtendente;
    data['dataAtendimento'] = this.dataAtendimento;
    if (this.equipamentos != null) {
      data['equipamentos'] = this.equipamentos.map((v) => v.toJson()).toList();
    }
    if (this.servicosContrato != null) {
      data['servicosContrato'] =
          this.servicosContrato.map((v) => v.toJson()).toList();
    }
    data['descricaoDetalhada'] = this.descricaoDetalhada;
    data['emailCliente'] = this.emailCliente;
    data['nomeContato'] = this.nomeContato;
    data['ddI1Contato'] = this.ddI1Contato;
    data['ddD1Contato'] = this.ddD1Contato;
    data['telefone1Contato'] = this.telefone1Contato;
    data['telefoneContato'] = this.telefoneContato;
    data['ddiC1Contato'] = this.ddiC1Contato;
    data['dddC1Contato'] = this.dddC1Contato;
    data['celular1Contato'] = this.celular1Contato;
    data['celularContato'] = this.celularContato;
    data['emailContato'] = this.emailContato;
    data['empresaId'] = this.empresaId;
    data['statusTecnico'] = this.statusTecnico;
    data['statusOS'] = this.statusOS;
    return data;
  }
}

class Equipamentos {
  int id;
  String descricaoProduto;
  double quantidade;

  Equipamentos({this.id, this.descricaoProduto, this.quantidade});

  Equipamentos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    descricaoProduto = json['descricaoProduto'];
    quantidade = json['quantidade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['descricaoProduto'] = this.descricaoProduto;
    data['quantidade'] = this.quantidade;
    return data;
  }
}

class ServicosContrato {
  int id;
  String descricao;

  ServicosContrato({this.id, this.descricao});

  ServicosContrato.fromJson(Map<String, dynamic> json) {
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
