// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/main.dart';
import 'package:flutter_app_komeet/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------------------------------------------
// MyApp est toujours la première classe lancée en flutter
// -------------------------------------------------------

class MyApp extends StatelessWidget {
  final DataBase db = new DataBase();
  @override
  Widget build(BuildContext context) {
    if (!ThemeKomeet.darkTheme) {
      return MaterialApp(
        title: 'Komeet',
        theme: new ThemeData(
          primarySwatch: ThemeKomeet.themeColor,
        ),
        home: LoginScreen(title: 'Komeet'),
        // enlève la bannière "debug"
        debugShowCheckedModeBanner: false,
      );
    } else {
      return MaterialApp(
        title: 'Komeet',
        theme: new ThemeData.dark(), // Mode sombre
        home: LoginScreen(title: 'Komeet'),
        debugShowCheckedModeBanner: false,
      );
    }
  }
}

class LoginScreen extends StatefulWidget {
  // Attributs
  final String title;

  // database
  final DataBase db;
  // Constructeur
  LoginScreen({Key key, this.title, this.db}) : super(key: key);

  // nouvel état
  @override
  LoginScreenState createState() => LoginScreenState(db: db);
}

class LoginScreenState extends State<LoginScreen> {
  // Back-end de l'authentification
  final DataBase db;

  // Constructeur
  LoginScreenState({Key key, @required this.db});

  final GoogleSignIn googleSignIn =
      GoogleSignIn(); // déclaration d'un nouveau client google
  final FirebaseAuth firebaseAuth =
      FirebaseAuth.instance; // nouvelle instance de firebase auth
  SharedPreferences
      prefs; // SharedPreferences : écriture en local (base de donnée locale)

  // Commande le widget chargement
  bool isLoading = false;
  // est connecté oui/non
  bool isLoggedIn = false;
  // ID de l'utilisateur courant
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    isSignedIn(); // si l'utilisateur est connecté booléen
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
      // déclenche le chargement
    });

    prefs = await SharedPreferences.getInstance(); // préférences

    isLoggedIn = await googleSignIn.isSignedIn();
    // booléen qui dit si connecté
    if (isLoggedIn) {
      // si connecté on peut afficher l'écran des conversations : main
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                currentUserId: prefs.getString('codeUtilisateur'), db: db)),
      );
    }

    this.setState(() {
      isLoading = false; // l'utilisateur est connecté donc chargement terminé
    });
  }

  // Procédure back-end de connexion
  Future<Null> handleSignIn() async {
    prefs = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    // selon documentation Google Sign In
    GoogleSignInAccount googleUser =
        await googleSignIn.signIn(); // compte de connexion google
    GoogleSignInAuthentication googleAuth =
        await googleUser.authentication; // évènement de connexion

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken, // identifiant de l'utilisateur compte google
    );

    FirebaseUser firebaseUser =
        await firebaseAuth.signInWithCredential(credential);

    if (firebaseUser != null) {
      // si les tokens ont bien été récupérés
      final QuerySnapshot result = await Firestore.instance
          .collection('Utilisateur')
          .where('codeUtilisateur', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      Fluttertoast.showToast(msg: "Utilisateur existant");
      if (documents.length == 0) {
        Fluttertoast.showToast(msg: "Premier utilisateur");
        // Si nouvel utilisateur on met à jour dans la base de données
        Firestore.instance
            .collection('Utilisateur')
            .document(firebaseUser.uid)
            .setData({
          'pseudoUtilisateur': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'codeUtilisateur': firebaseUser.uid
        });

        // Ecriture en local dans les sharedPreferences
        currentUser = firebaseUser;
        await prefs.setString('codeUtilisateur', currentUser.uid);
        await prefs.setString('pseudoUtilisateur', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        Fluttertoast.showToast(msg: "Ecriture en local");

        await prefs.setString(
            'codeUtilisateur', documents[0]['codeUtilisateur']);
        await prefs.setString(
            'pseudoUtilisateur', documents[0]['pseudoUtilisateur']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('statut', documents[0]['statut']);
      }
      Fluttertoast.showToast(msg: "Connexion réussie");
      this.setState(() {
        isLoading = false;
        // chargement terminé
      });

      // création de l'écran de main à l'aide du constructeur
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  currentUserId: firebaseUser.uid,
                  db: db,
                )),
      );
    } else {
      // Dans tous les autres cas
      Fluttertoast.showToast(msg: "Echec de connexion");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  // Création de l'écran de login
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(
                color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                  onPressed: handleSignIn, // evenemenent presser le bouton
                  child: Text(
                    'CONNEXION AVEC GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),

            // Widget chargement
            Positioned(
              child: isLoading // si vrai
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeKomeet.themeColor),
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        ));
  }
}
