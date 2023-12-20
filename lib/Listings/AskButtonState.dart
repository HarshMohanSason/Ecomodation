
import 'package:flutter/cupertino.dart';

class DetailedListingStateManage extends ChangeNotifier {

  bool _initialMessageSent = false; //initially message Sent value is false

  bool get getAskButton => _initialMessageSent; //getter to get the button

  set setAskButton(bool value) { //set the state of the show button to true
    _initialMessageSent = value;
    notifyListeners();  //notify listeners whenever the value for the of the button is changed.
  }
}