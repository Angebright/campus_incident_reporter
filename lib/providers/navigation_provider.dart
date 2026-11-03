import 'package:flutter/foundation.dart';

/// Tracks the selected bottom-navigation tab for the active shell.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    if (_currentIndex == 0) return;
    _currentIndex = 0;
    notifyListeners();
  }
}
