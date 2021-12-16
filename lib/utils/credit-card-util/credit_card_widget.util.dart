import 'dart:math';

import 'package:flutter/material.dart';
import 'package:erp/utils/constantes/assets.constante.dart';

class CreditCardWidget extends StatefulWidget {
  const CreditCardWidget({
    Key key,
    @required this.cardNumber,
    @required this.expiryDate,
    @required this.cardHolderName,
    @required this.cvvCode,
    @required this.showBackView,
    this.animationDuration = const Duration(milliseconds: 500),
    this.height,
    this.width,
    this.textStyle,
    this.cardBgColor = const Color(0xff1b447b),
    this.showImage = false,
    this.cardHolderPlaceholder = 'CARD HOLDER',
    this.expiryPlaceholder = 'Expiry',
    this.expiryDatePlaceholder = 'MM/YY',
  })  : assert(cardNumber != null),
        assert(showBackView != null),
        super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final TextStyle textStyle;
  final Color cardBgColor;
  final bool showBackView;
  final Duration animationDuration;
  final double height;
  final double width;
  
  final bool showImage;
  final String cardHolderPlaceholder;
  final String expiryPlaceholder;
  final String expiryDatePlaceholder;

  @override
  _CreditCardWidgetState createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> _frontRotation;
  Animation<double> _backRotation;
  Gradient backgroundGradientColor;

  bool isAmex = false;

