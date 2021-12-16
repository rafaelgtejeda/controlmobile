class TipoClienteConstante {
  static const int PESSOA_JURIDICA = 1;
  static const int PESSOA_FISICA = 2;
  static const int ESTRANGEIRO = 3;
}

class CategoriaFinanceiroConstante {
  static const int MENOS2 = -2;
  static const int MENOS1 = -1;
  static const int RECEBIMENTOS = 1;
  static const int DESPESAS_FIXAS = 2;
  static const int DESPESAS_VARIAVEIS = 3;
  static const int PESSOAS = 4;
  static const int IMPOSTOS = 5;
  static const int TRANSFERENCIAS_SAIDA = 6;
  static const int TRANSFERENCIAS_ENTRADA = 7;
}

class ListagemOrcamentoConstante {
  static const int PENDENTE = 1;
  static const int CONCLUIDO = 2;
  // static const int REJEITADO = 2;
  static const int ASSINADO = 3;
  // static const int VINCULADO = 4;

  // static const int PENDENTE = 0;
  // static const int CONCLUIDO = 1;
  // static const int REJEITADO = 2;
  // static const int ASSINADO = 3;
  // static const int VINCULADO = 4;
}

class ListagemOrcamentoConstanteString {
  static const String PENDENTE = 'Pendente';
  static const String CONCLUIDO = 'Concluido';
  static const String ASSINADO = 'Assinado';
  static const String REJEITADO = 'Rejeitado';
  static const String VINCULADO = 'Vinculado';
}

class TiposOrcamentos {
  static const int VENDA = 1;
  static const int SERVICO = 2;
}

class ProdutoTipoConstante {
  static const int REVENDA = 1;
  static const int MATERIA_PRIMA = 2;
  static const int EMBALAGEM = 3;
  static const int PRODUTO_EM_PROCESSO = 4;
  static const int PRODUTO_ACABADO = 5;
  static const int SUBPRODUTO = 6;
  static const int PRODUTO_INTERMEDIARIO = 7;
  static const int MATERIAL_CONSUMO = 8;
  static const int ATIVO_IMOBILIZADO = 9;
  static const int SERVICOS = 10;
  static const int OUTROS_INSUMOS = 11;
  static const int OUTROS = 12;
  static const int KIT = 13;

  // Parque Tecnologico = [1, 9, 10, 13]

  // Produto = [1,9,13]
  // Servico = [10]
}

class ProdutoSituacaoConstante {
  static const int ATIVO = 1;
  static const int INATIVO = 2;
  static const int SEM_MOVIMENTACAO = 3;
}

class TiposPadraoLimiteCredito {
  static const String NAO_CONTROLAR = '0';
  static const String POR_TOTAL = '1';
  static const String POR_FORMA_RECEBIMETO = '2';
}

class StatusOrdemDeServico {
  static const int Agendado = 1; //Cor: Vermelho(#FF0000)
  static const int Nova = 2; //Cor: Branco(#FFFFFF)
  static const int Despachado = 3; //Cor: Amarelo(#FFFF00)
  static const int Finalizado = 4; //Cor: Preto(#000000)
  static const int ACaminho = 5; //Cor: DarkOliveGreen1(#CAFF70)
  static const int Atendendo = 6; //Cor: Verde(#00FF00)
  static const int Reagendado = 7; //Cor: Laranja(#FFA500)
  static const int Entregue = 8; //Cor: SteelBlue1(#63B8FF)
  static const int EmExecucao = 9;
  static const int FinalizacaoTecnico = 10; //Cor: DarkGreen(#006400)
  static const int EntregaCancelada = 11; //Cor: RoyalBlue4(#27408B)
  static const int FechamentoParcial = 12; //Cor: DimGrey(#696969)
  static const int CancelamentoFechamento = 13; //Cor: LightSlateGray(#778899)
  static const int CancelamentoConclusao = 14; //Cor: LightGray(#D3D3D3)
  static const int CancelamentoFinalizacaoTecnico = 15; //Cor: MediumAquamarine(#66CDAA)
  static const int Visualizada = 16; // Cor: Purple(#691A99)
  static const int FinalizacaoSemSucessoTecnico = 17;
  static const int Excluido = 18;
}

