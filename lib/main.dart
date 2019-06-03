// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app_komeet/chat.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/login.dart';
import 'package:flutter_app_komeet/settings.dart';
import 'package:google_sign_in/google_sign_in.dart';

// -----------------------------------------
// Lancement de l'écran de Login au démarrage
//-------------------------------------------
void main() => runApp(MyApp());

// -------------------------------------
// Ecran de main : affichage des messages
// -------------------------------------

class MainScreen extends StatefulWidget {
  // Utilisateur courant
  final String currentUserId;

  // Constructeur
  MainScreen({Key key, @required this.currentUserId}) : super(key: key);

  // Création d'un nouvel état de MainScreen avec les widgets
  @override
  State createState() => MainScreenState(currentUserId: currentUserId);
}

class MainScreenState extends State<MainScreen> {
  MainScreenState({Key key, @required this.currentUserId});

  final String currentUserId;

  // Lancement du widget chargement commandé par ce booléen
  bool isLoading = false;

  // Liste de choix du menu de droite
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Réglages', icon: Icons.settings),
    const Choice(title: 'Supprimer mon profil', icon: Icons.delete)
  ];

  // Quand appuie sur retour (icône déconnexion)

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: ThemeKomeet.themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Déconnexion',
                      style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confirmation ?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),

              // Confirmation de déconnexion
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: ThemeKomeet.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'Annuler',
                      style: TextStyle(color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: ThemeKomeet.primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'Oui',
                      style: TextStyle(color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        handleSignOut(); // Déconnexion back-end
        break;
    }
  }

  // Méthode pour rechercher un contact
  Future<Null> handleSearchContact () {
    Fluttertoast.showToast(msg: "A implémenter");
  }

  // Méthode pour ajouter des favoris
  Future<bool> handleAddFavorites() {
    Fluttertoast.showToast(msg: "A implémenter");
    return Future.value(true);
  }


  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Material(
                child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                        child: CircularProgressIndicator(
                          strokeWidth: 1.0,
                          valueColor: AlwaysStoppedAnimation<Color>(ThemeKomeet.themeColor),
                        ),
                        width: 50.0,
                        height: 50.0,
                        padding: EdgeInsets.all(15.0),
                      ),
                  imageUrl: document['photoUrl'],
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              // Widget contenant le nom et le statut
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          '${document['nickname']}',
                          style: TextStyle(color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold, fontSize: 18),

                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      ),
                      Container(
                        child: Text(
                          'Statut : ${document['aboutMe'] ?? 'Je suis cool'}', // il faudra mettre le dernier message à la place
                          style: TextStyle(color: ThemeKomeet.primaryColor),
                        ),
                        alignment: Alignment.centerLeft,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          // Lorsque l'on appuie sur le widget Flexible
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  // Lancement d'un nouvel écran de chat
                    builder: (context) => Chat(
                          peerId: document.documentID,
                          peerAvatar: document['photoUrl'],
                          chatMate: document['nickname'],
                        )));
          },
          color: ThemeKomeet.greyColor2,
          padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Evenements lors du l'appui sur le menu de droite
  void onItemMenuPress(Choice choice) {
   if (choice.title == 'Réglages') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
    }
    else if (choice.title == 'Supprimer mon profil') {
      handleDeleteProfile();
    }
  }

  // Méthode back-end de déconnexion du profil
  Future<Null> handleSignOut() async {
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    // Navigation vers la page de Login
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);
  }

  // Méthode back-end de suppression du profil de la base de données
  Future<Null> handleDeleteProfile() async {
    Fluttertoast.showToast(msg: "Profil supprimé");
    this.setState(() {
      isLoading = true;
    });

    await FirebaseAuth.instance.signOut();
    await googleSignIn.disconnect();
    await googleSignIn.signOut();

    this.setState(() {
      isLoading = false;
    });

    // Navigation vers un écran de Login
    Navigator.of(context)
        .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false);

  Firestore.instance.collection("users").document(currentUserId).delete();  // méthode pour supprimer de firebase le currentUser 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: ThemeKomeet.primaryColor,
        ),
        leading: new IconButton(
          icon: new Icon(Icons.exit_to_app),
          onPressed: openDialog,
        ),
        title: Text(
          'Messages',
          style: TextStyle(color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),

        ),
        centerTitle: true,
        actions: <Widget>[

          //Bouton rechercher des contacts
          IconButton(
            onPressed: handleSearchContact,
            icon: Icon(Icons.search),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          ),

          // Bouton favoris
          IconButton(
            onPressed: handleAddFavorites,
            icon: Icon(Icons.star),
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          ),
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: ThemeKomeet.primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: ThemeKomeet.primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            // Liste de conversation
            Container(
              child: StreamBuilder(
                stream: Firestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(ThemeKomeet.themeColor),
                      ),
                    );
                  } else {
                    // construction de la listView
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(context, snapshot.data.documents[index]),
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ThemeKomeet.themeColor)),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            )
          ],
        ),
        onWillPop: onBackPress,
      ),
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

