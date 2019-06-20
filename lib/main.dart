// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_app_komeet/chat.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/login.dart';
import 'package:flutter_app_komeet/search_user.dart';
import 'package:flutter_app_komeet/settings.dart';
import 'package:flutter_app_komeet/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/cupertino.dart';

// -----------------------------------------
// Lancement de l'écran de Login au démarrage
//-------------------------------------------
void main() => runApp(MyApp());

// -------------------------------------
// Ecran de main : affichage des messages
// -------------------------------------

class MainScreen extends StatefulWidget {
  // Attributs

  // Utilisateur courant
  final String currentUserId;

  // Constructeur
  MainScreen({
    Key key,
    @required this.currentUserId,
  }) : super(key: key);

  // Création d'un nouvel état de MainScreen avec les widgets
  @override
  State createState() => MainScreenState(
        currentUserId: currentUserId,
      );
}
// --------------------------------------------
// Création de l'état qui hérite de Mainscreen
//----------------------------------------------

class MainScreenState extends State<MainScreen> {
  static List<User> allUsers = new List<User>();
  // base de données
  DataBase db = new DataBase();
  // Attributs
  final String currentUserId;

  // Constructeur
  MainScreenState({
    Key key,
    @required this.currentUserId,
  });

  // Lancement du widget chargement commandé par ce booléen
  bool isLoading = false;

  // Utilisateur sélectionné
  var selectedUser;

  // retour : déconnexion
  Future<bool> onBackPress() {
    openSignOutDialog();
    return Future.value(false);
  }

