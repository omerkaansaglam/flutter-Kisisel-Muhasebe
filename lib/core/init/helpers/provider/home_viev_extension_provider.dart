import 'package:flutter/widgets.dart';

class HomeViewManagerProvider with ChangeNotifier{
  bool _gelirOrGider = false;

  bool get gelirOrGider => _gelirOrGider;

  set gelirOrGider(bool gelirOrGider) {
    _gelirOrGider = gelirOrGider;
    notifyListeners();
  }

}