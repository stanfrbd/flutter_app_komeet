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
import 'package:flutter/services.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/main.dart';
import 'package:flutter_app_komeet/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';

class Chat extends StatelessWidget {
  // Attributs

  // ID de celui à qui on envoie le message
  final String peerId;
  // Image de celui à qui on envoie le message
  final String peerAvatar;
  // le nom d'utilisateur de la personne à qui on envoie le message
  final String chatMate;

  // Constructeur
  Chat(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.chatMate})
      : super(key: key);

  // Construction de l'écran
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          chatMate, // à qui on envoie le message
          style: TextStyle(
              color: ThemeKomeet.primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // body de Chat avec le constructeur
      body: new ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  // Attributs

  final String peerId;
  final String peerAvatar;

  // Constructeur
  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  // Nouvel état
  @override
  State createState() =>
      new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class ChatScreenState extends State<ChatScreen> {
  // Attributs

  String peerId;
  String peerAvatar;
  String codeUtilisateur;

  // Constructeur
  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  // Liste des messages
  var listMessage;
  // ID de la conversation
  String groupChatId;
  // SharedPreferences : écriture en local
  SharedPreferences prefs;

  // fichier image
  File imageFile;
  // Chargement
  bool isLoading;

  // URL de l'image obtenu à l'upload
  String imageUrl;

  // Champ texte
  final TextEditingController textEditingController =
      new TextEditingController();
  // scrolling
  final ScrollController listScrollController = new ScrollController();

  // Initialisation de départ
  @override
  void initState() {
    super.initState();

    groupChatId = '';

    isLoading = false;
    imageUrl = '';

    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    codeUtilisateur = prefs.getString('codeUtilisateur') ?? '';
    if (codeUtilisateur.hashCode <= peerId.hashCode) {
      // Génération de l'ID de conversation
      groupChatId = '$codeUtilisateur-$peerId';
    } else {
      groupChatId = '$peerId-$codeUtilisateur';
    }
    // mettre à jour, sinon cela ne fait rien
    setState(() {});
  }

  Future getImage() async {
    // utilisation de l'image picker
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        // widget chargement activé
        isLoading = true;
      });
      // envoi du fichier
      uploadFile();
    }
  }

  // Envoi du fichier
  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    // upload de l'image sur firebase puis récupération de l'URL
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Erreur inconnue');
    });
  }

  // à l'envoi du message
  void onSendMessage(String content, int type) {
    // type : 0 = texte, 1 = image,
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          // remplissage des champs du message
          documentReference,
          {
            'idFrom': codeUtilisateur,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
      // Animation de scroll
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      // si le champ texte est vide
      Fluttertoast.showToast(msg: 'Rien à envoyer');
    }
  }

  // Création de l'item message dans la liste
  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == codeUtilisateur) {
      // Le message personnel
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Texte
              ? GestureDetector(
                  onLongPress: () {
                    Fluttertoast.showToast(
                        msg: 'Message copié, implémenter : supprimer');
                    Clipboard.setData(
                        new ClipboardData(text: document['content']));
                  },
                  child: Container(
                    child: Text(
                      document['content'],
                      style: TextStyle(color: ThemeKomeet.primaryColor),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: ThemeKomeet.greyColor2,
                        borderRadius: BorderRadius.circular(20.0)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  ))
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeKomeet.themeColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: ThemeKomeet.greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),
                          imageUrl: document['content'],
                          width: 200.0,
                          height: 200.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  : Container(),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeKomeet.themeColor),
                                ),
                                width: 35.0,
                                height: 35.0,
                                padding: EdgeInsets.all(10.0),
                              ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0 // texte
                    ? GestureDetector(
                        // lorqu'on reste appuyé
                        onLongPress: () {
                          Fluttertoast.showToast(
                              msg: 'Message copié, Implémenter : supprimer');
                          Clipboard.setData(
                              new ClipboardData(text: document['content']));
                        },
                        child: Container(
                          child: Text(
                            document['content'],
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(
                              color: ThemeKomeet.primaryColor,
                              borderRadius: BorderRadius.circular(20.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        ))
                    : document['type'] == 1 // image
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ThemeKomeet.themeColor),
                                      ),
                                      width: 200.0,
                                      height: 200.0,
                                      padding: EdgeInsets.all(70.0),
                                      decoration: BoxDecoration(
                                        color: ThemeKomeet.greyColor2,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                    ),
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(),
              ],
            ),

            // Date du message : à gauche uniquement (résultat du booléen)
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(
                              int.parse(document['timestamp']))),
                      style: TextStyle(
                          color: ThemeKomeet.greyColor,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  // dernier message à gauche oui/non
  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == codeUtilisateur) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // dernier message à droite oui/non
  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != codeUtilisateur) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // Lors de l'appui sur la flèche de retour arrière
  Future<Null> onBackPress() {
    Navigator.pop(context);
  }

  // Création de l'écran
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          GestureDetector(
              // implémenter pour le swipe-to-go-back
              ),
          Column(
            children: <Widget>[
              // création de la liste des messages
              buildListMessage(),

              // widget Entrée de texte
              buildInput(),
            ],
          ),

          // widget chargement
          buildLoading()
        ],
      ),
      // retour à la page d'avant
      onWillPop: onBackPress,
    );
  }

  // Création du widget chargement
  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ThemeKomeet.themeColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  // création du widget d'entrée des données
  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Bouton envoyer une image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: getImage,
                color: ThemeKomeet.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.timer),
                onPressed: () {
                  Fluttertoast.showToast(msg: 'à implémenter : timer');
                },
                color: ThemeKomeet.primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Changer le texte : widget flexible contenant le champ texte
          Flexible(
            child: Container(
              child: TextField(
                style:
                    TextStyle(color: ThemeKomeet.primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Tapez ici...',
                  hintStyle: TextStyle(color: ThemeKomeet.greyColor),
                ),
              ),
            ),
          ),

          // Bouton envoyer
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: new IconButton(
                icon: new Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: ThemeKomeet.primaryColor,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: ThemeKomeet.greyColor2, width: 0.5)),
          color: Colors.white),
    );
  }

  // création de la pile de messages
  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          // si on ne sait pas le contenu : widget de chargement
          ? Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(ThemeKomeet.themeColor)))
          //sinon on stream Firebase pour récupérer les messages
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  //groupement par timestamp
                  .orderBy('timestamp', descending: true)
                  // on limite à 20 messages le scroll
                  .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                // si pas de données : widget chargement
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              ThemeKomeet.themeColor)));
                }
                // Sinon construction de la liste avec les données de firebase
                else {
                  // on récupère les messages dans la liste
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    // Constructeur d'items : items de la liste
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount:
                        snapshot.data.documents.length, // nombre de documents
                    reverse: true,
                    // scrollable
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
