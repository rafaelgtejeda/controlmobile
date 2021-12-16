class Paises {
  
  List<PaisesLista> paisesLista;

  Paises({this.paisesLista});

  Paises.fromJson(Map<String, dynamic> json) {
    if (json['paisesLista'] != null) {
      paisesLista = new List<PaisesLista>();
      json['paisesLista'].forEach((v) {
        paisesLista.add(new PaisesLista.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.paisesLista != null) {
      data['paisesLista'] = this.paisesLista.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class PaisesLista {

  String sigla;
  String bandeira;
  String pais;
  String ddi;

  PaisesLista({this.sigla, this.bandeira, this.pais, this.ddi});

  PaisesLista.fromJson(Map<String, dynamic> json) {
    sigla = json['sigla'];
    bandeira = json['bandeira'];
    pais = json['pais'];
    ddi = json['ddi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sigla'] = this.sigla;
    data['bandeira'] = this.bandeira;
    data['pais'] = this.pais;
    data['ddi'] = this.ddi;
    return data;
  }
}
