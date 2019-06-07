// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchUser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'Ajouter un ami',
          style: TextStyle(color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
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

  // Liste des utilisteurs à ajouter au lieu de ça
  final users = List<String>.generate(100, (i) => "Ami $i");

  //items
  var items = List<String>();

  @override
  void initState() {
    items.addAll(users);
    super.initState();
  }

  void findUser(String query) {
    List<String> searchList = List<String>();
    searchList.addAll(users);
    if(query.isNotEmpty) {
      List<String> listData = List<String>();
      searchList.forEach((item) {
        if(item.contains(query)) {
          listData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(listData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(users);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  findUser(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Rechercher",
                    hintText: "Rechercher",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return FlatButton(onPressed: () {
                    Fluttertoast.showToast(msg: '${items[index]} appuyé (implémenter)');
                  }, child:
                    ListTile(
                      leading: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                        child: Container(
                        width: 48,
                        height: 48,
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        alignment: Alignment.center,
                        child: CircleAvatar(), // photo de l'utilisateur à ajouter
                      ),

                      ),
                    title: Text('${items[index]}'),
                  ),
                  );
                },
              ),
            ),
          ],
        ),
      );
  }
}