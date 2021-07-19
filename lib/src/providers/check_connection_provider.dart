import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';

class ConnectivityChangeNotifier extends ChangeNotifier {
  late StreamSubscription sub;

  ConnectivityChangeNotifier() {
    sub = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      resultHandler(result);
    });
  }

  bool _connected = true;

  bool get connected => _connected;

  void resultHandler(ConnectivityResult result) async{
    if (result == ConnectivityResult.none) {
      _connected = false;
    } else if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          _connected = true;
        }
      } on SocketException catch (_) {
        _connected = false;
      }
    }

    notifyListeners();
  }

  void initialLoad() async {
    ConnectivityResult connectivityResult =
        await (Connectivity().checkConnectivity());
    resultHandler(connectivityResult);
  }

  @override
  dispose() {
    super.dispose();

    sub.cancel();
  }
}