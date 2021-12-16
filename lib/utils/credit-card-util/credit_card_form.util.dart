import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:erp/models/cliente/cobranca-pagamento/cartao-editar.modelo.dart';
import 'package:erp/servicos/localizacao/localizacao.servico.dart';
import 'package:erp/servicos/localizacao/localizacao.widget.dart';
import 'package:erp/utils/constantes/mascaras.constante.dart';
import 'package:erp/utils/credit-card-util/credit_card_model.util.dart';
import 'package:erp/utils/credit-card-util/credit_card_widget.util.dart';
import 'package:erp/utils/date-picker.util.dart';
import 'package:intl/intl.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key key,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    @required this.onCreditCardModelChange,
    this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
    this.cardNumberLabel = 'Card number',
    this.expiredDateLabel = 'Expired Date',
    this.expiredDateHint = 'MM/YY',
    this.cvvLabel = 'CVV',
    this.cardHolderLabel = 'Card Holder',
    this.cartaoCreditoEditar,
    this.dataNascimento
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color cursorColor;

  final String cardNumberLabel;
  final String expiredDateLabel;
  final String expiredDateHint;
  final String cvvLabel;
  final String cardHolderLabel;
  final CartaoCreditoEditar cartaoCreditoEditar;
  final DateTime dataNascimento;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;
  DateTime dataNascimento = DateTime.now();

  LocalizacaoServico _locale = new LocalizacaoServico();

  final formKey = GlobalKey<FormState>();
  bool _autovalidate = false;

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController = MaskedTextController(mask: MascarasConstantes.CARTAO_CREDITO_NUMERO);
  final MaskedTextController _expiryDateController = MaskedTextController(mask: MascarasConstantes.CARTAO_CREDITO_VALIDADE);
  final TextEditingController _cardHolderNameController = TextEditingController();
  final MaskedTextController _cvvCodeController = MaskedTextController(mask: MascarasConstantes.CARTAO_CREDITO_CVV);
  TextEditingController _dataNascimentoController = new TextEditingController();

  FocusNode cvvFocusNode = FocusNode();
  FocusNode _focusDataNascimento = new FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';
    dataNascimento = widget.dataNascimento ?? '';

    creditCardModel = CreditCardModel(
        cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused, dataNascimento);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    _locale.iniciaLocalizacao(context);

    onCreditCardModelChange = widget.onCreditCardModelChange;

    if (widget.cartaoCreditoEditar != null) {
      if (cardNumber.isNotEmpty) {
        setState(() {
          String reformatacao = '';
          reformatacao = cardNumber.replaceAll('•', '*');
          reformatacao = reformatacao.replaceFirst('*', '');
          reformatacao = reformatacao.replaceFirst('*', '');
          reformatacao = reformatacao.replaceFirst('*', '');
          _cardNumberController.updateText(reformatacao);
        });
      }
      if (expiryDate.isNotEmpty) {
        setState(() {
          _expiryDateController.updateText(expiryDate);
        });
      }
      if (cardHolderName.isNotEmpty) {
        setState(() {
          _cardHolderNameController.text = cardHolderName;
        });
      }
      if (cvvCode.isNotEmpty) {
        setState(() {
          _cvvCodeController.updateText(cvvCode);
        });
      }
    }

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _dataNascimentoController.text = DateFormat.yMd().format(DateTime.parse(dataNascimento.toString())) ?? '';

    _cardNumberController.addListener(() {
      setState(() {
        if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) {
          _cardNumberController.updateMask(MascarasConstantes.CARTAO_CREDITO_NUMERO_AMEX);
        }
        else {
          _cardNumberController.updateMask(MascarasConstantes.CARTAO_CREDITO_NUMERO);
        }
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _dataNascimentoController.addListener(() {
      setState(() {
        creditCardModel.dataNascimento = dataNascimento;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return LocalizacaoWidget(
      child: StreamBuilder(
        builder: (context, snapshot) {
          return Theme(
            data: ThemeData(
              primaryColor: themeColor.withOpacity(0.8),
              primaryColorDark: themeColor,
            ),
            child: Form(
              key: formKey,
              autovalidate: _autovalidate,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: TextFormField(
                      controller: _cardNumberController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      enabled: widget.cartaoCreditoEditar.id != null ? false : true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.cardNumberLabel,
                        hintText: 'xxxx xxxx xxxx xxxx',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (input) {
                        if (input.isEmpty || input.length < 19) {
                          return _locale.locale['NumeroCartaoObrigatorio'];
                        }
                        else {
                          return null;
                        }
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      controller: _cardHolderNameController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.cardHolderLabel,
                      ),
                      validator: (input) {
                        if (input.isEmpty || input.length < 3) {
                          return _locale.locale['TitularObrigatorio'];
                        }
                        else {
                          return null;
                        }
                      },
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      controller: _dataNascimentoController,
                      focusNode: _focusDataNascimento,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "${_locale.locale['DataNascimento']}",
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                      onTap: () {_selecionaDataNascimento(context);},
                      validator: (input) {
                        if (input.isEmpty) {
                          return _locale.locale['PreenchaData'];
                        }
                        else {
                          return null;
                        }
                      },
                      textInputAction: TextInputAction.next,
                      // onSaved: (input) => _observacao = Validators().fieldFilledValidator(input, _observacao),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      focusNode: cvvFocusNode,
                      controller: _cvvCodeController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      validator: (input) {
                        if (input.isEmpty || input.length < 3) {
                          return _locale.locale['CVVObrigatorio'];
                        }
                        else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: widget.cvvLabel,
                        hintText: 'XXXX',
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onChanged: (String text) {
                        setState(() {
                          cvvCode = text;
                        });
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                    child: TextFormField(
                      controller: _expiryDateController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      validator: (input) {
                        if (input.isEmpty || input.length < 5) {
                          return _locale.locale['DataValidadeObrigatorio'];
                        }
                        else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: widget.expiredDateLabel,
                          hintText: widget.expiredDateHint),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Future<Null> _selecionaDataNascimento(BuildContext context) async {
    final DateTime dataSelecionada = await DatePickerUtil().datePicker(
      context: context,
      dataInicial: dataNascimento
    );

    if (dataSelecionada != null && dataSelecionada != dataNascimento) {
      setState(() {
        dataNascimento = dataSelecionada;
        _dataNascimentoController.text = DateFormat.yMd().format(DateTime.parse(dataNascimento.toString()));
      });
    }
  }

  submit() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
    }
    else {
      setState(() {
        _autovalidate = true;
      });
      return null;
    }
  }

  // CreditCardModel submit() {
  //   if(formKey.currentState.validate()) {
  //     formKey.currentState.save();

  //     CreditCardModel cartao = new CreditCardModel(cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);

  //     return cartao;
  //   }
  //   else {
  //     setState(() {
  //       _autovalidate = true;
  //     });
  //     return null;
  //   }

  // }
}
