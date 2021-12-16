class FinanceiroComparativoModelo {
  double totalReceitaMesAtual;
  double totalDespesaMesAtual;
  double totalDespesasFixasMesAtual;
  double totalDespesasVariaveisMesAtual;
  double totalPessoasMesAtual;
  double totalImpostosMesAtual;
  double totalGeralMesAtual;
  double totalReceitaMesPassado;
  double totalDespesaMesPassado;
  double totalDespesasFixasMesPassado;
  double totalDespesasVariaveisMesPassado;
  double totalPessoasMesPassado;
  double totalImpostosMesPassado;
  double totalGeralMesPassado;

  FinanceiroComparativoModelo(
      {this.totalReceitaMesAtual,
      this.totalDespesaMesAtual,
      this.totalDespesasFixasMesAtual,
      this.totalDespesasVariaveisMesAtual,
      this.totalPessoasMesAtual,
      this.totalImpostosMesAtual,
      this.totalGeralMesAtual,
      this.totalReceitaMesPassado,
      this.totalDespesaMesPassado,
      this.totalDespesasFixasMesPassado,
      this.totalDespesasVariaveisMesPassado,
      this.totalPessoasMesPassado,
      this.totalImpostosMesPassado,
      this.totalGeralMesPassado});

  FinanceiroComparativoModelo.fromJson(Map<String, dynamic> json) {
    totalReceitaMesAtual = json['totalReceitaMesAtual'];
    totalDespesaMesAtual = json['totalDespesaMesAtual'];
    totalDespesasFixasMesAtual = json['totalDespesasFixasMesAtual'];
    totalDespesasVariaveisMesAtual = json['totalDespesasVariaveisMesAtual'];
    totalPessoasMesAtual = json['totalPessoasMesAtual'];
    totalImpostosMesAtual = json['totalImpostosMesAtual'];
    totalGeralMesAtual = json['totalGeralMesAtual'];
    totalReceitaMesPassado = json['totalReceitaMesPassado'];
    totalDespesaMesPassado = json['totalDespesaMesPassado'];
    totalDespesasFixasMesPassado = json['totalDespesasFixasMesPassado'];
    totalDespesasVariaveisMesPassado = json['totalDespesasVariaveisMesPassado'];
    totalPessoasMesPassado = json['totalPessoasMesPassado'];
    totalImpostosMesPassado = json['totalImpostosMesPassado'];
    totalGeralMesPassado = json['totalGeralMesPassado'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['totalReceitaMesAtual'] = this.totalReceitaMesAtual;
    data['totalDespesaMesAtual'] = this.totalDespesaMesAtual;
    data['totalDespesasFixasMesAtual'] = this.totalDespesasFixasMesAtual;
    data['totalDespesasVariaveisMesAtual'] =
        this.totalDespesasVariaveisMesAtual;
    data['totalPessoasMesAtual'] = this.totalPessoasMesAtual;
    data['totalImpostosMesAtual'] = this.totalImpostosMesAtual;
    data['totalGeralMesAtual'] = this.totalGeralMesAtual;
    data['totalReceitaMesPassado'] = this.totalReceitaMesPassado;
    data['totalDespesaMesPassado'] = this.totalDespesaMesPassado;
    data['totalDespesasFixasMesPassado'] = this.totalDespesasFixasMesPassado;
    data['totalDespesasVariaveisMesPassado'] =
        this.totalDespesasVariaveisMesPassado;
    data['totalPessoasMesPassado'] = this.totalPessoasMesPassado;
    data['totalImpostosMesPassado'] = this.totalImpostosMesPassado;
    data['totalGeralMesPassado'] = this.totalGeralMesPassado;
    return data;
  }
}
