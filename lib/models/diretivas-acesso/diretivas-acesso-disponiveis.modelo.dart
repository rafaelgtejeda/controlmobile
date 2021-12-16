class DiretivasAcessoDisponiveis {
  FinanceiroAcessos financeiro = new FinanceiroAcessos();
  VendaAcessos venda = new VendaAcessos();
  OrdemServicoAcessos ordemServico = new OrdemServicoAcessos();
  ClienteAcessos cliente = new ClienteAcessos();

  DiretivasAcessoDisponiveis({this.financeiro, this.venda, this.ordemServico, this.cliente});
}

class FinanceiroAcessos {
  bool possuiContasFinanceiras = false;
  bool possuiTodasAsContas = false;
  bool possuiContasAPagar = false;
  bool possuiContasAReceber = false;
  bool possuiDRE = false;
  bool possuiHistorico = false;
  bool possuiFinanceiro = false;

  FinanceiroAcessos({
    this.possuiContasFinanceiras, this.possuiTodasAsContas, this.possuiContasAPagar,
    this.possuiContasAReceber, this.possuiDRE, this.possuiHistorico, this.possuiFinanceiro
  });
}

class VendaAcessos {
  bool possuiOrcamentosFinalizados = false;
  bool possuiVendasDiarias = false;
  bool possuiContratosCancelados = false;
  bool possuiOrcamentosPendentes = false;
  bool possuiComparativoDeVendas = false;
  bool possuiLiberacaoTotalVendasLabel = false;
  bool possuiVendas = false;

  VendaAcessos({
    this.possuiOrcamentosFinalizados, this.possuiVendasDiarias, this.possuiContratosCancelados,
    this.possuiOrcamentosPendentes, this.possuiComparativoDeVendas, this.possuiLiberacaoTotalVendasLabel,
    this.possuiVendas
  });
}

class OrdemServicoAcessos {
  bool possuiOrdemDeServico = false;
  bool possuiEditarOrdemDeServico = false;
  bool possuiAdicionarMaterialServico = false;
  bool possuiEditarMaterialServico = false;
  bool possuiDeletarMaterialServico = false;
  bool possuiVisualizarMaterialServico = false;
  bool possuiVisualizarValorMaterialServico = false;
  bool possuiVisualizarReagendar = false;

  OrdemServicoAcessos({
    this.possuiOrdemDeServico, this.possuiEditarOrdemDeServico, this.possuiAdicionarMaterialServico,
    this.possuiEditarMaterialServico, this.possuiDeletarMaterialServico, this.possuiVisualizarMaterialServico,
    this.possuiVisualizarValorMaterialServico, this.possuiVisualizarReagendar
  });
}

class ClienteAcessos {
  bool possuiClientes = false;

  ClienteAcessos({
    this.possuiClientes
  });
}
