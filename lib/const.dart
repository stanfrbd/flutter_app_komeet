// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:ui';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------
// -------------- Classe Statique de thèmes de l'application -------------
// -----------------------------------------------------------------------
class ThemeKomeet {
  static bool darkTheme = false;

  static var themeColor = Colors.grey;//Color(0xff838383);//Color(0xfff5a623);
  static var primaryColor = Color(0xff203152);
  static var greyColor = Color(0xffaeaeae);
  static var greyColor2 = Color(0xffE8E8E8);
  static var floatingBtnColor = Colors.grey;

  static void changeColors() {
    if (darkTheme) {
        primaryColor = Colors.blue;
        greyColor2 = Color(0xffCCCCCC).withOpacity(0.15);
        floatingBtnColor = Colors.blue;
    }
    else {
      themeColor = Colors.grey;
      primaryColor = Color(0xff203152);
      greyColor2 = Color(0xffE8E8E8);
    }

  }
// ----------------------------------------
// --------- Activer le mode sombre -------
// ----------------------------------------


  static void enableDarkMode(bool state) {
    darkTheme = false;
    if (state) {
        darkTheme = true;
    }
    changeColors();
  }
}


