import 'package:flutter/material.dart';

class ColorTheme{

  ColorTheme._();

  static MaterialColor get green{
    return MaterialColor(0xff00552a,<int,Color> {100:Color(0xff00552a)});
  }

  static Color get lightGreen1{
    return Color(0xff46d3a0);
  }

  static Color get darkGreen2{
    return Color(0xff1aaa76);
  }

  static Color get darkGreen{
    return Color(0xff00552a);
  }

  static Color get golden=>Color.fromRGBO(179, 143, 7,1.0);

  static Color get darkRed{
    return Color(0xffff0000);
  }

  static Color get lightGreen{
    return Color(0xff86C5B0);
  }

  static Color get lightGreenOpacity{
    return Color(0xffedfaf8);
  }
/*
  static Color get backgroundColor{
    return Color(0xffE9FFFB);
  }*/

static Color get buttonColor{
  return Color(0xff62ab8d);
}


static Color get iconColor{
  return Color(0xff78a28d);
}



  static Color get backgroundColor{
    return Color(0xffDCEFED);
  }

  static Color get white{
    return Color(0xffffffff);
  }

}