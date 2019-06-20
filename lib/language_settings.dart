// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

class LanguageSettings extends StatelessWidget {
  // Utilisateur courant
  final String currentUserId;

  // Constructeur
  LanguageSettings({
    Key key,
    @required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Choisir une langue parlée',
          style: TextStyle(
              color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Nouvel écran de Recherche Utilisateur
      body: new LanguageSettingsScreen(
        currentUserId: currentUserId,
      ),
    );
  }
}

class LanguageSettingsScreen extends StatefulWidget {
  // Utilisateur courant
  final String currentUserId;

  // Constructeur
  LanguageSettingsScreen({
    Key key,
    @required this.currentUserId,
  }) : super(key: key);

  @override
  LanguageSettingsScreenState createState() => new LanguageSettingsScreenState(
        currentUserId: currentUserId,
      );
}

class LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  // Utilisateur courant
  final String currentUserId;

  //database
  DataBase db = new DataBase();

  // Constructeur
  LanguageSettingsScreenState({
    Key key,
    @required this.currentUserId,
  });

  // création du widget (départ)
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
              // Construction d'un stream : on récupère tous les utilisateurs de la BD
              stream: Firestore.instance
                  .collection('Langue')
                  .orderBy('codeLangue', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container();
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data.documents
                        .length, //Nombre de documents de la collection
                    itemBuilder: (context, index) {
                      // création des items
                      return ListTile(
                        onTap: () {
                          var codeLangue =
                              snapshot.data.documents[index]['codeLangue'];
                          var titreLangue =
                              snapshot.data.documents[index]['titreLangue'];
                          Fluttertoast.showToast(
                              msg: '$titreLangue choisi',
                              gravity: ToastGravity.TOP);
                          // changement dans la base
                          db.changeLangueUser(currentUserId, codeLangue);
                        },
                        title: Text(
                          '${snapshot.data.documents[index]['titreLangue']}',
                          style: TextStyle(fontSize: 20.0),
                          textAlign: TextAlign.left,
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
