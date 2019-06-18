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
import 'dart:math' show Random;

// ------------------------------------------------
// Classe des méthodes back-end de firebase
// ------------------------------------------------

class DataBase {
  //Methode de suppression d'un contact
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

  //Méthode d'ajout d'un ami
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

  //Méthode d'ajout d'un ami à une discussion
  Future<bool> addUserToDiscussion(
      String codeDiscussion, String codeUtilisateur) async {
    try {
      //Ajout de l'utilisateur à la conversation dans la BD
      Firestore.instance
          .collection('Discussion_Utilisateur')
          .document('$codeDiscussion-$codeUtilisateur')
          .setData({
        'codeDiscussion': codeDiscussion,
        'codeUtilisateur': codeUtilisateur,
      });
    } on Exception {
      return false;
    }
    return true;
  } //Fin addUserToDiscussion

  //Méthode de récupération des messages d'une conversation
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

  //Rempli le document dans lequel on stocke le message
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

  //Retourne un stream sur l'ensemble des identifiants des amis
  Stream<QuerySnapshot> getConnaissancesId(String idUser) {
    var query = Firestore.instance
        .collection('Connaissance')
        .where('codeUtilisateur', isEqualTo: idUser)
        .snapshots();
    return query;
  }

  //Obtenir le pseudo d'un utilisateur à partir de son code utiisateur
  String getPseudoUtilisateur(String codeUtilisateur) {
    //Variable qui stockera le résultat de la requête
    String toto = "Chaîne vide";
    var query;

    try {
      //Requête pour récupérer le document concernant l'utilisateur
      query = Firestore.instance
          .collection(
              'Utilisateur') //Ciblage de la table (ou collection) Utilisateur
          .where('codeUtilisateur', isEqualTo: codeUtilisateur)
          .getDocuments();
      //.document(
      //  codeUtilisateur); //Ciblage du document identifié par le codeUtilisateur passé en paramètre
    } on Exception {
      return "erreur"; //Si il y a un erreur lors de la requête, on retourne une chaine vide
    }

    var pseudo;

    query.then((q) =>
        {q.documents.forEach((doc) => pseudo = doc.data['pseudoUtilisateur'])});

    return pseudo ?? toto;
  }

  //Obtenir l'url de la photo de profil à partir du codeUtilisateur
  String getPhotoUtilisateur(String userId) {
    var query;
    try {
      //récupération du document de l'utilisateur
      query = Firestore.instance
          .collection('Utilisateur')
          .document(userId)
          .get(); //document(userId);
    } on Exception {
      return "erreur";
    }
    var url = "";
    //Récupération de l'url dans ce document
    query.then((doc) => url = doc.data['photoUrl']);

    return url;
  }

  //Méthode d'ajout d'un ami tiré aléatoirement
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
          q.documents.forEach(
              (doc) => possibleFriends.add(doc.data['codeUtilisateur']))
        });

    //On retire les utilisateurs à ne pas tirer au sort
    possibleFriends.forEach((f) => {
          if (friendsYet.contains(f)) {possibleFriends.remove(f)}
        });

    //On tire un utilisateur aléatoirement
    var random = new Random();
    int ind = random.nextInt(possibleFriends.length);
    String newFriendId = possibleFriends.elementAt(ind);

    //Ajout de l'ami
    addFriend(userId, newFriendId);

    return newFriendId; //getPseudoUtilisateur(newFriendId);
  }

  //Méthode de suppression d'un message
  Future<bool> deleteMessage(String idMsg) async {
    var query =
        Firestore.instance.collection('Message').document(idMsg).delete();

    bool success = true;

    query.then((val) => success = true).catchError((error) => success = false);

    return success;
  }
}
