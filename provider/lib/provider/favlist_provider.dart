import 'package:flutter/foundation.dart';

class FavListProvider with ChangeNotifier{

    List _favNum = [];

    List get favNum => _favNum;

    void selectItel(int i){
        _favNum.add(i);
        notifyListeners();
    }

    void removeItem(int i){
      _favNum.remove(i);
       notifyListeners();
    }

}