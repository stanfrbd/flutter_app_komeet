# flutter_app_komeet

Projet tutoré Komeet

## Contenu

***Le projet en lui-même fait 340 Mo***

**d'où l'intérêt du .gitignore**

### Ne surtout pas modifier 

* `pubspecs.yaml`
* `google-services.json`

**Les plugins suivants doivent être installés et configurés dans le path (Android Studio et OS)**

`flutter`
`dart`
`firebase`

**J'utilise dans cette version ma version de firebase, elle sera changée ensuite**

### Avant toute chose

run `flutter packages get`à la racine du projet

# Compilation

* La compilation fonctionne mais **Google Sign In** ne fonctionne pas
* Si vous voulez tester des requêtes avec la base de données 

mettez en commentaire le `if(firebaseuser != NULL) {` et le `}` de fin de `login.dart`  mais pas le contenu : cela affichera les données de la BD sans être connecté en tant qu'utilisateur

