
import 'package:flutter/material.dart';

class MessageStatus extends ChangeNotifier{ //Status for checking whether a message was sent or not

  bool isSent = false;
  bool isSeen = false;

  bool get isMessageSent => isSent;
  bool get isMessageSeen => isSeen;

  set isMessageSent(bool value) {
    isSent = value;
    notifyListeners();
  }
  set isMessageSeen(bool value)
  {
    isSeen = value;
    notifyListeners();
  }
}