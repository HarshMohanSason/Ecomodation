
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

enum ConnectionStatus { connected, disconnected, connecting }

class InternetProvider extends ChangeNotifier {

  ConnectionStatus connectionStatus = ConnectionStatus.connecting;
  bool _hasInternet = false;

  bool get hasInternet => _hasInternet;

  InternetProvider()
  {
    checkInternetConnection();
  }

  Future checkInternetConnection() async
  {
    var result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
    notifyListeners();
  }

  Future<void> retryInternetConnection() async
  {

    connectionStatus = ConnectionStatus.connecting;
    await checkInternetConnection();
    notifyListeners();

  }

  void _updateConnectionStatus(ConnectivityResult result)
  {
    if(result == ConnectivityResult.none)
    {
      connectionStatus = ConnectionStatus.disconnected;
      _hasInternet = false;
    }
    else
    {
      connectionStatus = ConnectionStatus.connected;
      _hasInternet = true;
    }
    notifyListeners();
  }
}