  @override
  void initState() {
    super.initState();

    ///initialize the animation controller
    controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    backgroundGradientColor = LinearGradient(
      // Where the linear gradient begins and ends
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      // Add one stop for each color. Stops should increase from 0 to 1
      stops: const <double>[0.1, 0.4, 0.7, 0.9],
      colors: <Color>[
        widget.cardBgColor.withOpacity(0.5),
        widget.cardBgColor.withOpacity(0.45),
        widget.cardBgColor.withOpacity(0.4),
        widget.cardBgColor.withOpacity(0.3),
      ],
    );

    ///Initialize the Front to back rotation tween sequence.
    _frontRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: pi / 2)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
      ],
    ).animate(controller);

    _backRotation = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(pi / 2),
          weight: 50.0,
        ),
        TweenSequenceItem<double>(
          tween: Tween<double>(begin: -pi / 2, end: 0.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50.0,
        ),
      ],
    ).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final Orientation orientation = MediaQuery.of(context).orientation;

    ///
    /// If uer adds CVV then toggle the card from front to back..
    /// controller forward starts animation and shows back layout.
    /// controller reverse starts animation and shows front layout.
    ///
    if (widget.showBackView) {
      controller.forward();
    } else {
      controller.reverse();
    }

    return Stack(
      children: <Widget>[
        AnimationCard(
          animation: _frontRotation,
          child: buildFrontContainer(width, height, context, orientation),
        ),
        AnimationCard(
          animation: _backRotation,
          child: buildBackContainer(width, height, context, orientation),
        ),
      ],
    );
  }

  ///
  /// Builds a back container containing cvv
  ///
  Container buildBackContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    final TextStyle defaultTextStyle = Theme.of(context).textTheme.title.merge(
          TextStyle(
            color: Colors.black,
            fontFamily: 'halter',
            fontSize: 16,
            package: 'credit_card',
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 0),
            blurRadius: 24,
          ),
        ],
        gradient: backgroundGradientColor,
      ),
      margin: const EdgeInsets.all(16),
      width: widget.width ?? width,
      height: widget.height ??
          (orientation == Orientation.portrait ? height / 4 : height / 2),
      child: Stack(
        children: <Widget>[
          widget.showImage
            ? getRandomBackground(widget.height, widget.width)
            : Container(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 0),
                  blurRadius: 24,
                )
              ],
              gradient: backgroundGradientColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    height: 48,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 9,
                          child: Container(
                            height: 40,
                            color: const Color(0xffdddddd),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(
                                widget.cvvCode.isEmpty
                                    ? isAmex ? 'XXXX' : 'XXX'
                                    : isAmex
                                        ? widget.cvvCode.length > 4
                                            ? widget.cvvCode.substring(0, 4)
                                            : widget.cvvCode
                                        : widget.cvvCode.length > 3
                                            ? widget.cvvCode.substring(0, 3)
                                            : widget.cvvCode,
                                maxLines: 1,
                                style: widget.textStyle ?? defaultTextStyle,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16),
                      child: getCardTypeIcon(widget.cardNumber),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// Builds a front container containing
  /// Card number, Exp. year and Card holder name
  ///
  Container buildFrontContainer(
    double width,
    double height,
    BuildContext context,
    Orientation orientation,
  ) {
    final TextStyle defaultTextStyle = Theme.of(context).textTheme.title.merge(
          TextStyle(
            color: Colors.white,
            fontFamily: 'halter',
            fontSize: 16,
            package: 'credit_card',
          ),
        );

    return Container(
      margin: const EdgeInsets.all(16),
      width: widget.width ?? width,
      height: widget.height ??
          (orientation == Orientation.portrait ? height / 4 : height / 2),
      child: Stack(
        children: <Widget>[
          widget.showImage
            ? getRandomBackground(widget.height, widget.width)
            : Container(),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 0),
                  blurRadius: 24,
                )
              ],
              gradient: backgroundGradientColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 16,
                ),
                getChipImage(),
                Container(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    widget.cardNumber.isEmpty || widget.cardNumber == null
                    ? 'XXXX XXXX XXXX XXXX'
                    : widget.cardNumber,
                    style: widget.textStyle ?? defaultTextStyle,
                  ),
                ),
                Container(
                  height: 8,
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.expiryPlaceholder,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'halter',
                            fontSize: 9,
                            package: 'credit_card',
                          ),
                        ),
                        Container(
                          width: 16,
                        ),
                        Text(
                          widget.expiryDate.isEmpty || widget.expiryDate == null
                              ? widget.expiryDatePlaceholder
                              : widget.expiryDate,
                          style: widget.textStyle ?? defaultTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Text(
                      widget.cardHolderName.isEmpty ||
                              widget.cardHolderName == null
                          ? widget.cardHolderPlaceholder
                          : widget.cardHolderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'halter',
                        fontSize: 14,
                        package: 'credit_card',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              child: getCardTypeIcon(widget.cardNumber),
            ),
          ),
        ],
      ),
    );
  }

  /// Credit Card prefix patterns as of March 2019
  /// A [List<String>] represents a range.
  /// i.e. ['51', '55'] represents the range of cards starting with '51' to those starting with '55'
  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
    CardType.dinersclub: {
      ['300', '305'],
      ['36'],
      ['38'],
      ['39'],
    },
    CardType.jcb: {
      ['3528', '3589'],
      ['2131'],
      ['1800'],
    },
    CardType.aura: {
      ['50'],
    },
    // CardType.unionpay: {
    //   ['620'],
    //   ['624', '626'],
    //   ['62100', '62182'],
    //   ['62184', '62187'],
    //   ['62185', '62197'],
    //   ['62200', '62205'],
    //   ['622010', '622999'],
    //   ['622018'],
    //   ['622019', '622999'],
    //   ['62207', '62209'],
    //   ['622126', '622925'],
    //   ['623', '626'],
    //   ['6270'],
    //   ['6272'],
    //   ['6276'],
    //   ['627700', '627779'],
    //   ['627781', '627799'],
    //   ['6282', '6289'],
    //   ['6291'],
    //   ['6292'],
    //   ['810'],
    //   ['8110', '8131'],
    //   ['8132', '8151'],
    //   ['8152', '8163'],
    //   ['8164', '8171'],
    // },
    // CardType.maestro: {
    //   ['493698'],
    //   ['500000', '506698'],
    //   ['506779', '508999'],
    //   ['56', '59'],
    //   ['63'],
    //   ['67'],
    //   //['6'], Not 100% about this one
    // },
    CardType.elo: {
      ['401178'],
      ['401179'],
      ['438935'],
      ['457631'],
      ['457632'],
      ['431274'],
      ['451416'],
      ['457393'],
      ['504175'],
      ['506699', '506778'],
      ['509000', '509999'],
      ['627780'],
      ['636297'],
      ['636368'],
      ['650031', '650033'],
      ['650035', '650051'],
      ['650405', '650439'],
      ['650485', '650538'],
      ['650541', '650598'],
      ['650700', '650718'],
      ['650720', '650727'],
      ['650901', '650978'],
      ['651652', '651679'],
      ['655000', '655019'],
      ['655021', '655058'],
    },
    // CardType.mir: {
    //   ['2200', '2204'],
    // },
    // CardType.hiper: {
    //   ['637095'],
    //   ['637568'],
    //   ['637599'],
    //   ['637609'],
    //   ['637612'],
    // },
    CardType.hipercard: {
      ['606282'],
    }
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          // String ccPatternStr = cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          String ccPatternStr;
          ccPatternStr = cardNumber.replaceAll(' ', '');
          ccPatternStr = ccPatternStr.replaceAll('•', '');
          ccPatternStr = ccPatternStr.replaceAll('-', '');
          ccPatternStr = ccPatternStr.replaceAll('/', '');
          ccPatternStr = ccPatternStr.replaceAll('.', '');
          ccPatternStr = ccPatternStr.replaceAll('*', '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  // This method returns the icon for the visa card type if found
  // else will return the empty container
  Widget getCardTypeIcon(String cardNumber) {
    Widget icon;
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        icon = Image.asset(
          AssetsCreditCards.VISA,
          // 'icons/visa.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.americanExpress:
        icon = Image.asset(
          AssetsCreditCards.AMERICAN_EXPRESS,
          // 'icons/amex.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = true;
        break;

      case CardType.mastercard:
        icon = Image.asset(
          AssetsCreditCards.MASTER,
          // 'icons/master.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.discover:
        icon = Image.asset(
          AssetsCreditCards.DISCOVER,
          // 'icons/discover.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.dinersclub:
        icon = Image.asset(
          AssetsCreditCards.DINERS,
          // 'icons/diners.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.elo:
        icon = Image.asset(
          AssetsCreditCards.ELO,
          // 'icons/elo.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.jcb:
        icon = Image.asset(
          AssetsCreditCards.JCB,
          // 'icons/jcb.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.aura:
        icon = Image.asset(
          AssetsCreditCards.AURA,
          // 'icons/jcb.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.hipercard:
        icon = Image.asset(
          AssetsCreditCards.HIPERCARD,
          // 'icons/hipercard.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.hiper:
        icon = Image.asset(
          AssetsCreditCards.HIPER,
          // 'icons/hiper.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.mir:
        icon = Image.asset(
          AssetsCreditCards.MIR,
          // 'icons/mir.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.maestro:
        icon = Image.asset(
          AssetsCreditCards.MAESTRO,
          // 'icons/maestro.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      case CardType.unionpay:
        icon = Image.asset(
          AssetsCreditCards.UNIONPAY,
          // 'icons/unionpay.png',
          height: 64,
          width: 64,
          // package: 'credit_card',
        );
        isAmex = false;
        break;

      default:
        icon = Container(
          height: 64,
          width: 64,
        );
        isAmex = false;
        break;
    }

    return icon;
  }
}

class AnimationCard extends StatelessWidget {
  const AnimationCard({
    @required this.child,
    @required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        final Matrix4 transform = Matrix4.identity();
        transform.setEntry(3, 2, 0.001);
        transform.rotateY(animation.value);
        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class MaskedTextController extends TextEditingController {
  MaskedTextController({String text, this.mask, Map<String, RegExp> translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (this.beforeChange(previous, this.text)) {
        updateText(this.text);
        this.afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String mask;

  Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text != null) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection =
        TextSelection.fromPosition(TextPosition(offset: (text ?? '').length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
      final String valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar].hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

enum CardType {
  otherBrand,
  mastercard,
  visa,
  americanExpress,
  discover,
  dinersclub,
  jcb,
  aura,
  unionpay,
  maestro,
  elo,
  mir,
  hiper,
  hipercard
}

String randomPic = 'https://placeimg.com/680/400/nature';

Container getRandomBackground(double height, double width) {
  return Container(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(
        randomPic,
        width: width,
        height: height,
      ),
    ),
  );
}

Container getChipImage() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    child: Image.asset(
      'icons/chip.png',
      height: 52,
      width: 52,
      package: 'credit_card',
    ),
  );
}
