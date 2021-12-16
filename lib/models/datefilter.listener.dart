import 'package:erp/data/datefilter_helper.dart';

enum DateFilterState { LOGGED_IN, LOGGED_OUT }

abstract class DateFilterStateListener {
  void onDateFilterStateChanged(DateFilterState state);
}

// A naive implementation of Observer/Subscriber Pattern. Will do for now.
class DateFilterStateProvider {
  static final DateFilterStateProvider _instance = new DateFilterStateProvider.internal();

  List<DateFilterStateListener> _subscribers;

  factory DateFilterStateProvider() => _instance;
  DateFilterStateProvider.internal() {
    _subscribers = new List<DateFilterStateListener>();
    initState();
  }

  void initState() async {
    var db = new DatefilterHelper();
    var isLoggedIn = await db.getDateFilter();
    
    // if (isLoggedIn)
    //   notify(AuthState.LOGGED_IN);
    // else
    //   notify(AuthState.LOGGED_OUT);
  }

  void subscribe(DateFilterStateListener listener) {
    _subscribers.add(listener);
  }

  void dispose(DateFilterStateListener listener) {
    for (var l in _subscribers) {
      if (l == listener) _subscribers.remove(l);
    }
  }

  void notify(DateFilterState state) {
    _subscribers.forEach((DateFilterStateListener s) => s.onDateFilterStateChanged(state));
  }
}
