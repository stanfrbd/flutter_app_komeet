// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';

class SearchUser extends StatelessWidget {
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
      body: new SearchUserScreen(),
    );
  }
}

class SearchUserScreen extends StatefulWidget {
  // Constructeur
  SearchUserScreen({Key key}) : super(key: key);

  @override
  SearchUserScreenState createState() => new SearchUserScreenState();
}

class SearchUserScreenState extends State<SearchUserScreen> {
  TextEditingController editingController = TextEditingController();

  String query = ' ';

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
                  .collection('users')
                  .where('nickname',
                      isGreaterThanOrEqualTo:
                          query) // isEqualTO (moins permissif)
                  .snapshots(),
              builder: (context, snapshot) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot
                      .data.documents.length, //snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    return FlatButton(
                      onPressed: () {
                        Fluttertoast.showToast(
                            msg:
                                '${snapshot.data.documents[index]['nickname']} ajouté aux amis (implémenter)',
                            gravity: ToastGravity.TOP);
                      },
                      child: ListTile(
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                            '${snapshot.data.documents[index]['nickname']}'),
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
