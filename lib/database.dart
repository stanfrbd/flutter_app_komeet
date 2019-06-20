// ----------------------------------------------------
// Projet Tutoré Komeet -------------------------------
// Josquin IMBERT, Rémi TEYSSIEUX,---------------------
// Antoine DE GRYSE, Stanislas MEDRANO ----------------
//-----------------------------------------------------

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app_komeet/const.dart';
import 'package:flutter_app_komeet/main.dart';
import 'dart:math' show Random;

// ------------------------------------------------
// Classe des méthodes back-end de firebase
// ------------------------------------------------

class DataBase {
/* Ancienne version de deleteFriend, avec les collections 'sesAmis'
  Future<bool> deleteFriend(
      String codeAmi, String codeUtilisateurCourant) async {
    // suppression d'un ami dans l'utilisateur courant
    Firestore.instance
        .collection("Connaissance")
        .document(codeUtilisateurCourant)
        .collection('sesAmis')
        .document(codeAmi)
        .delete();
    // suppression d'un ami dans l'ami en question
    Firestore.instance
        .collection("Connaissance")
        .document(codeAmi)
        .collection('sesAmis')
        .document(codeUtilisateurCourant)
        .delete();
    return true;
  }

  // Ancienne version de addFriend
  Future<bool> addFriend(
      String codeAmi,
      String pseudoAmi,
      String photoAmi,
      String statutAmi,
      String codeUtilisateurCourant,
      String pseudoUtilisateurCourant,
      String photoUtilisateurCourant,
      String statutUtilisateurCourant) async {
    // ajout d'un ami : redondance des données mais marche :
    // en gros copié collé de
    // l'utilisateur dans une collection ayant pour ID le codeUtilisateur et pour attributs le nom, la photo...
    Firestore.instance
        .collection('Connaissance')
        .document(codeUtilisateurCourant)
        .collection(
            'sesAmis') // une collection qui contient les docs utilisateur
        .document(codeAmi)
        .setData({
      'codeUtilisateur': codeAmi,
      'pseudoUtilisateur': pseudoAmi,
      'photoUrl': photoAmi,
      'statut': statutAmi
    });

    // ajout de l'ami chez dans l'autre ami
    Firestore.instance
        .collection('Connaissance')
        .document(codeAmi)
        .collection(
            'sesAmis') // une collection qui contient les docs utilisateur
        .document(codeUtilisateurCourant)
        .setData({
      'codeUtilisateur': codeUtilisateurCourant,
      'pseudoUtilisateur': pseudoUtilisateurCourant,
      'photoUrl': photoUtilisateurCourant,
      'statut': statutUtilisateurCourant
    });
    */
  Future<void> deleteFriend(
      String codeAmi, String codeUtilisateurCourant) async {
    Firestore.instance
        .collection("Connaissance")
        .document('$codeAmi-$codeUtilisateurCourant')
        .delete();
    Firestore.instance
        .collection("Connaissance")
        .document('$codeUtilisateurCourant-$codeAmi')
        .delete();
  }

  Future<bool> addFriend(String codeUtilisateur, String codeAmi) async {
    try {
      //Ajout d'un ami dans la BD
      Firestore.instance
          .collection('Connaissance')
          .document('$codeAmi-$codeUtilisateur')
          .setData({'codeAmi': codeAmi, 'codeUtilisateur': codeUtilisateur});

      //L'Ajout se fait aussi dans l'autre sens
      Firestore.instance
          .collection('Connaissance')
          .document('$codeUtilisateur-$codeAmi')
          .setData({'codeAmi': codeUtilisateur, 'codeUtilisateur': codeAmi});

      //Création de la discussion entre les deux utilisateurs
      Firestore.instance
          .collection('Discussion')
          .document('$codeUtilisateur-$codeAmi')
          .setData({
        'codeDiscussion': '$codeUtilisateur-$codeAmi',
        'titreDiscussion': 'Une discussion',
      });

      //Ajout des personnes à la discussion
      addUserToDiscussion('$codeUtilisateur-$codeAmi', codeUtilisateur);
      addUserToDiscussion('$codeUtilisateur-$codeAmi', codeAmi);
    } on Exception {
      return false;
    }

    return true;
  } //Fin addFriend

