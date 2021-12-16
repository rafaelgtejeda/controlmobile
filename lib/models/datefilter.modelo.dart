class DateFilter {
  String inicio;
  String fim;

  DateFilter({this.inicio, this.fim});

  DateFilter.map(dynamic obj) {
    this.inicio = obj["inicio"];
    this.fim = obj["fim"];
  }

  Map<String, dynamic> toMap() {
    return {'inicio': inicio, 'fim': fim};
  }
}
