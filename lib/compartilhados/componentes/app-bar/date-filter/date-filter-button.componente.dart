import 'package:connectivity_wrapper/connectivity_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateFilterButtonComponente extends StatelessWidget {
  final Function funcao;
  final String tooltip;
  final bool desativarEmOffline;

  DateFilterButtonComponente({@required this.funcao, this.tooltip, this.desativarEmOffline = true});

  @override
  Widget build(BuildContext context) {
    bool _isOnline = Provider.of<ConnectivityStatus>(context) == ConnectivityStatus.CONNECTED;
    return IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: _isOnline 
        ? funcao
        : desativarEmOffline
          ? () {}
          : funcao,
      tooltip: '$tooltip',
    );
  }
}