  //Méthode d'ajout d'un ami tiré aléatoirement
  // même problème qu'avec getPseudo et getPhoto
  Future<String> addRandomFriend(String userId) async {
    //On commence par récupérer les amis
    var queryFriends = Firestore.instance
        .collection('Connaissance')
        .where('codeUtilisateur', isEqualTo: userId)
        .getDocuments();

    //On crée une liste d'identifiants à ne pas tirer au sort (amis et utilisateur courant)
    List<String> friendsYet;
    queryFriends.then((q) =>
        {q.documents.forEach((doc) => friendsYet.add(doc.data['codeAmi']))});
    friendsYet.add(userId);

    //On récupère l'ensemble des utilisateurs
    var queryAll = Firestore.instance
        .collection('Utilisateur')
        .getDocuments(); //Future<QuerySnapshot>

    //On met leurs identifiants dans une liste
    List<String> possibleFriends;
    queryAll.then((q) => {
          q.documents.forEach((doc) => {
                //On n'ajoute que les utilisateurs à prendre en compte
                if (!friendsYet.contains(doc.data['codeUtilisateur']))
                  {possibleFriends.add(doc.data['codeUtilisateur'])}
              })
        });

    //On tire un utilisateur aléatoirement
    var random = new Random();
    int ind = random.nextInt(possibleFriends.length);
    String newFriendId = possibleFriends.elementAt(ind);

    //Ajout de l'ami
    addFriend(userId, newFriendId);

    return newFriendId; //getPseudoUtilisateur(newFriendId);
  }

  // Ajouter un utilisateur à une discussion
  Future<bool> addUserToDiscussion(
      String codeDiscussion, String codeUtilisateur) async {
    try {
      //Ajout de l'utilisateur à la conversation dans la BD
      Firestore.instance
          .collection('Discussion_Utilisateur')
          .document()
          .setData({
        'codeDiscussion': codeDiscussion,
        'codeUtilisateur': codeUtilisateur,
      });
    } on Exception {
      return false;
    }
    return true;
  } //Fin addUserToDiscussion

  Stream<QuerySnapshot> getMessagesConversation(String groupChatId) {
    //Requête de récupération des 20 derniers messages de la conversation groupChatId
    var snap = Firestore.instance
        .collection('Message')
        .where('codeDiscussion', isEqualTo: groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();

    return snap;
  }

  //Crée le document dans lequel sera stocké le message
  DocumentReference createMessageDocument(String groupChatId) {
    //Le document n'existant pas, il sera créé
    var documentReference = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());

    return documentReference;
  }

  //Remplit le document dans lequel on stocke le message
  Future<bool> completeMessageDocument(
      DocumentReference docRef, codeUtilisateur, peerId, content, type) async {
    try {
      //Transaction pour éviter les concurrences d'accès
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          docRef, //Clé du document
          {
            'idFrom': codeUtilisateur,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      });
    } on Exception {
      return false;
    }

    return true;
  }

  Stream<QuerySnapshot> getConnaissancesId(String idUser) {
    var query = Firestore.instance
        .collection('Connaissance')
        .where('codeUtilisateur', isEqualTo: idUser)
        .snapshots();
    return query;
  }

  // Les requêtes sur lesquelles on boquait nécessitaient en fait des FutureWidgets :

/*##############################################################################*/
/*main.dart :																	*/
/*Le WIDGET aurait dû RESSEMBLER A CA pour que cette méthode fonctionne :	*/
/*##############################################################################*/
/*
return FutureBuilder<String> (
  future: db.getPseudoUtilisateur(document['codeAmi']), //La valeur qu'on veut utiliser
    initialData: 'Loading...', //La valeur par défault qu'on utilise pendant que ça charge
      builder: (BuildContext context, AsyncSnapshot<String> text) {
        return new Text(
            text.data //Le widget retourné une fois que la valeur souhaitée est arrivée
        );
      },
);
*/

