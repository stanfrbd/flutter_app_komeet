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



}
