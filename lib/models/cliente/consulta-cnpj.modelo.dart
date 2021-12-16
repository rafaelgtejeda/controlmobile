class ConsultaCNPJModelo {
	Entidade entidade;
	List<Endereco> enderecos;

	ConsultaCNPJModelo({this.entidade, this.enderecos});

	ConsultaCNPJModelo.fromJson(Map<String, dynamic> json) {
		entidade = json['entidade'] != null ? new Entidade.fromJson(json['entidade']) : null;
		if (json['enderecos'] != null) {
			enderecos = new List<Endereco>();
			json['enderecos'].forEach((v) { enderecos.add(new Endereco.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.entidade != null) {
      data['entidade'] = this.entidade.toJson();
    }
		if (this.enderecos != null) {
      data['enderecos'] = this.enderecos.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class Endereco {
  String cep;
  String codigoIBGE;
  String endereco;
  String numero;
  String bairro;
  String complemento;
  String cidade;
  String uf;
  int cidadeEstrangeiroId;

  Endereco(
      {this.cep,
      this.codigoIBGE,
      this.endereco,
      this.numero,
      this.bairro,
      this.complemento,
      this.cidade,
      this.uf,
      this.cidadeEstrangeiroId});

  Endereco.fromJson(Map<String, dynamic> json) {
    cep = json['cep'];
    codigoIBGE = json['codigoIBGE'];
    endereco = json['endereco'];
    numero = json['numero'];
    bairro = json['bairro'];
    complemento = json['complemento'];
    cidade = json['cidade'];
    uf = json['uf'];
    cidadeEstrangeiroId = json['cidadeEstrangeiroId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cep'] = this.cep;
    data['codigoIBGE'] = this.codigoIBGE;
    data['endereco'] = this.endereco;
    data['numero'] = this.numero;
    data['bairro'] = this.bairro;
    data['complemento'] = this.complemento;
    data['cidade'] = this.cidade;
    data['uf'] = this.uf;
    data['cidadeEstrangeiroId'] = this.cidadeEstrangeiroId;
    return data;
  }
}

class Entidade {
	List<AtividadePrincipal> atividadePrincipal;
	String dataSituacao;
	String complemento;
	String nome;
	String uf;
	String telefone;
	String email;
	List<AtividadePrincipal> atividadesSecundarias;
	// List<dynamic> qsa;
	String situacao;
	String bairro;
	String logradouro;
	String numero;
	String cep;
	String municipio;
	String porte;
	String abertura;
	String naturezaJuridica;
	String fantasia;
	String cnpj;
	String ultimaAtualizacao;
	String status;
	String tipo;
	String efr;
	String motivoSituacao;
	String situacaoEspecial;
	String dataSituacaoEspecial;
	String capitalSocial;
	// Extra extra;
	Billing billing;

	Entidade({this.atividadePrincipal, this.dataSituacao, this.complemento, this.nome, this.uf, this.telefone, this.email, this.atividadesSecundarias, this.situacao, this.bairro, this.logradouro, this.numero, this.cep, this.municipio, this.porte, this.abertura, this.naturezaJuridica, this.fantasia, this.cnpj, this.ultimaAtualizacao, this.status, this.tipo, this.efr, this.motivoSituacao, this.situacaoEspecial, this.dataSituacaoEspecial, this.capitalSocial, this.billing});

	// ConsultaNPJModelo({this.atividadePrincipal, this.dataSituacao, this.complemento, this.nome, this.uf, this.telefone, this.email, this.atividadesSecundarias, this.qsa, this.situacao, this.bairro, this.logradouro, this.numero, this.cep, this.municipio, this.porte, this.abertura, this.naturezaJuridica, this.fantasia, this.cnpj, this.ultimaAtualizacao, this.status, this.tipo, this.efr, this.motivoSituacao, this.situacaoEspecial, this.dataSituacaoEspecial, this.capitalSocial, this.extra, this.billing});

	Entidade.fromJson(Map<String, dynamic> json) {
		if (json['atividade_principal'] != null) {
			atividadePrincipal = new List<AtividadePrincipal>();
			json['atividade_principal'].forEach((v) { atividadePrincipal.add(new AtividadePrincipal.fromJson(v)); });
		}
		dataSituacao = json['data_situacao'];
		complemento = json['complemento'];
		nome = json['nome'];
		uf = json['uf'];
		telefone = json['telefone'];
		email = json['email'];
		if (json['atividades_secundarias'] != null) {
			atividadesSecundarias = new List<AtividadePrincipal>();
			json['atividades_secundarias'].forEach((v) { atividadesSecundarias.add(new AtividadePrincipal.fromJson(v)); });
		}
		// if (json['qsa'] != null) {
		// 	qsa = new List<dynamic>();
		// 	json['qsa'].forEach((v) { qsa.add(new dynamic.fromJson(v)); });
		// }
		situacao = json['situacao'];
		bairro = json['bairro'];
		logradouro = json['logradouro'];
		numero = json['numero'];
		cep = json['cep'];
		municipio = json['municipio'];
		porte = json['porte'];
		abertura = json['abertura'];
		naturezaJuridica = json['natureza_juridica'];
		fantasia = json['fantasia'];
		cnpj = json['cnpj'];
		ultimaAtualizacao = json['ultima_atualizacao'];
		status = json['status'];
		tipo = json['tipo'];
		efr = json['efr'];
		motivoSituacao = json['motivo_situacao'];
		situacaoEspecial = json['situacao_especial'];
		dataSituacaoEspecial = json['data_situacao_especial'];
		capitalSocial = json['capital_social'];
		// extra = json['extra'] != null ? new Extra.fromJson(json['extra']) : null;
		billing = json['billing'] != null ? new Billing.fromJson(json['billing']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		if (this.atividadePrincipal != null) {
      data['atividade_principal'] = this.atividadePrincipal.map((v) => v.toJson()).toList();
    }
		data['data_situacao'] = this.dataSituacao;
		data['complemento'] = this.complemento;
		data['nome'] = this.nome;
		data['uf'] = this.uf;
		data['telefone'] = this.telefone;
		data['email'] = this.email;
		if (this.atividadesSecundarias != null) {
      data['atividades_secundarias'] = this.atividadesSecundarias.map((v) => v.toJson()).toList();
    }
		// if (this.qsa != null) {
    //   data['qsa'] = this.qsa.map((v) => v.toJson()).toList();
    // }
		data['situacao'] = this.situacao;
		data['bairro'] = this.bairro;
		data['logradouro'] = this.logradouro;
		data['numero'] = this.numero;
		data['cep'] = this.cep;
		data['municipio'] = this.municipio;
		data['porte'] = this.porte;
		data['abertura'] = this.abertura;
		data['natureza_juridica'] = this.naturezaJuridica;
		data['fantasia'] = this.fantasia;
		data['cnpj'] = this.cnpj;
		data['ultima_atualizacao'] = this.ultimaAtualizacao;
		data['status'] = this.status;
		data['tipo'] = this.tipo;
		data['efr'] = this.efr;
		data['motivo_situacao'] = this.motivoSituacao;
		data['situacao_especial'] = this.situacaoEspecial;
		data['data_situacao_especial'] = this.dataSituacaoEspecial;
		data['capital_social'] = this.capitalSocial;
		// if (this.extra != null) {
    //   data['extra'] = this.extra.toJson();
    // }
		if (this.billing != null) {
      data['billing'] = this.billing.toJson();
    }
		return data;
	}
}

class AtividadePrincipal {
	String text;
	String code;

	AtividadePrincipal({this.text, this.code});

	AtividadePrincipal.fromJson(Map<String, dynamic> json) {
		text = json['text'];
		code = json['code'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['text'] = this.text;
		data['code'] = this.code;
		return data;
	}
}

// class Extra {


// 	Extra({});

// 	Extra.fromJson(Map<String, dynamic> json) {
// 	}

// 	Map<String, dynamic> toJson() {
// 		final Map<String, dynamic> data = new Map<String, dynamic>();
// 		return data;
// 	}
// }

class Billing {
	bool free;
	bool database;

	Billing({this.free, this.database});

	Billing.fromJson(Map<String, dynamic> json) {
		free = json['free'];
		database = json['database'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['free'] = this.free;
		data['database'] = this.database;
		return data;
	}
}
