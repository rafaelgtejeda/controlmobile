import 'package:flutter/widgets.dart';
import 'package:erp/utils/constantes/request.constante.dart';

class InfiniteScrollUtil {
  String pesquisaInfinite = '';
  bool pesquisaAlterada = false;
  int skipCount = 0;
  List<dynamic> novaLista = new List<dynamic>();
  bool infiniteScrollCompleto = false;

  iniciaValores() {
    novaLista.clear();
    skipCount = 0;
    infiniteScrollCompleto = false;
  }

  verificaPesquisaAlterada() {
    pesquisaAlterada = true;
    skipCount = 0;
    infiniteScrollCompleto = false;
  }

  verificaPermanencia({@required String pesquisa}) {
    skipCount++;
    novaLista = [];

    if(pesquisaInfinite != pesquisa) {
      pesquisaAlterada = true;
      pesquisaInfinite = pesquisa;
    }
    else {
      pesquisaAlterada = false;
    }
  }

  completaInfiniteScroll() {
    if (novaLista.length < Request.TAKE) {
      infiniteScrollCompleto = true;
    }
  }

  restart() {
    infiniteScrollCompleto = false;
    skipCount = 0;
  }
}
