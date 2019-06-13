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

class SearchUser extends StatelessWidget {
  // Utilisateur courant
  final String currentUserId;

  BackendDataBase backendDataBase;

  // Constructeur
  SearchUser(
      {Key key, @required this.currentUserId, @required this.backendDataBase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Ajouter un ami',
          style: TextStyle(
              color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // Nouvel écran de Recherche Utilisateur
      body: new SearchUserScreen(
          currentUserId: currentUserId, backendDataBase: backendDataBase),
    );
  }
}

class SearchUserScreen extends StatefulWidget {
  // Utilisateur courant
  final String currentUserId;

  //database
  BackendDataBase backendDataBase;

  // Constructeur
  SearchUserScreen(
      {Key key, @required this.currentUserId, @required this.backendDataBase})
      : super(key: key);

  @override
  SearchUserScreenState createState() => new SearchUserScreenState(
      currentUserId: currentUserId, backendDataBase: backendDataBase);
}

class SearchUserScreenState extends State<SearchUserScreen> {
  // Utilisateur courant
  final String currentUserId;

  //database
  BackendDataBase backendDataBase;

  // Constructeur
  SearchUserScreenState(
      {Key key, @required this.currentUserId, @required this.backendDataBase});

  // Champ texte
  TextEditingController editingController = TextEditingController();

  // requête de recherche
  String query = ' ';

  // couleur de l'ami sélectionné
  Color selectedColor = Colors.white;

  // création du widget (départ)
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value; // On change la requête dans la base
                }); //findUser(value);
              },
              controller: editingController,
              decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ThemeKomeet.primaryColor),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  labelText: "Rechercher",
                  hintText: "Donnez le pseudo exact",
                  labelStyle: TextStyle(color: ThemeKomeet.primaryColor),
                  prefixIcon:
                      Icon(Icons.search, color: ThemeKomeet.primaryColor),
                  // bordure stylisée
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ThemeKomeet.primaryColor),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              cursorColor: ThemeKomeet.primaryColor,
            ),
          ),
          Expanded(
            child: StreamBuilder(
              // Construction d'un stream : on récupère tous les utilisateurs de la BD
              stream: Firestore.instance
                  .collection('Utilisateur')
                  .where('pseudoUtilisateur',
                      isEqualTo: query) // isEqualTO (moins permissif)
                  .snapshots(),
              builder: (context, snapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.documents
                      .length, //Nombre de documents de la collection
                  itemBuilder: (context, index) {
                    // création des items
                    return ListTile(
                      onTap: () {
                        var codeAmi =
                            snapshot.data.documents[index]['codeUtilisateur'];
                        Fluttertoast.showToast(
                            msg:
                                '${snapshot.data.documents[index]['pseudoUtilisateur']} ajouté aux amis (implémenter)',
                            gravity: ToastGravity.TOP);
                        // Ajout d'un ami en back-end
                        backendDataBase.addFriend(codeAmi, currentUserId);
                      },
                      leading: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: Container(
                          width: 65.0,
                          height: 65.0,
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          alignment: Alignment.center,
                          child: Material(
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
                              imageUrl: snapshot.data.documents[index]
                                  ['photoUrl'],
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(25.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                        ),
                      ),
                      title: Text(
                        '${snapshot.data.documents[index]['pseudoUtilisateur']}',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
