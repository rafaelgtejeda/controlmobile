class Request {

  static const String BASE_URL = "http://homologacao.fullcontrol.com.br:8077/";

  // FULLCONTROL

  // static const String BASE_URL = "http://apimobile.fullcontrol.com.br/";
  // static const String BASE_URL = "http://192.168.0.145:5000/";
  // static const String BASE_URL = "http://192.168.11.222:5000/";
  // static const String BASE_URL = "http://172.17.0.21:8077/";
  // static const String BASE_URL = "http://172.17.0.21:8078/";

  // ATMOS
  // static const String BASE_URL = "http://atmoserp.com/api/";
  // static const String BASE_URL = "http://172.17.0.21:8078/";
  // static const String BASE_URL = "http://homologacao.fullcontrol.com.br:8003/";
  // static const String BASE_URL = "http://homologacao.fullcontrol.com.br:8003/";
        

  static const String POST = "POST";
  static const String GET = "GET";
  static const String PUT = "PUT";
  static const String DELETE = "DELETE";

  static const int SKIP = 0;
  static const int TAKE = 50;

}

class Endpoints {
  // LOGIN
  static const String ACCOUNT_LOGIN = 'Account/Login';

  // EMPRESA
  static const String EMPRESAS = 'Empresas/';
  static const String EMPRESA_ACESSOS = 'Empresa/Acessos/';

  // CLIENTE
  static const String PARCEIRO = 'Parceiro/';
  static const String PARCEIROS = 'Parceiros/';
  static const String PARCEIRO_LOOKUP = 'Parceiro/LookupParceiro/';
  static const String SITUACAO_PARCEIRO_LOOKUP = 'Parceiro/SituacaoParceiroLookup/';
  static const String PARCEIRO_SELECIONAR_TODOS = 'Parceiro/SelecionarTodos/';
  static const String PARCEIRO_INCLUIR_PROSPECT = 'Parceiro/IncluirProspect/';
  static const String PARCEIRO_CONSULTAR_CNPJ = 'Parceiro/ConsultarCnpj/';

  // ORCAMENTO
  static const String ORCAMENTOS = 'Orcamentos/';
  static const String ORCAMENTO_OBTER = 'Orcamento/Obter/';
  static const String ORCAMENTO_REMOVER = 'Orcamento/Remover';
  static const String ORCAMENTO_OBTER_PARCELAS_VENCIMENTOS = 'Orcamento/ObterParcelasVencimentos/';
  static const String ORCAMENTO_INCLUIR = 'Orcamento/Incluir/';
  static const String ORCAMENTO_ATUALIZAR = 'Orcamento/Atualizar/';
  static const String ORCAMENTO_PDF = 'Orcamento/Pdf/';
  static const String ORCAMENTO_ASSINAR = 'Orcamento/Assinar/';

  // FINANCEIRO
  static const String FINANCEIRO_OBTER_DASHBOARD = 'Financeiro/ObterDashboard/';
  static const String FINANCEIRO_OBTER_DRE = 'Financeiro/ObterDRE/';
  static const String FINANCEIRO_OBTER_PREVISTO_REALIZADO = 'Financeiro/ObterPrevistoRealizado/';
  static const String FINANCEIRO_OBTER_LANCAMENTO_PREVISTO = 'Financeiro/ObterLancamentoPrevisto/';
  static const String FINANCEIRO_OBTER_LANCAMENTO_PREVISTO_REALIZADO = 'Financeiro/ObterLancamentoPrevistoRealizado/';
  static const String FINANCEIRO_OBTER_HISTORICO_LANCAMENTO = 'Financeiro/ObterHistoricoLancamentos/';
  static const String FINANCEIRO_OBTER_COMPARATIVO = 'Financeiro/ObterComparativo/';

  static const String LOOKUP_VENDEDORES = 'Usuario/LookupVendedores/';
  static const String LOOKUP_PRODUTOS = 'Produto/Lookup/';

  // ORDEM DE SERVIÇO
  static const String GRID_OS_PRXIMOS_CHAMADOS = 'OrdemServico/GridOSProximosChamados/';
  static const String GRID_OS_AGENDADA = 'OrdemServico/GridOSAgendada/';
  static const String DETALHE_OS_AGENDADA = 'OrdemServico/DetalheOSAgendada/';
  static const String GRID_MATERIAL = 'OrdemServico/GridMaterial/';
  static const String GRID_CHECKLISTS_OS = 'OrdemServico/GridCheckList/';
  static const String GRID_FINALIZACAO_TECNICO_X_SERVICO = 'OrdemServico/GridFinalizacaoTecnicoXServico/';
  static const String GRID_FINALIZACAO_SERVICO_X_CHECKLIST = 'OrdemServico/GridFinalizacaoServicoXCheckList/';
  static const String GET_OS_CONFIG = 'OrdemServico/GetOSConfig/';
  static const String GET_OS_CONFIG_MATERIAL = 'TipoOrdemServico/ObterConfigOS/';

  static const String ADICIONAR_MATERIAL = 'OrdemServico/AdicionarMaterial/';
  static const String ATUALIZAR_MATERIAL = 'OrdemServico/AtualizarMaterial/';
  static const String REMOVER_MATERIAL = 'OrdemServico/RemoverMaterial/';
  static const String ATUALIZAR_STATUS_OS = 'OrdemServico/AtualizarStatus/';
  static const String ATUALIZAR_STATUS_CHECKLISTS = 'OrdemServico/AtualizarStatusCheckList/';
  static const String FINALIZAR_TECNICO_OS = 'OrdemServico/FinalizarTecnicoOS/';
  static const String ATUALIZAR_STATUS_SERVICO_X_TECNICO = 'OrdemServico/AtualizarStatusServicoXTecnico/';
  static const String ATUALIZAR_STATUS_CHECK_X_SERVICO = 'OrdemServico/AtualizarStatusCheckXServico/';
  static const String REAGENDAR = 'OrdemServico/Reagendar/';
}
