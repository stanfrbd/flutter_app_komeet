# flutter_app_komeet

Projet tutoré

### Avant toute chose

* `git clone https://github.com/stanfrbd/flutter_app_komeet` ou `download zip`

* **Dans le cas où on `download zip` il faut renommer `flutter_app_komeet-master` en `flutter_app_komeet`**

* ***Dans le cas contraire erreur à la compilation `packages not found`***

* `flutter packages get` à la racine du projet ou dans Android Studio

## Contenu

***Le projet en lui-même fait 340 Mo***

**d'où l'intérêt du .gitignore**

### Ne surtout pas modifier

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

* Les réglages de firebase sont à manipuler avec précautions 
* Je vais faire la doc pour que vous puissiez voir tout
* Google Sign in fonctionne sur iOS mais aucun message n'est vu (normal les variables ne sont pas encore changées)

