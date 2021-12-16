
import 'dart:convert';

import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:erp/compartilhados/componentes/app-bar/save-button/save-button.componente.dart';
import 'package:erp/compartilhados/componentes/button/button.componente.dart';
import 'package:erp/models/cliente/cobranca-pagamento/cartao-editar.modelo.dart';
import 'package:erp/servicos/cliente/cliente.servicos.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/assets.constante.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/credit-card-util/credit_card_form.util.dart';
import 'package:erp/utils/credit-card-util/credit_card_model.util.dart';
import 'package:erp/utils/credit-card-util/credit_card_type_detector.util.dart';
import 'package:erp/utils/credit-card-util/credit_card_widget.util.dart';
import 'package:provider/provider.dart';

class CartaoCadastroTela extends StatefulWidget {
  final CartaoCreditoEditar cartao;
  final int parceiroId;
  CartaoCadastroTela({this.cartao, this.parceiroId});

  @override
  _CartaoCadastroTelaState createState() => _CartaoCadastroTelaState();
}

class _CartaoCadastroTelaState extends State<CartaoCadastroTela> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  DateTime dataNascimento = DateTime.now();

  CreditCardType bandeira;
  String bandeiraString;
  int bandeiraInt;

  LocalizacaoServico _locale = new LocalizacaoServico();
  CartaoCreditoEditar _cartaoEditar = new CartaoCreditoEditar();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  CreditCardForm _formCartao;

  CreditCardModel creditCardModel;

  @override
  void initState() { 
    super.initState();
    _locale.iniciaLocalizacao(context);

    if(widget.cartao != null) {
      String anoNovo = '';
      _cartaoEditar = widget.cartao;
      cardNumber = _cartaoEditar.numero;
      if (_cartaoEditar.validadeAno.length > 2) {
        anoNovo = _cartaoEditar.validadeAno.replaceAll(' ', '');
        anoNovo = anoNovo.substring(2);
      }
      else {
        anoNovo = _cartaoEditar.validadeAno;
      }
      dataNascimento = DateTime.parse(_cartaoEditar.dataNascimento);
      expiryDate = _cartaoEditar.validadeMes + '/' + anoNovo;
      cardHolderName = _cartaoEditar.titular;
      cvvCode = _cartaoEditar.codigoSeguranca;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;OfflineMessageWidget();
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              actions: <Widget>[
                SaveButtonComponente(
                  funcao: () async {
                    if (_submit() == true) {
                      if(await _salvar() == true) {
                        Navigator.pop(context);
                      }
                    }
                  },
                )
              ],
              title: Text(
                widget.cartao == null
                  ? "${_locale.locale['CadastroCartao']}"
                  : "${_locale.locale['EditarCartao']}"
              ),
            ),
            body: CustomOfflineWidget(
              child: Column(
                children: <Widget>[
                  CreditCardWidget(
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    showBackView: isCvvFocused,
                    height: 200,
                    showImage: false,
                    cardHolderPlaceholder: _locale.locale['Titular'],
                    expiryPlaceholder: _locale.locale['Validade'],
                    expiryDatePlaceholder: _locale.locale['MMAA'],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _formCartao = new CreditCardForm(
                        cartaoCreditoEditar: _cartaoEditar,
                        cardNumber: cardNumber,
                        cardHolderName: cardHolderName,
                        cvvCode: cvvCode,
                        expiryDate: expiryDate,
                        dataNascimento: dataNascimento,
                        onCreditCardModelChange: onCreditCardModelChange,
                        cardNumberLabel: _locale.locale['NumeroCartao'],
                        cardHolderLabel: _locale.locale['TitularCartao'],
                        expiredDateHint: _locale.locale['MMAA'],
                        expiredDateLabel: _locale.locale['DataValidade'],
                      ),
                    )
                  ),
                  ButtonComponente(
                    funcao: () async {
                      if (_submit() == true) {
                        if(await _salvar() == true) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    ladoIcone: 'Esquerdo',
                    imagemCaminho: AssetsIconApp.Add,
                    somenteTexto: true,
                    somenteIcone: false,
                    texto: _locale.locale['Salvar'],
                    backgroundColor: Colors.blue,
                    textColor: Colors.white
                  )
                ],
              ),
            ),
            bottomNavigationBar: _isOnline ? null : OfflineMessageWidget(),
          );
        }
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      dataNascimento = creditCardModel.dataNascimento;
    });
  }

  bool _submit() {
    if (cardNumber.isEmpty || cardNumber.length < 7) {
      _showSnackBar(_locale.locale['NumeroCartaoObrigatorio']);
      return false;
    }
    else
    if (expiryDate.isEmpty || expiryDate.length < MascarasConstantes.CARTAO_CREDITO_VALIDADE.length) {
      _showSnackBar(_locale.locale['DataValidadeObrigatorio']);
      return false;
    }
    else
    if (cvvCode.isEmpty || cvvCode.length < MascarasConstantes.CARTAO_CREDITO_CVV.length - 1) {
      _showSnackBar(_locale.locale['CVVObrigatorio']);
      return false;
    }
    else
    if (cardHolderName.isEmpty) {
      _showSnackBar(_locale.locale['TitularObrigatorio']);
      return false;
    }
    else {
      List<String> validadeSeparacao = expiryDate.split('/');
      _cartaoEditar.titular = cardHolderName;
      _cartaoEditar.parceiroId = widget.parceiroId;
      _cartaoEditar.validadeMes = validadeSeparacao[0];
      _cartaoEditar.validadeAno = '20' + validadeSeparacao[1];
      _cartaoEditar.codigoSeguranca = cvvCode;
      _cartaoEditar.dataNascimento = dataNascimento.toString() ?? '';


        bandeira = detectCCType(cardNumber.substring(0, 4));
        // bandeira = detectCCType(cardNumber.substring(0, 6));
        switch (bandeira) {
          case CreditCardType.visa:
            _cartaoEditar.bandeira = 0;
            // bandeiraInt = 0;
            break;
          case CreditCardType.mastercard:
            _cartaoEditar.bandeira = 1;
            // bandeiraInt = 1;
            break;
          case CreditCardType.amex:
            _cartaoEditar.bandeira = 2;
            // bandeiraInt = 2;
            break;
          case CreditCardType.elo:
            _cartaoEditar.bandeira = 3;
            // bandeiraInt = 3;
            break;
          case CreditCardType.aura:
            _cartaoEditar.bandeira = 4;
            // bandeiraInt = 4;
            break;
          case CreditCardType.jcb:
            _cartaoEditar.bandeira = 5;
            // bandeiraInt = 5;
            break;
          case CreditCardType.dinersclub:
            _cartaoEditar.bandeira = 6;
            // bandeiraInt = 6;
            break;
          case CreditCardType.discover:
            _cartaoEditar.bandeira = 7;
            // bandeiraInt = 7;
            break;
          case CreditCardType.hipercard:
            _cartaoEditar.bandeira = 8;
            // bandeiraInt = 8;
            break;
          default:
            bandeiraInt = -1;
            break;
        }

      if (widget.cartao == null) {
        _cartaoEditar.numero = cardNumber;
      }


      print(_cartaoEditar.toJson());

      return true;
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(text)));
  }

  Future<bool> _salvar() async {
    // Tratar Cadastro Clientes
    bool resultado;
    if (_cartaoEditar.id == null) {
      String cartaoJson = json.encode(_cartaoEditar.novoCartaoJson());
      Response request = await ClienteService().cobrancaPagamento.adicionarCartao(cartao: cartaoJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    } else {
      String clienteJson = json.encode(_cartaoEditar.cartaoEditadoJson());
      Response request = await ClienteService().cobrancaPagamento.editarCartao(cartao: clienteJson, context: context);
      if (request.statusCode == 200) resultado = true;
      else resultado = false;
      return resultado;
    }
  }
}
