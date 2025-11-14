# Architecture de Résumé avec LLM Local et OpenAI

## Vue d'ensemble

L'application MemoReader supporte maintenant deux modes de génération de résumés :
1. **Local (TinyLlama)** : Utilise un modèle LLM local via llama.cpp, fonctionne hors ligne
2. **OpenAI (GPT)** : Utilise l'API OpenAI, nécessite une connexion Internet et une clé API

## Architecture

### Services

#### `SummaryService` (Interface abstraite)
- `generateSummary(String text, String language)` : Génère un résumé
- `isAvailable()` : Vérifie si le service est disponible
- `serviceName` : Nom du service pour l'affichage

#### `LocalSummaryService`
- Implémente `SummaryService`
- Utilise TinyLlama via llama.cpp (à intégrer)
- Charge le modèle depuis les assets de l'application
- Fonctionne hors ligne

#### `OpenAISummaryService`
- Implémente `SummaryService`
- Utilise l'API OpenAI GPT-3.5-turbo
- Nécessite une clé API configurée par l'utilisateur

#### `SummaryConfigService`
- Gère la configuration et le choix du fournisseur
- Stocke les préférences utilisateur (local ou OpenAI)
- Stocke la clé API OpenAI de manière sécurisée
- Crée et gère les instances des services de résumé

### Interface Utilisateur

#### `SettingsScreen`
- Permet de choisir entre le modèle local et OpenAI
- Permet de configurer la clé API OpenAI
- Affiche l'état de disponibilité de chaque option

#### `ReaderScreen`
- Intègre la génération de résumés via le menu
- Affiche un dialogue de chargement pendant la génération
- Affiche le résumé généré dans un dialogue

## Prochaines Étapes

### 1. Intégrer llama.cpp dans Flutter

**✅ Recommandation : Utiliser `llama_cpp_dart`**

Après recherche, **llama_cpp_dart** est le package le plus adapté :
- Version actuelle : 0.1.2+1 (publié le 9 novembre 2025)
- Support iOS, Android, macOS, Linux, Windows
- Utilise FFI pour des performances optimales
- Support des Isolates pour Flutter (non-bloquant)
- API moderne et facile à utiliser
- Actif et régulièrement mis à jour

```yaml
dependencies:
  llama_cpp_dart: ^0.1.2
```

**Voir PACKAGES_COMPARISON.md pour une comparaison détaillée des packages disponibles.**

### 2. Télécharger et intégrer le modèle TinyLlama

1. Télécharger le modèle depuis Hugging Face :
   - URL : https://huggingface.co/marroyo777/TinyLlama-1.1B-Chat-v1.0-Q4_K_M-GGUF
   - Format : GGUF (quantifié Q4_K_M)
   - Taille : ~700 MB

2. Créer le répertoire `assets/models/` dans le projet

3. Placer le fichier `.gguf` dans `assets/models/`

4. Décommenter la ligne dans `pubspec.yaml` :
   ```yaml
   assets:
     - assets/models/tinyllama-1.1b-chat-v1.0-Q4_K_M.gguf
   ```

### 3. Implémenter l'inférence LLM dans `LocalSummaryService`

Une fois le package `llama_cpp_dart` intégré, mettre à jour `LocalSummaryService.generateSummary()` :

```dart
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

@override
Future<String> generateSummary(String text, String language) async {
  if (!await isAvailable()) {
    throw Exception('Local summary service is not available');
  }

  // Charger le modèle
  final loadCommand = LlamaLoad(
    path: _modelPath!,
    modelParams: ModelParams(),
    contextParams: ContextParams(),
    samplingParams: SamplerParams(),
    format: ChatMLFormat(),
  );

  final llamaParent = LlamaParent(loadCommand);
  await llamaParent.init();

  // Créer le prompt
  final prompt = _buildPrompt(text, language);
  
  // Générer le résumé
  final completer = Completer<String>();
  final buffer = StringBuffer();
  
  llamaParent.stream.listen(
    (response) {
      buffer.write(response);
    },
    onDone: () {
      completer.complete(buffer.toString());
    },
    onError: (error) {
      completer.completeError(error);
    },
  );
  
  llamaParent.sendPrompt(prompt);
  
  return await completer.future;
}
```

### 4. Configuration native (iOS/Android)

#### iOS
- Ajouter les dépendances natives dans `ios/Podfile` si nécessaire
- Configurer les permissions si nécessaire

#### Android
- Ajouter les dépendances natives dans `android/build.gradle` si nécessaire
- Configurer les permissions si nécessaire

## Fichiers Créés/Modifiés

### Nouveaux Fichiers
- `lib/services/summary_service.dart` : Interface abstraite
- `lib/services/local_summary_service.dart` : Service local
- `lib/services/openai_summary_service.dart` : Service OpenAI
- `lib/services/summary_config_service.dart` : Service de configuration
- `lib/screens/settings_screen.dart` : Écran de paramètres

### Fichiers Modifiés
- `lib/screens/reader_screen.dart` : Intégration de la génération de résumés
- `lib/screens/library_screen.dart` : Ajout du bouton paramètres
- `lib/l10n/app_en.arb` : Nouvelles localisations anglaises
- `lib/l10n/app_fr.arb` : Nouvelles localisations françaises
- `pubspec.yaml` : Ajout de la dépendance `http` et configuration des assets

## Notes Importantes

1. **Taille de l'application** : L'inclusion du modèle TinyLlama (~700 MB) augmentera significativement la taille de l'application. Considérer une option de téléchargement à la demande.

2. **Performance** : Le modèle local peut être plus lent que l'API OpenAI, surtout sur des appareils moins puissants. Tester sur différents appareils.

3. **Mémoire** : Le modèle nécessite environ 2-4 GB de RAM. Vérifier la disponibilité avant de charger.

4. **Sécurité** : La clé API OpenAI est stockée dans SharedPreferences. Pour une sécurité accrue, considérer l'utilisation de `flutter_secure_storage`.

5. **Licences** : Vérifier les licences des packages utilisés (llama.cpp, fllama, etc.) pour s'assurer de la compatibilité avec votre projet.

## Tests

Une fois l'intégration complète, tester :
- Génération de résumés avec le modèle local
- Génération de résumés avec OpenAI
- Basculement entre les deux modes
- Gestion des erreurs (modèle non disponible, API key invalide, etc.)
- Performance sur différents appareils

