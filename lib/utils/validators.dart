class Validators {
  cpfValidator(String cpf) {
    // strCPF = strCPF.replace(/\D/g, "");
    cpf = cpf.replaceAll("-", "");
    cpf = cpf.replaceAll(".", "");

    int soma = 0;
    int resto = 0;
    if (cpf == "00000000000" || cpf == "11111111111" || cpf == "22222222222" || cpf == "33333333333" || cpf == "44444444444" || cpf == "55555555555" || cpf == "66666666666" || cpf == "77777777777" || cpf == "88888888888" || cpf == "99999999999") return false;

    if (cpf.length != 11) return false;

    for (int i = 1; i <= 9; i++) {
      soma = soma + int.parse(cpf.substring(i - 1, i)) * (11 - i);
    }
    resto = (soma * 10) % 11;

    if ((resto == 10) || (resto == 11)) resto = 0;
    if (resto != int.parse(cpf.substring(9, 10))) return false;

    soma = 0;
    for (int i = 1; i <= 10; i++) soma = soma + int.parse(cpf.substring(i - 1, i)) * (12 - i);
    resto = (soma * 10) % 11;

    if ((resto == 10) || (resto == 11)) resto = 0;
    if (resto != int.parse(cpf.substring(10, 11))) return false;
    return true;
  }

  bool cnpjValidator(String cnpj) {
    // cnpj = cnpj.replace(/[^\d]+/g, '');
    cnpj = cnpj.replaceAll(".", '');
    cnpj = cnpj.replaceAll("-", '');
    cnpj = cnpj.replaceAll("/", '');

    if (cnpj == '') return false;

    if (cnpj.length != 14) return false;

    if (cnpj == "00000000000000" || cnpj == "11111111111111" || cnpj == "22222222222222" || cnpj == "33333333333333" || cnpj == "44444444444444" || cnpj == "55555555555555" || cnpj == "66666666666666" || cnpj == "77777777777777" || cnpj == "88888888888888" || cnpj == "99999999999999") return false;

    // Valida DVs
    int tamanho = cnpj.length - 2;
    String numeros = cnpj.substring(0, tamanho);
    String digitos = cnpj.substring(tamanho);
    int soma = 0;
    int pos = tamanho - 7;
    for (int i = tamanho; i >= 1; i--) {
      soma += int.parse(numeros[tamanho - i]) * pos--;
      if (pos < 2) pos = 9;
    }
    int resultado = (soma % 11 < 2) ? 0 : 11 - soma % 11;
    if (resultado != int.parse(digitos[0])) return false;

    tamanho = tamanho + 1;
    numeros = cnpj.substring(0, tamanho);
    soma = 0;
    pos = tamanho - 7;
    for (int i = tamanho; i >= 1; i--) {
      soma += int.parse(numeros[tamanho - i]) * pos--;
      if (pos < 2) pos = 9;
    }
    resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
    if (resultado != int.parse(digitos[1])) return false;

    return true;
  }

  emailValidator(String email) {
    RegExp re = new RegExp(r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return(re.hasMatch(email));
  }

  fieldFilledValidator(String input, String propriedade) {
    if(input.isNotEmpty) {
      return input;
    }
    if(propriedade != null && input.isEmpty) {
      return null;
    }
  }

  fieldValidatorObrigatorio(
    {
      /// A váriável a ser recebida
      String valor,
      /// A mensagem a ser exibida se o campo estiver incompleto
      String mensagemIncompleto,
      /// A mensagem a ser exibida se o campo estiver completo porém inválido
      String mensagemCompletoInvalido,
    }
  ) {}

  fieldValidatorNaoObrigatorio(
    {
      /// A váriável a ser recebida
      String valor,
      /// A mensagem a ser exibida se o campo estiver incompleto
      String mensagemIncompleto,
      /// A mensagem a ser exibida se o campo estiver completo porém inválido
      String mensagemCompletoInvalido,
    }
  ) {}
}
