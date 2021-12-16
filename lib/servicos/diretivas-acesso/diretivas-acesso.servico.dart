import 'package:erp/models/diretivas-acesso/diretivas-acesso-disponiveis.modelo.dart';
import 'package:erp/utils/constantes/shared_preferences.constante.dart';
import 'package:erp/utils/constantes/sistema.constante.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DiretivasAcessosService {
  List<int> _diretivasAcesso = new List<int>();
  DiretivasAcessoDisponiveis diretivasDisponiveis = new DiretivasAcessoDisponiveis();

  Future<DiretivasAcessoDisponiveis> iniciaDiretivas() async {
    List<String> diretivasAcessoShared = new List<String>();
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    diretivasAcessoShared = _prefs.getStringList(SharedPreference.DIRETIVAS_ACESSO);
    _diretivasAcesso = diretivasAcessoShared.map((e) => int.parse(e)).toList();
    await _getDiretivasDisponiveis();
    return diretivasDisponiveis;
  }

  bool _verificaAcesso(int acesso) {
    if (_diretivasAcesso.indexOf(acesso) != -1) {
      return true;
    }
    else {
      return false;
    }
  }

  Future<dynamic> _getDiretivasDisponiveis() async {
    FinanceiroAcessos _financeiro() {
      FinanceiroAcessos financeiroAcessos = new FinanceiroAcessos();

      bool possuiContasFinanceiras() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasFinanceiras));
      }

      bool possuiTodasAsContas() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroTodasAsContas));
      }

      bool possuiContasAPagar() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasAPagar));
      }

      bool possuiContasAReceber() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasAReceber));
      }

      bool possuiDRE() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroDRE));
      }

      bool possuiHistorico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroHistorico));
      }

      // bool possuiFinanceiro() {
      //   return (
      //     _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasFinanceiras)
      //     || _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroTodasAsContas)
      //     || _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasAPagar)
      //     || _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroContasAReceber)
      //     || _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroDRE)
      //     || _verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobFinanceiroHistorico)
      //   );
      // }

      bool possuiFinanceiro() {
        return (
          possuiContasFinanceiras()
          || possuiTodasAsContas()
          || possuiContasAPagar()
          || possuiContasAReceber()
          || possuiDRE()
          || possuiHistorico()
        );
      }

      financeiroAcessos.possuiContasFinanceiras = possuiContasFinanceiras();
      financeiroAcessos.possuiTodasAsContas = possuiTodasAsContas();
      financeiroAcessos.possuiContasAPagar = possuiContasAPagar();
      financeiroAcessos.possuiContasAReceber = possuiContasAReceber();
      financeiroAcessos.possuiDRE = possuiDRE();
      financeiroAcessos.possuiHistorico = possuiHistorico();
      financeiroAcessos.possuiFinanceiro = possuiFinanceiro();

      return financeiroAcessos;
    }

    VendaAcessos _vendas() {
      VendaAcessos vendaAcessos = new VendaAcessos();

      bool possuiOrcamentosFinalizados() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVendasOrcamentosFinalizados));
      }

      bool possuiVendasDiarias() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVendasDiarias));
      }

      bool possuiContratosCancelados() {
        // return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVendasContratosCancelados));
        return false;
      }

      bool possuiOrcamentosPendentes() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVendasOrcamentosPendentes));
      }

      bool possuiComparativoDeVendas() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVendasComparativoDeVendas));
      }

      bool possuiLiberacaoTotalVendasLabel() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVisualizarSaldos));
      }

      bool possuiVendas() {
        return (
          possuiOrcamentosFinalizados()
          || possuiVendasDiarias()
          || possuiContratosCancelados()
          || possuiOrcamentosPendentes()
          || possuiComparativoDeVendas()
        );
      }

      vendaAcessos.possuiOrcamentosFinalizados = possuiOrcamentosFinalizados();
      vendaAcessos.possuiVendasDiarias = possuiVendasDiarias();
      vendaAcessos.possuiContratosCancelados = possuiContratosCancelados();
      vendaAcessos.possuiOrcamentosPendentes = possuiOrcamentosPendentes();
      vendaAcessos.possuiComparativoDeVendas = possuiComparativoDeVendas();
      vendaAcessos.possuiLiberacaoTotalVendasLabel = possuiLiberacaoTotalVendasLabel();
      vendaAcessos.possuiVendas = possuiVendas();

      return vendaAcessos;
    }

    OrdemServicoAcessos _ordemServico() {
      OrdemServicoAcessos ordemServicoAcessos = new OrdemServicoAcessos();

      bool possuiOrdemDeServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSAcessarTecnico));
      }

      bool possuiEditarOrdemDeServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSAcessarTecnico));
      }

      bool possuiAdicionarMaterialServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSAdicionarMaterial));
      }

      bool possuiEditarMaterialServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSEditarMaterial));
      }

      bool possuiDeletarMaterialServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSExcluirMaterial));
      }

      bool possuiVisualizarMaterialServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSVisualizarMaterial));
      }

      bool possuiVisualizarValorMaterialServico() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobOSVisualizarValorMaterial));
      }

      bool possuiVisualizarReagendar() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobReagendarOS));
      }

      ordemServicoAcessos.possuiOrdemDeServico = possuiOrdemDeServico();
      ordemServicoAcessos.possuiEditarOrdemDeServico = possuiEditarOrdemDeServico();
      ordemServicoAcessos.possuiAdicionarMaterialServico = possuiAdicionarMaterialServico();
      ordemServicoAcessos.possuiEditarMaterialServico = possuiEditarMaterialServico();
      ordemServicoAcessos.possuiDeletarMaterialServico = possuiDeletarMaterialServico();
      ordemServicoAcessos.possuiVisualizarMaterialServico = possuiVisualizarMaterialServico();
      ordemServicoAcessos.possuiVisualizarValorMaterialServico = possuiVisualizarValorMaterialServico();
      ordemServicoAcessos.possuiVisualizarReagendar = possuiVisualizarReagendar();

      return ordemServicoAcessos;
    }

    ClienteAcessos _cliente() {
      ClienteAcessos clienteAcessos = new ClienteAcessos();

      bool possuiClientes() {
        return (_verificaAcesso(DiretivasAcessoMobileConstantes.ManagerMobVisualizarClientes));
      }

      clienteAcessos.possuiClientes = possuiClientes();

      return clienteAcessos;
    }

    diretivasDisponiveis.financeiro = _financeiro();
    diretivasDisponiveis.venda = _vendas();
    diretivasDisponiveis.ordemServico = _ordemServico();
    diretivasDisponiveis.cliente = _cliente();
  }
}
