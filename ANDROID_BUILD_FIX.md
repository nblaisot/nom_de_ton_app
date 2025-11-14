# Solution pour le problème de build Android avec flutter_llama

## Problème
Le package `flutter_llama` publié sur pub.dev cherche `llama.cpp` à un chemin qui n'existe pas :
```
/Users/nblaisot/.pub-cache/hosted/pub.dev/flutter_llama-1.1.2/llama.cpp
```

## Solution : Cloner llama.cpp et créer un lien symbolique

### Étape 1 : Cloner llama.cpp
```bash
cd /Users/nblaisot/development
git clone https://github.com/ggerganov/llama.cpp.git
```

### Étape 2 : Créer un lien symbolique dans le répertoire du plugin
```bash
ln -s /Users/nblaisot/development/llama.cpp /Users/nblaisot/.pub-cache/hosted/pub.dev/flutter_llama-1.1.2/llama.cpp
```

### Étape 3 : Reconstruire
```bash
cd /Users/nblaisot/development/memoreader
flutter clean
flutter pub get
flutter run
```

## Alternative : Modifier le CMakeLists.txt pour utiliser un chemin absolu

Si le lien symbolique ne fonctionne pas, vous pouvez modifier le CMakeLists.txt du plugin :

1. Ouvrir : `/Users/nblaisot/.pub-cache/hosted/pub.dev/flutter_llama-1.1.2/android/src/main/cpp/CMakeLists.txt`
2. Remplacer la ligne 18 :
   ```cmake
   set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../llama.cpp")
   ```
   Par :
   ```cmake
   set(LLAMA_CPP_DIR "/Users/nblaisot/development/llama.cpp")
   ```

**Note** : Cette modification sera perdue si vous exécutez `flutter pub cache repair` ou si le package est mis à jour.

## Solution permanente : Fork du plugin

Pour une solution permanente, vous pourriez :
1. Forker le plugin flutter_llama
2. Ajouter llama.cpp comme submodule Git
3. Utiliser votre fork dans pubspec.yaml

## Alternative : Désactiver temporairement le support Android

Si vous ne voulez pas compiler llama.cpp maintenant, vous pouvez :
1. Commenter `flutter_llama` dans `pubspec.yaml`
2. Utiliser uniquement le service OpenAI pour les résumés
3. Réactiver flutter_llama plus tard quand le problème sera résolu





