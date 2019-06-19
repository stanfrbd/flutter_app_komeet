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

  static var themeColor = Colors.grey; //Color(0xff838383);//Color(0xfff5a623);
  static var primaryColor = Color(0xff203152);
  static var greyColor = Color(0xffaeaeae);
  static var greyColor2 = Color(0xffE8E8E8);
  static var floatingBtnColor = Colors.grey;

  static void changeColors() {
    if (darkTheme) {
      primaryColor = Colors.blue;
      greyColor2 = Color(0xffCCCCCC).withOpacity(0.15);
      floatingBtnColor = Colors.blue;
    } else {
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

// -------------------------------------
// Choix dans les PopMenuButton
// -------------------------------------

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

//---------------------------------------
//Classe des variables statiques
// --------------------------------------

class Static {
  static bool isPressed = false;
  static bool enableNotif = true;

// Liste de choix du menu de droite
  static List<Choice> choicesNotifOn = const <Choice>[
    const Choice(title: 'Réglages', icon: Icons.settings),
    const Choice(
        title: 'Désactiver les notifications', icon: Icons.notifications_none),
    const Choice(title: 'Supprimer mon profil', icon: Icons.delete)
  ];

  static List<Choice> choicesNotifOff = const <Choice>[
    const Choice(title: 'Réglages', icon: Icons.settings),
    const Choice(
        title: 'Activer les notifications', icon: Icons.notifications_none),
    const Choice(title: 'Supprimer mon profil', icon: Icons.delete)
  ];

  // Liste de choix pour les conversations

  static List<Choice> friendsOptions = const <Choice>[
    const Choice(title: 'Supprimer cet ami', icon: Icons.highlight_off),
    const Choice(title: 'Supprimer la conversation', icon: Icons.delete)
  ];

  // Liste de choix pour les réglages dans l'écran réglages

  static List<Choice> SettingsOptionsLight = const <Choice>[
    const Choice(title: 'Changer de thème', icon: Icons.format_paint),
    const Choice(title: 'Mode sombre', icon: Icons.brightness_3)
  ];

  static List<Choice> SettingsOptionsDark = const <Choice>[
    const Choice(title: 'Changer de thème', icon: Icons.format_paint),
    const Choice(title: 'Mode clair', icon: Icons.wb_sunny)
  ];
}

class Language {
  final int id;
  final String name;
  final String symbol;

  const Language({this.id, this.name, this.symbol});

  static List<Language> userLanguage = const <Language>[
    const Language(id: 1, name: 'Français', symbol: '🇫🇷'),
    const Language(id: 2, name: 'Anglais', symbol: '🇺🇸'),
    const Language(id: 3, name: 'Allemand', symbol: '🇩🇪'),
    const Language(id: 4, name: 'Espagnol', symbol: '🇪🇸'),
    const Language(id: 5, name: 'Chinois', symbol: '🇨🇳'),
    const Language(id: 6, name: 'Japonais', symbol: '🇯🇵'),
    const Language(id: 7, name: 'Russe', symbol: '🇷🇺'),
    const Language(id: 8, name: 'Italien', symbol: '🇮🇹'),
    const Language(id: 9, name: 'Grec', symbol: '🇬🇷'),
  ];
}
