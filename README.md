# Komeet

Projet tutoré S2 - Application en réseau - Dart - Flutter - Firebase

Rémi T. - Josquin I. - Antoine D-G. - Stanislas M. 

[**Wiki !!!** 👍 ](https://github.com/stanfrbd/flutter_app_komeet/wiki)

## Fonctionnalités
### Fonctionnalités principales
* Envoyer et recevoir des messages **[fonctionnel]**
* Ajouter des amis **[fonctionnel]**
* Supprimer des amis **[fonctionnel]**
* Rechercher des utilisateurs avec leur unique pseudonyme (sensible à la casse) **[fonctionnel]**
* Mettre à jour ses informations (pseudo, photo, statut) **[fonctionnel]**
* Supprimer son compte **[fonctionnel]**
* Se connecter / se déconnecter en conservant son profil **[fonctionnel]**
### Fonctionnalités secondaires
* Envoyer des photos **[fonctionnel sur iPhone, exception image-picker sur Android ?]** [Issue #24859, Flutter Team](https://github.com/flutter/flutter/issues/24859)
* Changer les couleurs **[fonctionnel]**
* Mettre en mode sombre **[fonctionnel]**
* Copier / coller des messages **[fonctionnel]**
* Notifications in-app **[En cours, ne sera peut-être pas ajouté]**
* Timers **[optionnel, ne sera peut-être pas ajouté]**
* Ajouter aléatoirement des personnes **[optionnel, ne sera peut-être pas ajouté]**

<img src="https://user-images.githubusercontent.com/44167150/59147905-bfdc5880-8a01-11e9-9151-7425f80d2143.png" alt="drawing" width="200"/>

<img src="https://user-images.githubusercontent.com/44167150/59149702-494b5500-8a19-11e9-870a-c040668dc66a.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149703-4b151880-8a19-11e9-9c14-6b11d620406a.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149705-4d777280-8a19-11e9-9974-3ada86e81c2e.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149706-4fd9cc80-8a19-11e9-9bf2-4705c074b7a0.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149707-52d4bd00-8a19-11e9-9673-27836fc718e2.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149710-55cfad80-8a19-11e9-92b2-3e4261f85195.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59452626-6b284b80-8e0e-11e9-85c2-a36e6c9e7312.png" width="200"/>
<img src="https://user-images.githubusercontent.com/44167150/59163112-7886c280-8afc-11e9-8638-1a396e108846.png" width="200"/>

<img src="https://user-images.githubusercontent.com/44167150/59163130-d61b0f00-8afc-11e9-851b-13f1bf734f6c.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149715-5a946180-8a19-11e9-9ca1-b88b20e74b27.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149716-5e27e880-8a19-11e9-9e87-c77d1952ca1d.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149719-62540600-8a19-11e9-86b8-8c7c1d226b83.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149725-6da73180-8a19-11e9-8d9e-367637be3c66.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149720-64b66000-8a19-11e9-8162-22a95931e49d.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59149723-6aac4100-8a19-11e9-9fc7-3a2c9843543b.png" width="200"/><img src="https://user-images.githubusercontent.com/44167150/59452616-6499d400-8e0e-11e9-8188-294ea6ddb37d.png" width="200"/>

## Avant toute chose
* `flutter`doit être à jour et sans erreur !
* `flutter doctor -v`

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

Fichier de dépendances `flutter`.

* `google-services.json` 

Fichier de configuration Firebase

* `AndroidManifest.xml` 

Fichier de propriétés de l'application.

* `build.gradle`(les deux) 

Fichiers de compilation

* `GoogleServices-Info.plist`

Fichier de configuration `Firebase` (iOS uniquement).

* `Podfile` 

Fichier de dépendances `cocoapods` généré avec `pubspecs.yaml` (iOS uniquement).

**Les plugins suivants doivent être installés et configurés dans le path (Android Studio et OS)**

`flutter`
`dart`

**Version changée de firebase : celle de Rémi**


# Compilation

* Attention à bien avoir tous les packages et les dependencies
* Si vous voulez nettoyer le projet :
* `flutter clean` à la racine du projet (supprime le dossier de compilation et son contenu)
* Si vous n'avez pas envie de lancer Android Studio mais que vous voulez debug le projet : 
* `flutter analyze` à la racine du projet permet de voir s'il y a des erreurs
* `flutter run` (compile sans Android Studio) **à condition d'avoir une VM allumée ou un appareil branché**
* `flutter build apk` pour générer une * `apk`.

# Firebase

* Les réglages de firebase sont à manipuler avec précautions (clé SHA-1, ajout d'app, fichiers config...)
* Mieux vaut utiliser pour l'instant firebase avec Google Sign In qui fonctionne

