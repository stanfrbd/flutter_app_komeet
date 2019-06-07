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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------------------------------------------
// MyApp est toujours la première classe lancée en flutter
// -------------------------------------------------------

class MyApp extends StatelessWidget {
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
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Back-end de l'authentification

  final GoogleSignIn googleSignIn =
      GoogleSignIn(); // déclaration d'un nouveau client google
  final FirebaseAuth firebaseAuth =
      FirebaseAuth.instance; // nouvelle instance de firebase auth
  SharedPreferences prefs;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser; // utilisateur courant

  @override
  void initState() {
    super.initState();
    isSignedIn(); // si l'utilisateur est connecté booléen
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    prefs = await SharedPreferences.getInstance(); // préférences

    isLoggedIn = await googleSignIn.isSignedIn(); // booléen qui dit si connecté
    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainScreen(currentUserId: prefs.getString('id'))),
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
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      Fluttertoast.showToast(msg: "Utilisateur existant");
      if (documents.length == 0) {
        Fluttertoast.showToast(msg: "Premier utilisateur");
        // Update data to server if new user
        Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid
        });

        // Write data to local
        currentUser = firebaseUser;
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        Fluttertoast.showToast(msg: "Ecriture en local");
        // Write data to local
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Connexion réussie");
      this.setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MainScreen(
                  currentUserId: firebaseUser.uid,
                )),
      );
    } else {
      Fluttertoast.showToast(msg: "Echec de connexion");
      this.setState(() {
        isLoading = false;
      });
    }
  }

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

            // Loading
            Positioned(
              child: isLoading // if true
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
