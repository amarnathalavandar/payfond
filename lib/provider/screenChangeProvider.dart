import 'package:flutter/material.dart';

class ScreenChangeProvider extends ChangeNotifier{

  String screen = 'home';

  Color btnClr = Colors.white;
  screenChange(String val){
    screen = val;
    notifyListeners();
  }
  btnClrChange(bool onButton){
    if(onButton){
      btnClr = Colors.black12;
    }else{
      btnClr = Colors.white;
    }
    notifyListeners();
  }

}