class DiretivasAcessoMobileConstantes {
  static const int ManagerMobFinanceiroContasFinanceiras = 42;
  static const int ManagerMobFinanceiroTodasAsContas = 43;
  static const int ManagerMobFinanceiroContasAReceber = 44;
  static const int ManagerMobFinanceiroContasAPagar = 45;
  static const int ManagerMobFinanceiroDRE = 46;
  static const int ManagerMobFinanceiroHistorico = 47;
  static const int ManagerMobVendasOrcamentosFinalizados = 48;
  static const int ManagerMobVendasHistorico = 49;
  static const int ManagerMobVendasDiarias = 50;
  static const int ManagerMobVendasContratosCancelados = 51;
  static const int ManagerMobVendasOrcamentosPendentes = 52;
  static const int ManagerMobVendasComparativoDeVendas = 53;
  static const int ManagerPushSaldoConta = 54;
  static const int ManagerPushTotalAPagarDia = 55;
  static const int ManagerPushTotalAReceberDia = 56;
  static const int ManagerPushTotalVendas = 57;
  static const int ManagerMobOSAcessarTecnico = 87;
  static const int ManagerMobOSVisualizarMaterial = 92;
  static const int ManagerMobOSAdicionarMaterial = 93;
  static const int ManagerMobOSEditarMaterial = 94;
  static const int ManagerMobOSExcluirMaterial = 95;
  static const int ManagerMobOSVisualizarValorMaterial = 96;
  static const int ManagerMovimentacaoDistribuicao = 146;
  static const int ManagerMovimentacaoFinanceira = 147;
  static const int ManagerMobReagendarOS = 162;
  static const int ManagerMobVisualizarSaldos = 206;
  static const int ManagerMobVisualizarClientes = 283;
}

