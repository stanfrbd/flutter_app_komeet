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

class BackendDataBase {

  var pseudo = ""; //Le pseudo ne peut pas être récupéré dans une variable locale

  Future<bool> addFriend(String codeAmi, String codeUtilisateur) async {
    try
    {
      //Ajout d'un ami dans la BD
      Firestore.instance
          .collection('Connaissance')
          .document()
          .setData({
        'codeAmi': codeAmi,
        'codeUtilisateur': codeUtilisateur
      });

      //L'Ajout se fait aussi dans l'autre sens
      Firestore.instance
          .collection('Connaissance')
          .document()
          .setData({
        'codeAmi': codeUtilisateur,
        'codeUtilisateur': codeAmi
      });

      //Création de la discussion entre les deux utilisateurs
      Firestore.instance
          .collection('Discussion')
          .document()
          .setData({
        'codeDiscussion': '$codeUtilisateur-$codeAmi',
        'titreDiscussion': 'Une discussion',
      });

      //Ajout des personnes à la discussion
      addUserToDiscussion('$codeUtilisateur-$codeAmi', codeUtilisateur);
      addUserToDiscussion('$codeUtilisateur-$codeAmi', codeAmi);
    }
    on Exception
    {
      return false;
    }
    return true;
  } //Fin addFriend



  Future<bool> addUserToDiscussion(String codeDiscussion, String codeUtilisateur) async {
    try
    {
      //Ajout de l'utilisateur à la conversation dans la BD
      Firestore.instance
          .collection('Discussion_Utilisateur')
          .document()
          .setData({
        'codeDiscussion': codeDiscussion,
        'codeUtilisateur': codeUtilisateur,
      });
    }
    on Exception
    {
      return false;
    }
    return true;
  } //Fin addUserToDiscussion


  //Obtenir le pseudo d'un utilisateur à partir de son code utiisateur
  // /!\ On utilise une variable globale car une variable locale ne permet pas de stocker la valeur du champ /!\
  String getPseudoUtilisateur(String codeUtilisateur) {
    //Variable qui stockera le résultat de la requête
    var query;

    try {
      //Requête pour récupérer le document concernant l'utilisateur
      query = Firestore.instance
          .collection('Utilisateur') //Ciblage de la table (ou collection) Utilisateur
          .document(codeUtilisateur); //Ciblage du document identifié par le codeUtilisateur passé en paramètre
    }
    on Exception {
      return ""; //Si il y a un erreurlors de la requête, on retourne une chaine vide
    }

    //Extraire de ce document le champs n°3 (correspondant au pseudo)
    query.snapshots().listen(
            (data) => this.pseudo = ('${data.data.values.elementAt(3)}')
    );

    //Retour sans erreur
    return this.pseudo;
  }

  Future<Stream> getMessagesConversation(String groupChatId) async {
    //Requête de récupération des 20 derniers messages de la conversation groupChatId
    var snap = Firestore.instance
        .collection('Message')
        .where('codeDiscussion', isEqualTo: groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();

    return snap;
  }
}
