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

  bool addFriend(String codeAmi, String codeUtilisateur) {

    // ajout d'un ami en back-end
    Firestore.instance
        .collection('Connaissance')
        .document()
        .setData({
      'codeAmi': codeAmi,
      'codeUtilisateur': codeUtilisateur
    });
    return true;
  }

  String getcodeUtilisateur(String pseudoUtilisateur) {
    String codeUtilisateur = '';
    // requête à implémenter
    return codeUtilisateur;
  }
}
