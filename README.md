# Komeet

Projet tutoré S2 - Application en réseau - Dart - Flutter - Firebase

Rémi T. - Josquin I. - Antoine D-G. - Stanislas M.

<img src="https://user-images.githubusercontent.com/44167150/59147905-bfdc5880-8a01-11e9-9151-7425f80d2143.png" alt="drawing" width="200"/>

## Avant toute chose
* `flutter`doit être à jour et sans erreur !
<img src="https://user-images.githubusercontent.com/44167150/59148837-e30d0500-8a0d-11e9-9f1d-63894e55ff57.png" alt="drawing" width="500"/>

* `git clone https://github.com/stanfrbd/flutter_app_komeet` ou `download zip`

* **Dans le cas où on `download zip` il faut renommer `flutter_app_komeet-master` en `flutter_app_komeet`**

* ***Dans le cas contraire erreur à la compilation `packages not found`***

* `flutter packages get` à la racine du projet ou dans Android Studio

## Contenu

***Le projet en lui-même fait 340 Mo***

**d'où l'intérêt du .gitignore**

## Ne surtout pas modifier

* `pubspecs.yaml` 
* `google-services.json` 
* `AndroidManifest.xml` 
* `build.gradle`(les deux) 
* `GoogleServices-Info.plist`
* `Podfile` 

**Les plugins suivants doivent être installés et configurés dans le path (Android Studio et OS)**

`flutter`
`dart`
`firebase`

**Version changée de firebase : celle de Rémi**


# Compilation

* Attention à bien avoir tous les packages et les dependencies
* Si vous voulez nettoyer le projet :
* `flutter clean` à la racine du projet
* Si vous n'avez pas envie de lancer Android Studio mais que vous voulez debug le projet : 
* `flutter analyze` à la racine du projet permet de voir s'il y a des erreurs
* `flutter run` (compile sans Android Studio) **à condition d'avoir une VM allumée ou un appareil branché**

# Firebase

* Les réglages de firebase sont à manipuler avec précautions (clé SHA-1, ajout d'app, fichiers config...)
* Mieux vaut utiliser pour l'instant firebase avec Google Sign In qui fonctionne

