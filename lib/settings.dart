// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/login.dart';
import 'package:flutter_app_komeet/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

// Color picker
import 'package:flutter_colorpicker/block_picker.dart';

class Settings extends StatelessWidget {
  // Constructeur
  Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Réglages',
          style: TextStyle(
              color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Nouvel écran de Réglages
      body: new SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  // Constructeur
  SettingsScreen({Key key}) : super(key: key);

  @override
  State createState() => new SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  // base de données
  DataBase db = new DataBase();

  // Constructeur
  SettingsScreenState({Key key});

  // champs texte
  TextEditingController controllerPseudoUtilisateur;
  TextEditingController controllerStatut;

  // Préférences partagées :  stockage des données en local
  SharedPreferences prefs;

  String codeUtilisateur = '';
  String pseudoUtilisateur = '';
  String statut = '';
  String photoUrl = '';

  // déclenche le widget chargement
  bool isLoading = false;
  // image de l'utilisateur
  File avatarImageFile;

  // focus sur un champ texte
  final FocusNode focusNodepseudoUtilisateur = new FocusNode();
  final FocusNode focusNodestatut = new FocusNode();

  //color picker

  Color currentColor = ThemeKomeet.themeColor;

  // texte du bouton : mode sombre/mode clair
  static String themeTxt;

  // méthode de changement des couleurs
  void changeColor(Color color) {
    if (color == Colors.black) {
      handleDarkTheme();
    }
    currentColor = color;
    setState(
      () {
        ThemeKomeet.themeColor = currentColor;
        Fluttertoast.showToast(msg: "Couleur Changée");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return MyApp();
            // Retour à l'écran de main
          }),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  // lecture des données déjà présentes dans les sharedPreferences
  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    codeUtilisateur = prefs.getString('codeUtilisateur') ?? '';
    pseudoUtilisateur = prefs.getString('pseudoUtilisateur') ?? '';
    statut = prefs.getString('statut') ?? '';
    photoUrl = prefs.getString('photoUrl') ?? '';

    controllerPseudoUtilisateur =
        new TextEditingController(text: pseudoUtilisateur);
    controllerStatut = new TextEditingController(text: statut);

    // Obligation de rafraichir
    setState(() {});
  }

  Future getImage() async {
    // image picker
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = codeUtilisateur;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          Firestore.instance
              .collection('Utilisateur')
              .document(codeUtilisateur)
              .updateData({
            'pseudoUtilisateur': pseudoUtilisateur,
            'statut': statut,
            'photoUrl': photoUrl
          }).then((data) async {
            await prefs.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Mise à jour réussie");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            // message d'erreur en toast
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'Erreur inconnue');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Erreur inconnue');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      // message d'erreur en toast
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  void handleUpdateData() {
    // on se retire du champ texte
    focusNodepseudoUtilisateur.unfocus();
    focusNodestatut.unfocus();

    setState(() {
      isLoading = true;
      // chargement lancé
    });

    // mise à jour des données de firebase et des sharedPreferences
    Firestore.instance
        .collection('Utilisateur')
        .document(codeUtilisateur)
        .updateData({
      'pseudoUtilisateur': pseudoUtilisateur,
      'statut': statut,
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs.setString('pseudoUtilisateur', pseudoUtilisateur);
      await prefs.setString('statut', statut);
      await prefs.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
        // chragement terminé
      });

      Fluttertoast.showToast(msg: "Mise à jour réussie");
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      // message d'erreur en toast
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  // Changement du texte du bouton si changement de thème
  void checkTheme() {
    if (ThemeKomeet.darkTheme) {
      themeTxt = "MODE CLAIR";
    } else {
      themeTxt = "MODE SOMBRE";
    }
  }

  // Choix de la couleur dans le color picker
  void handleChangeTheme() {
    focusNodepseudoUtilisateur.unfocus();
    focusNodestatut.unfocus();
    if (!ThemeKomeet.darkTheme) {
      // Changement du thème...
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choisissez une couleur'),
            content: SingleChildScrollView(
              child: BlockPicker(
                pickerColor: currentColor,
                onColorChanged: changeColor,
              ),
            ),
          );
        },
      );
    } else {
      Fluttertoast.showToast(msg: "Pas de changement en mode sombre");
    }
  }

  // Application du thème sombre
  void handleDarkTheme() {
    if (!ThemeKomeet.darkTheme) {
      setState(() {
        ThemeKomeet.enableDarkMode(true);
      });
    } else if (ThemeKomeet.darkTheme) {
      setState(() {
        ThemeKomeet.enableDarkMode(false);
      });
    }
    checkTheme();
    Fluttertoast.showToast(msg: "Changement");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return MyApp();
      }),
    );
  }

  Widget handleChangeLanguage() {
    Navigator.pop(context);
    return Container(
      child: Text('Veuillez choisir votre langue'),
    );
  }

  // Création de l'écran de Réglages
  @override
  Widget build(BuildContext context) {
    checkTheme();
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Avatar
              Container(
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      (avatarImageFile == null)
                          ? (photoUrl != ''
                              ? Material(
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    ThemeKomeet.themeColor),
                                          ),
                                          width: 90.0,
                                          height: 90.0,
                                          padding: EdgeInsets.all(20.0),
                                        ),
                                    imageUrl: photoUrl,
                                    width: 90.0,
                                    height: 90.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(45.0)),
                                  clipBehavior: Clip.hardEdge,
                                )
                              : Icon(
                                  Icons.account_circle,
                                  size: 90.0,
                                  color: ThemeKomeet.greyColor,
                                ))
                          : Material(
                              child: Image.file(
                                avatarImageFile,
                                width: 90.0,
                                height: 90.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(45.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: ThemeKomeet.primaryColor.withOpacity(0.5),
                        ),
                        onPressed: getImage,
                        padding: EdgeInsets.all(30.0),
                        splashColor: Colors.transparent,
                        highlightColor: ThemeKomeet.greyColor,
                        iconSize: 30.0,
                      ),
                    ],
                  ),
                ),
                width: double.infinity,
                margin: EdgeInsets.all(20.0),
              ),

              // Changement d'informations utilisateur
              Column(
                children: <Widget>[
                  // Nom
                  Container(
                    child: Text(
                      'Pseudo',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ThemeKomeet.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: ThemeKomeet.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Johnny...',
                          contentPadding: new EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: ThemeKomeet.greyColor),
                        ),
                        controller: controllerPseudoUtilisateur,
                        onChanged: (value) {
                          pseudoUtilisateur = value;
                        },
                        focusNode: focusNodepseudoUtilisateur,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),

                  // Statut
                  Container(
                    child: Text(
                      'Statut',
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          color: ThemeKomeet.primaryColor),
                    ),
                    margin: EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                  ),
                  Container(
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: ThemeKomeet.primaryColor),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Flutter...',
                          contentPadding: EdgeInsets.all(5.0),
                          hintStyle: TextStyle(color: ThemeKomeet.greyColor),
                        ),
                        controller: controllerStatut,
                        onChanged: (value) {
                          statut = value;
                        },
                        focusNode: focusNodestatut,
                      ),
                    ),
                    margin: EdgeInsets.only(left: 30.0, right: 30.0),
                  ),
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),

              // Boutons d'actions
              Container(
                child: FlatButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    'METTRE A JOUR',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: ThemeKomeet.primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 50.0, bottom: 10.0),
              ),
              Container(
                child: FlatButton(
                  onPressed: handleChangeTheme,
                  child: Text(
                    'CHANGER DE THEME',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: ThemeKomeet.primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Container(
                child: FlatButton(
                  onPressed: handleDarkTheme,
                  child: Text(
                    themeTxt,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: ThemeKomeet.primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
              Container(
                child: FlatButton(
                  onPressed: handleChangeLanguage,
                  child: Text(
                    'Langue',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: ThemeKomeet.primaryColor,
                  highlightColor: new Color(0xff8d93a0),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
                ),
                margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              ),
            ],
          ),
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
        ),

        // Widget de chargement
        Positioned(
          child: isLoading
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ThemeKomeet.themeColor)),
                  ),
                  color: Colors.white.withOpacity(0.8),
                )
              : Container(),
        ),
      ],
    );
  }
}