  //--------------------------------------------
  // Dialogue de confirmation pour la déconnexion
  // --------------------------------------------
  // Future<Null> procédure évenementielle qui ne revoie rien
  Future<Null> openSignOutDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
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
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confirmation ?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),

              // Confirmation de déconnexion de type 0,1 => switch
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
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor,
                          fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor,
                          fontWeight: FontWeight.bold),
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
        handleSignOut(); // Procédure de la déconnexion
        break;
    }
  }

  // -------------------------------------------------
  // Procédure évenementielle de suppression d'un ami
  // ------------------------------------------------
  Future<Null> handleDeleteFriend(String codeUtilisateur) async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
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
                        Icons.warning,
                        size: 30.0,
                        color: ThemeKomeet.primaryColor,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Supprimer $selectedUser ?',
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Confirmation ?',
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
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
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor,
                          fontWeight: FontWeight.bold),
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
                      style: TextStyle(
                          color: ThemeKomeet.primaryColor,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0: // même principe que la procédure précédente
        break;
      case 1:
        Fluttertoast.showToast(
            msg: '$selectedUser Supprimé des amis'); // retour utilisateur
        db.deleteFriend(
            codeUtilisateur, currentUserId); // suppression dans la base
        break;
    }
  }

  // -------------------------------------------------
  // Procédure évenementielle pour rechercher un ami
  // ------------------------------------------------

  // Lancement d'un nouvel écran de SearchUser
  Future<Null> handleSearchContact() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => SearchUser(
                  currentUserId: currentUserId,
                )),
        (Route<dynamic> route) => true);
    return null;
  }

  // Procédure pour avoir des personnes en ami aléatoirement (principe Komeet)
  Future<bool> handleRandomFriends() {
    Fluttertoast.showToast(msg: 'Aléatoire (implémenter)');
    // db.addRandomFriend();
    return Future.value(true);
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['codeAmi'] == currentUserId) {
      return Container();
    } else {
      return Container(
        child: GestureDetector(
          onLongPress: () {
            setState(() {
              selectedUser = db.getSingleUser(document['codeAmi']).getPseudo();
            });
            Fluttertoast.showToast(msg: 'selectionné : $selectedUser');
            handleDeleteFriend(document['codeAmi']);
          },
          child: FlatButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                ThemeKomeet.themeColor),
                          ),
                          width: 50.0,
                          height: 50.0,
                          padding: EdgeInsets.all(15.0),
                        ),
                    imageUrl: db
                            .getSingleUser(document['codeAmi'])
                            .getPhoto() ??
                        "https://user-images.githubusercontent.com/44167150/59460176-bba7a500-8e1e-11e9-99dd-324b32162d57.jpg",
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
                            db.getSingleUser(document['codeAmi']).getPseudo() ??
                                "Chargement...",
                            style: TextStyle(
                                color: ThemeKomeet.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5),
                        ),
                        Container(
                          child: Text(
                            db.getSingleUser(document['codeAmi']).getStatus() ??
                                "Komeet c'est trop cool !",
                            // il faudra mettre le dernier message à la place
                            style: TextStyle(color: ThemeKomeet.primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20.0),
                  ),
                ),
                Container(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: ThemeKomeet.primaryColor,
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
                        peerId: document['codeAmi'],
                        peerAvatar:
                            db.getSingleUser(document['codeAmi']).getPhoto(),
                        chatMate:
                            db.getSingleUser(document['codeAmi']).getPseudo(),
                      ),
                ),
              );
            },
            color: ThemeKomeet.greyColor2,
            padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Evenements lors du l'appui sur le menu de droite
  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Réglages') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Settings()));
    } else if (choice.title == 'Supprimer mon profil') {
      handleDeleteProfile();
    } else if (choice.title == 'Supprimer la conversation') {
      Fluttertoast.showToast(
          msg: 'Conversation supprimée avec $selectedUser (implémenter)');
    } else if (choice.title == 'Désactiver les notifications') {
      Fluttertoast.showToast(
          msg: 'Notifications désactivées (implémenter)',
          gravity: ToastGravity.TOP);
      setState(() {
        Static.enableNotif = false;
      });
    } else if (choice.title == 'Supprimer cet ami') {
      Fluttertoast.showToast(msg: '$selectedUser supprimé (implémenter)');
    } else if (choice.title == 'Activer les notifications') {
      Fluttertoast.showToast(
          msg: 'Notifications activées (implémenter)',
          gravity: ToastGravity.TOP);
      setState(() {
        Static.enableNotif = true;
      });
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
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
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
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);

    Firestore.instance
        .collection("Utilisateur")
        .document(currentUserId)
        .delete(); // méthode pour supprimer de firebase le currentUser
  }

  // Construction de l'écran ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: ThemeKomeet.primaryColor,
        ),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: openSignOutDialog,
        ),
        title: Text(
          'Messages',
          style: TextStyle(
              color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          // Bouton ajouter amis
          IconButton(
            onPressed: handleRandomFriends,
            icon: Icon(Icons.people),
          ),

          //Bouton rechercher des contacts
          IconButton(
            onPressed: handleSearchContact,
            icon: Icon(Icons.search),
            //padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          ),
          // Menu de droite
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              if (Static.enableNotif) {
                return Static.choicesNotifOn.map((Choice choice) {
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
              } else {
                return Static.choicesNotifOff.map((Choice choice) {
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
              }
            },
          ),
        ],
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Container(
              child: StreamBuilder(
                  stream:
                      Firestore.instance.collection('Utilisateur').snapshots(),
                  builder: (context, snapshot) {
                    allUsers.clear();
                    for (int i = 0; i < snapshot.data.documents.length; i++) {
                      var doc = snapshot.data.documents[i];
                      User u = new User(
                          id: doc['codeUtilisateur'],
                          photo: doc['photoUrl'],
                          pseudo: doc['pseudoUtilisateur'],
                          status: doc['statut']);
                      allUsers.add(u);
                    }

                    return Container();
                  }),
            ),
            // Liste de conversations
            Container(
              child: StreamBuilder(
                // création d'un stream : on récupère tous les utilisateurs de la BD
                stream: Firestore.instance
                    .collection('Connaissance')
                    .where('codeUtilisateur', isEqualTo: currentUserId)
                    .snapshots(),
                builder: (context, snapshot) {
                  // si pas d'amis
                  if (!snapshot.hasData) {
                    Fluttertoast.showToast(
                        msg: "Vous n'avez pas encore d'ami",
                        gravity: ToastGravity.CENTER,
                        toastLength: Toast.LENGTH_LONG);
                    Fluttertoast.showToast(
                        msg: "Recherchez-les dans avec notre menu !",
                        gravity: ToastGravity.CENTER,
                        toastLength: Toast.LENGTH_SHORT);

                    return Container();
                  } else {
                    // construction de la listView
                    return ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      itemBuilder: (context, index) => buildItem(
                          context,
                          snapshot.data.documents[
                              index]), //Appelle constructeur avec UN des documents d'amis
                      itemCount: snapshot.data.documents.length,
                    );
                  }
                },
              ),
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
            )
          ],
        ),
        onWillPop: onBackPress, // retour
      ),
    );
  }
}