/*##############################################################################*/
/*database.dart :																*/
/*getPseudoUtilisateur DOIT RESSEMBLER A CA (plus besoin de variable globale)	*/
/*##############################################################################*/
/*
  Future<String> getPseudoUtilisateur(String code) async {
    var query  = await Firestore.instance
        .collection('Utilisateur')
        .document(code)
        .get();

    var pseudo = await query.data['pseudoUtilisateur'];

    return pseudo;
  }
*/

  //Obtenir le pseudo d'un utilisateur à partir de son code utiisateur
  // ne peut pas être utilisée car envoi de Future<String> en réalité
  String getPseudoUtilisateur(String codeUtilisateur) {
    //Variable qui stockera le résultat de la requête
    var query;

    try {
      //Requête pour récupérer le document concernant l'utilisateur
      query = Firestore.instance
          .collection(
              'Utilisateur') //Ciblage de la table (ou collection) Utilisateur
          .where('codeUtilisateur', isEqualTo: codeUtilisateur)
          .snapshots();
      //.document(
      //  codeUtilisateur); //Ciblage du document identifié par le codeUtilisateur passé en paramètre
    } on Exception {
      return "erreur"; //Si il y a un erreur lors de la requête, on retourne une chaine vide
    }

    var pseudo;

    //TEST 1
    query.forEach(
      (snap) => {pseudo = snap.value['pseudoUtilisateur'].toString()},
    );

    //TEST 2
    /*query.forEach(
        (snap) => {pseudo = snap.document['pseudoUtilisateur'].toString()},
    );*/

    //TEST 3
    /*query.forEach(
          (snap) => {pseudo = snap.getDocument()['pseudoUtilisateur'].toString()},
    );*/

    return pseudo;
  }

  //Obtenir l'url de la photo de profil à partir du codeUtilisateur
  // même problème que getPseudo
  String getPhotoUtilisateur(String userId) {
    var query;
    try {
      query = Firestore.instance
          .collection('Utilisateur')
          .where('codeUtiisateur', isEqualTo: userId); //document(userId);
    } on Exception {
      return "erreur";
    }
    return query['photoUrl'];
  }

  //Méthode de suppression d'un message dans la table prévue au départ
  /*Future<bool> deleteMessage(String idMsg) async {
    var query =
        Firestore.instance.collection('messages').document(idMsg).delete();

    bool success = true;

    query.then((val) => success = true).catchError((error) => success = false);

    return success;
  }*/

  // Nouvelle méthode avec la table actuelle : messages, fonctionne
  Future<Null> deleteMessage(String idMsg, String groupChatId) async {
    Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .document(idMsg)
        .delete();
  }

  // Méthode pour obtenir un utilisateur complet, voir la classe User dans const.dart
  User getSingleUser(String codeUtilisateur) {
    // Un utilisateur qui a tous les attributs (photo, id, pesudo, statut)
    User u;

    // la liste statique que l'on importe qui contient tous les Utilisateurs de la base
    var users = MainScreenState.allUsers;

    int i = 0;
    do {
      i++;
    } while (users[i].getId() != codeUtilisateur && i < users.length);
    u = users[i];
    return u ??
        new User(
            id: 'erreur', photo: 'erreur', pseudo: 'erreur', status: 'erreur');
  }

  // Méthodes de changement de thème
  void changeThemeUser(String codeUser, String codeTheme) {
    Firestore.instance
        .collection('Theme_Utilisateur')
        .document(codeUser)
        .setData({'codeUtilisateur': codeUser, 'codeTheme': codeTheme});
  }

  var clr;
  String getThemeUser(String codeUser) {
    var query = Firestore.instance
        .collection('Theme_Utilisateur')
        .document(codeUser)
        .get();

    query.then((doc) => this.clr = doc.data['codeTheme']);
    return this.clr;
  }
  // Méthodes de changement de langue

  void changeLangueUser(String codeUser, String codeLangue) {
    Firestore.instance
        .collection('Langue_Parle')
        .document(codeUser)
        .setData({'codeUtilisateur': codeUser, 'codeLangue': codeLangue});
  }

  var langue;
  String getLangueUser(String codeUser) {
    var query =
        Firestore.instance.collection('Langue_Parle').document(codeUser).get();
    query.then((doc) => this.langue = doc.data['codeLangue']);
    return this.langue;
  }

  // Renvoyer un utilisateur complet avec tous ses attributs

}
