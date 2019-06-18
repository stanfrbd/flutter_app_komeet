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

// ------------------------------------------------
// Classe des méthodes back-end de firebase
// ------------------------------------------------

class DataBase {
  // modification de structure, simple proposition,
  // si vous n'êtes pas d'accord on change tout, je ne veux pas imposer

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

  // plus d'attributs pour le copié-collé...
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

    /*try {
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
    }*/
    return true;
  } //Fin addFriend

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

  //Méthode de suppression d'un message
  Future<bool> deleteMessage(String idMsg) async {
    var query =
        Firestore.instance.collection('Message').document(idMsg).delete();

    bool success = true;

    query.then((val) => success = true).catchError((error) => success = false);

    return success;
  }
}
