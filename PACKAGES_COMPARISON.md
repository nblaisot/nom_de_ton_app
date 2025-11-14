# Comparaison des Packages Flutter pour llama.cpp

## Packages Disponibles

### 1. **llama_cpp_dart** ⭐ (Recommandé)

**Version actuelle :** 0.1.2+1 (publié le 9 novembre 2025)

**Caractéristiques :**
- ✅ Support multi-plateforme : iOS, Android, macOS, Linux, Windows
- ✅ Utilise FFI (Foreign Function Interface) pour des performances optimales
- ✅ Support des Isolates pour Flutter (non-bloquant)
- ✅ API de haut niveau orientée objet
- ✅ Wrappers de bas niveau disponibles
- ✅ Actif et régulièrement mis à jour
- ✅ Documentation disponible sur GitHub

**Dépendances :**
- `ffi: ^2.1.4`
- `typed_isolate: ^6.0.0`
- `uuid: ^4.5.1`
- `image: ^4.5.4`

**Repository :** https://github.com/netdur/llama_cpp_dart

**Exemple d'utilisation :**
```dart
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

final loadCommand = LlamaLoad(
  path: "chemin/vers/le/modèle.gguf",
  modelParams: ModelParams(),
  contextParams: ContextParams(),
  samplingParams: SamplerParams(),
  format: ChatMLFormat(),
);

final llamaParent = LlamaParent(loadCommand);
await llamaParent.init();

llamaParent.stream.listen((response) => print(response));
llamaParent.sendPrompt("Résume ce texte...");
```

**Avantages :**
- ✅ Mature et bien maintenu
- ✅ Support complet des plateformes mobiles
- ✅ API moderne et facile à utiliser
- ✅ Support du streaming
- ✅ Isolates pour éviter de bloquer l'UI

**Inconvénients :**
- ⚠️ Nécessite de compiler llama.cpp pour chaque plateforme
- ⚠️ Documentation peut être améliorée

---

### 2. **fllama**

**Version actuelle :** 0.0.1 (publié le 12 novembre 2024)

**Caractéristiques :**
- ✅ Support : Android, iOS, OpenHarmonyOS/HarmonyOS
- ✅ Utilise des canaux de plateforme (MethodChannel)
- ✅ Plus récent mais moins mature

**Repository :** https://github.com/xuegao-tzx/fllama

**Avantages :**
- ✅ Plus simple à intégrer (canaux de plateforme)
- ✅ Support OpenHarmonyOS

**Inconvénients :**
- ⚠️ Version très récente (0.0.1)
- ⚠️ Moins de documentation
- ⚠️ Moins de fonctionnalités
- ⚠️ Moins testé

---

### 3. **dart_llama**

**Caractéristiques :**
- ✅ Liaisons FFI de bas niveau
- ✅ Support du streaming
- ✅ API de bas niveau pour contrôle total

**Avantages :**
- ✅ Contrôle total sur la génération
- ✅ Support du streaming

**Inconvénients :**
- ⚠️ API de bas niveau (plus complexe)
- ⚠️ Moins adapté pour Flutter

---

### 4. **llama_cpp**

**Caractéristiques :**
- ✅ Liaison Dart directe
- ✅ Support de la mémoire mappée

**Avantages :**
- ✅ Simple

**Inconvénients :**
- ⚠️ Moins de fonctionnalités
- ⚠️ Moins maintenu

---

### 5. **fcllama**

**Caractéristiques :**
- ✅ Utilise des canaux de plateforme

**Avantages :**
- ✅ Simple

**Inconvénients :**
- ⚠️ Moins de documentation
- ⚠️ Moins maintenu

---

## Recommandation

### Pour votre projet MemoReader, je recommande **llama_cpp_dart** pour les raisons suivantes :

1. **Maturité** : Version 0.1.2+1, régulièrement mise à jour
2. **Support mobile** : iOS et Android bien supportés
3. **Performance** : Utilise FFI pour des performances optimales
4. **Isolates** : Support des isolates pour éviter de bloquer l'UI Flutter
5. **API moderne** : API de haut niveau facile à utiliser
6. **Streaming** : Support du streaming pour une meilleure UX

### Étapes d'intégration avec llama_cpp_dart

1. **Ajouter la dépendance :**
   ```yaml
   dependencies:
     llama_cpp_dart: ^0.1.2
   ```

2. **Compiler llama.cpp pour iOS et Android :**
   - Le package inclut déjà llama.cpp dans son code source
   - Nécessite de compiler les bibliothèques natives pour chaque plateforme
   - Consulter la documentation du package pour les instructions

3. **Intégrer dans LocalSummaryService :**
   - Utiliser `LlamaParent` pour charger le modèle
   - Utiliser `sendPrompt()` pour générer des résumés
   - Écouter le stream pour recevoir les réponses

## Prochaines Étapes

1. ✅ Architecture créée
2. ✅ Service OpenAI fonctionnel
3. ⏳ Intégrer llama_cpp_dart
4. ⏳ Télécharger et intégrer le modèle TinyLlama
5. ⏳ Implémenter l'inférence LLM dans LocalSummaryService
6. ⏳ Tester sur iOS et Android

## Ressources

- **llama_cpp_dart** : https://pub.dev/packages/llama_cpp_dart
- **GitHub llama_cpp_dart** : https://github.com/netdur/llama_cpp_dart
- **TinyLlama GGUF** : https://huggingface.co/marroyo777/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF
- **Documentation llama.cpp** : https://github.com/ggerganov/llama.cpp





