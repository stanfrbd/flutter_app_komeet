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

  Future<bool> addFriend(String codeAmi, String codeUtilisateur) async {
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



  Stream getMessagesConversation(String groupChatId) {
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

  //Récupérer les ID des connaissances
  List<String> getConnaissancesId(String idUser) {
    List<String> ids; //liste des ids des amis

    var query = Firestore.instance
        .collection('Connaissance')
        .where('codeUtilisateur', isEqualTo: idUser);

    //A FAIRE POUR CHAQUE DOCUMENT MAIS COMMENT ???????????????????????????????
    //ids.add(query['codeAmi']);

    //query.snapshots().listen(
    //    (data) => ids.add('${data.documents.}')
    //);
    //data['codeAmi'];

    //for(int index =0;index<nbAmis;index++)
    //{
      //ids.add(query.snapshots().//elementAt(index)['codeAmi']);
    //}
    //query.snapshots().forEach(
    //    (QuerySnap) => ids.add(QuerySnap.)
    //);
    //query.getDocuments().then(
    //    (qrySnap)=> ids.add(qrySnap.toString())
    //);
    //query['codeAmi'];
    //query.snapshots().forEach(
    //    (QrySnap) => ids.add(Q)
    //)
    return ids;
  }

  //Obtenir le pseudo d'un utilisateur à partir de son code utiisateur
  String getPseudoUtilisateur(String codeUtilisateur) {
    //Variable qui stockera le résultat de la requête
    var query;

    try {
      //Requête pour récupérer le document concernant l'utilisateur
      query = Firestore.instance
          .collection('Utilisateur') //Ciblage de la table (ou collection) Utilisateur
          .document(codeUtilisateur); //Ciblage du document identifié par le codeUtilisateur passé en paramètre
    } on Exception {
      return ""; //Si il y a un erreur lors de la requête, on retourne une chaine vide
    }

    return query['pseudoUtilisateur'];
  }

  //Obtenir l'url de la photo de profil à partir du codeUtilisateur
  String getPhotoUtilisateur(String userId) {
    var query;
    try {
      query = Firestore.instance
          .collection('Utilisateur')
          .document(userId);
    }
    on Exception {
      return "";
    }
    return query['photoUrl'];
  }
}