class DiretivasAcessoConstantes {
  static const int ManagerTraducao = -1;
  static const int NaoDefinido = 0;
  static const int ManagerEmpresa = 1;
  static const int ManagerProduto = 2;
  static const int ManagerUsuario = 3;
  static const int ManagerContato = 4;
  static const int ManagerMovimentacao = 5;
  static const int ManagerContrato = 6;
  static const int ManagerOrcamento = 7;
  static const int ManagerVenda = 8;
  static const int ManagerEmpresaFiscal = 9;
  static const int ManagerGrupoUsuario = 10;
  static const int ManagerCategoria = 11;
  static const int ManagerContaCorrente = 12;
  static const int ManagerRamoAtividade = 13;
  static const int ManagerFormaPagamento = 14;
  static const int ManagerUnidadeMedida = 15;
  static const int ManagerMarca = 16;
  static const int ManagerGrupo = 17;
  static const int ManagerCentroReceitaDespesa = 18;
  static const int ManagerTipoDocumento = 19;
  static const int ManagerPortador = 20;
  static const int ManagerModeloDocumento = 21;
  static const int ManagerDocumentoFiscal = 22;
  static const int ManagerRelatorioFaturamento = 23;
  static const int ManagerConfiguradorCobrancaBancaria = 24;
  static const int ManagerRelatorio = 25;
  static const int ManagerOrdemServico = 26;
  static const int ManagerRelatorioOrdemServico = 27;
  static const int ManagerResumo = 28;
  static const int ManagerDiretivaDeAcesso = 29;
  static const int ManagerFinanceiroPrevistoRealizado = 30;
  static const int ManagerFinanceiroResultadoDRE = 31;
  static const int ManagerFinanceiroContasaReceberePagar = 32;
  static const int ManagerFinanceiroHistoriocodeReceitaseDespesas = 33;
  static const int ManagerFinanceiroComparativodeMeses = 34;
  static const int ManagerFinanceiroContasemAtraso = 35;
  static const int ManagerVendasResumodeOrcamento = 36;
  static const int ManagerVendasResumodeVenda = 37;
  static const int ManagerVendasHistoricodeVenda = 38;
  static const int ManagerVendasContratosCancelados = 39;
  static const int ManagerGlobalTempodeCasa = 40;
  static const int ManagerGlobalClientesMapa = 41;
  static const int ManagerMobFinanceiroContasFinanceiras = 42;
  static const int ManagerMobFinanceiroTodasAsContas = 43;
  static const int ManagerMobFinanceiroContasAReceber = 44;
  static const int ManagerMobFinanceiroContasAPagar = 45;
  static const int ManagerMobFinaneiroDRE = 46;
  static const int ManagerMobFinanceiroHistorico = 47;
  static const int ManagerMobVendasOrcamentosFinalizados = 48;
  static const int ManagerMobVendasHistorico = 49;
  static const int ManagerMobVendasDiarias = 50;
  static const int ManagerMobVendasContratosCancelados = 51;
  static const int ManagerMobVendasOrcamentosPendentes = 52;
  static const int ManagerMobVendasComparativoDeVendas = 53;
  static const int ManagerPushSaldoConta = 54;
  static const int ManagerPushTotalAPagarDia = 55;
  static const int ManagerPushTotalAReceberDia = 56;
  static const int ManagerPushTotalVendas = 57;
  static const int ManagerVendasLucro = 58;
  static const int ManagerGlobalGaugeAcesso = 59;
  static const int ManagerGlobalGaugeMedida = 60;
  static const int ManagerAtendimento = 61;
  static const int ManagerDepartamentoCategoria = 62;
  static const int ManagerGrupoEmpresarial = 63;
  static const int ManagerCanalSolucao = 64;
  static const int ManagerPrioridadeAtendimento = 65;
  static const int ManagerTipoAtendimento = 66;
  static const int ManagerDepartamento = 67;
  static const int ManagerOrigemAtendimento = 68;
  static const int ManagerBaseConhecimento = 69;
  static const int ManagerInteracao = 70;
  static const int ManagerContratoBloquearDesbloquear = 71;
  static const int ManagerRastreador = 72;
  static const int ManagerVeiculo = 73;
  static const int ManagerOperacao = 74;
  static const int ManagerTipoOrdemDeServico = 75;
  static const int ManagerContratoCancelamento = 76;
  static const int ManagerMovimentacoesRecebimentos = 77;
  static const int ManagerMovimentacoesDespesasFixas = 78;
  static const int ManagerMovimentacoesDespesasVariaveis = 79;
  static const int ManagerMovimentacoesPessoas = 80;
  static const int ManagerMovimentacoesImpostos = 81;
  static const int ManagerMovimentacoesTransferencias = 82;
  static const int ManagerEntradaEstoque = 84;
  static const int ManagerSaidaEstoque = 85;
  static const int ManagerConfiguracaoProduto = 86;
  static const int ManagerMobOSAcessarTecnico = 87;
  static const int ManagerUsuarioPdv = 88;
  static const int ManagerEquipamentoVideo = 89;
  static const int ManagerContratoBloquearDesbloquearEquipamentosVideo = 90;
  static const int ManagerOficina = 91;
  static const int ManagerMobOSVisualizarMaterial = 92;
  static const int ManagerMobOSAdicionarMaterial = 93;
  static const int ManagerMobOSEditarMaterial = 94;
  static const int ManagerMobOSExcluirMaterial = 95;
  static const int ManagerMobOSVisualizarValorMaterial = 96;
  static const int ManagerRelatorioEstoque = 97;
  static const int ManagerGrupoMontagem = 98;
  static const int ManagerValorVendaOS = 99;
  static const int ManagerAllowEditDescontoContrato = 100;
  static const int ManagerMotivoCancelamento = 101;
  static const int ManagerFinanceiroFiltroAvancado = 102;
  static const int ManagerRelatorioVendaPDV = 103;
  static const int ManagerRegiao = 104;
  static const int ManagerGrupoEconomico = 105;
  static const int ManagerGerenciarDocumentoFiscal = 106;
  static const int ManagerDevolucao = 107;
  static const int ManagerOutrasSaidas = 108;
  static const int ManagerRelatorioAtendimento = 109;
  static const int ManagerContatoAtendimento = 110;
  static const int ManagerDadosPrincipaisContato = 111;
  static const int ManagerCheques = 112; // ok
  static const int ManagerEstoqueLocal = 113;
  static const int ManagerEstoqueTransferencia = 114;
  static const int ManagerGerenciamentoCartao = 115;
  static const int ManagerEtiquetasProduto = 116;
  static const int ManagerModeloEquipamento = 117;
  static const int ManagerGrupoContato = 118;
  static const int ManagerMovimentacaoBaixa = 119;
  static const int ManagerConfiguracaoMovimentacao = 120;
  static const int ManagerGerenciamentoComissao = 121;
  static const int ManagerRotinaJuros = 122;
  static const int ManagerConfiguracaoEstoque = 123;
  static const int ManagerConfiguracaoFaturamento = 124;
  static const int ManagerCodigoServico = 125;
  static const int ManagerCobrancaBancaria = 126;
  static const int ManagerImportarExportar = 127;
  static const int ManagerVisualizarTodasVendas = 128;
  static const int ManagerVisualizarTodosOrcamentos = 129;
  static const int ManagerVisualizarTodasOrdemServico = 130;
  static const int ManagerRelatorioComissao = 131;
  static const int ManagerRelatorioProduto = 132;
  static const int ManagerTransferenciaAcesso = 134;
  static const int ManagerCancelarConclusaoVenda = 135;
  static const int ManagerVisualizarLimiteCredito = 136;
  static const int ManagerNegociacao = 137;
  static const int CrmProspect = 138;
  static const int CrmProdutoConcorrente = 139;
  static const int CrmMotivosPerdaVenda = 140;
  static const int CrmOrigemProspect = 141;
  static const int ManagerWorkflow = 142;
  static const int ManagerAgenda = 143;
  static const int ManagerProblema = 144;
  static const int ManagerObservacaoProducao = 145;
  static const int ManagerMovimentacaoDistribuicao = 146;
  static const int ManagerMovimentacaoFinanceira = 147;
  static const int ManagerContatoRelatorio = 148;
  static const int ManagerImportarOfx = 149;
  static const int ManagerLog = 150;
  static const int ManagerMotivoInativacao = 151;
  static const int ManagerChequeConfigurador = 152;
  static const int ManagerEmpresaCompartilhamento = 153;
  static const int ManagerOrdemServicoConfigurador = 154;
  static const int ManagerProdutoEstrutura = 155;
  static const int ManagerConvenio = 156;
  static const int ManagerAlerta = 157;
  static const int ManagerUsuarioXEmpresaGrupoEmpresarial = 158;
  static const int ManagerAgendaVisualizarTodosEventos = 160;
  static const int CRMConfiguracaoCRM = 161;
  static const int ManagerMobReagendarOS = 162;
  static const int CrmHomeCRM = 163;
  static const int ManagerProdutoPrecosExcecoes = 164;
  static const int ManagerPercentualComissaoFinanceiraContrato = 165;
  static const int ManagerHome = 166;
  static const int ManagerDashboard = 167;
  static const int ManagerSubGrupo = 168;
  static const int ManagerDocumentoFiscalTransmissao = 169;
  static const int AdminDashboardAdmin = 170;
  static const int AdminControleAcesso = 171;
  static const int ManagerCondicaoPagamento = 172;
  static const int ManagerConfiguracaoAgenda = 173;
  static const int ManagerCamposAdicionais = 174;
  static const int CrmTelefonia = 175;
  static const int ManagerFormulario = 176;
  static const int CrmDiretivaAdminDashboard = 177;
  static const int ManagerImportar = 178;
  static const int CrmRelatorioCamposAdicionais = 179;
  static const int ManagerCustoEntradaSaida = 180;
  static const int ManagerFormularioXCompromisso = 181;
  static const int ManagerClonarTributacao = 182;
  static const int ManagerModeloPadrao = 183;
  static const int IManagerCondicaofaturamento = 184;
  static const int CrmConfiguracaoNotificacao = 185;
  static const int ManagerConfiguracaoContrato = 186;
  static const int IManagerIContrato = 187;
  static const int ManagerContratoRenovacao = 188;
  static const int ManagerVisualizarLucroPrejuizo = 189;
  static const int ManagerCidade = 190;
  static const int ManagerFeriado = 191;
  static const int CrmCadastroProspectForaCarteira = 192;
  static const int CrmGerenciamentoProspectForaCarteira = 193;
  static const int AdminHome = 194;
  static const int ManagerVisualizarSaldoContaCorrente = 195;
  static const int CrmInteracao = 196;
  static const int ManagerLogin = 197;
  static const int ManagerRelatorioRastreador = 198;
  static const int CrmFormulariosRealizadosPorOutrosUsuarios = 199;
  static const int ManagerRelatorioNumeroSerie = 200;
  static const int ManagerModeloEmailSMS = 201;
  static const int ManagerTest = 202;
  static const int CrmTagInteracao = 203;		
  static const int ManagerGerenciamentoCobranca = 204;
  static const int ManagerTabelaPreco = 205;
  static const int ManagerMobVisualizarSaldos = 206;
  static const int ManagerManifesto = 207;
  static const int ManagerViabilidadeOrcamento = 208;
  static const int ManagerMoBtnAlterarDataeValor = 209;
  static const int IManagerIOrcamento = 210;
  static const int ManagerConfiguracaoSistema = 211;
  static const int CrmPainelOrcamentos = 212;
  static const int CrmEmail = 213;
  static const int CrmProbabilidades = 214;
  static const int ManagerSintegra = 215;
  static const int ManagerGerarFinanceiroContratoOrcamento = 216;
  static const int CrmClassificacaoOportunidades = 217;
  static const int ManagerContatoEditarCamposFaturamento = 218;
  static const int ManagerContratoReajuste = 219;
  static const int ManagerContratoReajusteHistorico = 220;
  static const int CrmDashboard = 221;
  static const int ManagerLogEmailEnviados = 222;
}
