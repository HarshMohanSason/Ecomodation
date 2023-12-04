
import 'package:flutter/cupertino.dart';

class DetailedListingStateManage extends ChangeNotifier {

  bool _initialMessageSent = false;

  bool get getShowAskButton => _initialMessageSent;

  set setShowAskButton(bool value) {
    _initialMessageSent = value;
    notifyListeners();
  }

}