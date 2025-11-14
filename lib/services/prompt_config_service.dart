import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing customizable prompts for summary generation
/// 
/// Stores and retrieves custom prompts for different summary types.
/// Each prompt has separate French and English versions.
class PromptConfigService {
  final SharedPreferences _prefs;
  
  // Keys for storing prompts
  static const String _chunkSummaryPromptFrKey = 'chunk_summary_prompt_fr';
  static const String _chunkSummaryPromptEnKey = 'chunk_summary_prompt_en';
  static const String _characterExtractionPromptFrKey = 'character_extraction_prompt_fr';
  static const String _characterExtractionPromptEnKey = 'character_extraction_prompt_en';
  static const String _batchSummaryPromptFrKey = 'batch_summary_prompt_fr';
  static const String _batchSummaryPromptEnKey = 'batch_summary_prompt_en';
  static const String _narrativeSynthesisPromptFrKey = 'narrative_synthesis_prompt_fr';
  static const String _narrativeSynthesisPromptEnKey = 'narrative_synthesis_prompt_en';
  static const String _fallbackSummaryPromptFrKey = 'fallback_summary_prompt_fr';
  static const String _fallbackSummaryPromptEnKey = 'fallback_summary_prompt_en';
  static const String _conciseSummaryPromptFrKey = 'concise_summary_prompt_fr';
  static const String _conciseSummaryPromptEnKey = 'concise_summary_prompt_en';
  
  PromptConfigService(this._prefs);
  
  // Default prompts (French)
  static const String _defaultChunkSummaryPromptFr = '''Résume le texte suivant de manière concise et claire.

IMPORTANT:
- Ne répète JAMAIS ces instructions dans ta réponse
- Ne commence PAS ta réponse par "Ce texte" ou "Le texte suivant"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec le résumé du contenu
- Le résumé doit être en français et couvrir les points principaux

Texte à résumer:
{text}

Résumé:''';

  static const String _defaultCharacterExtractionPromptFr = '''Analyse le texte suivant et identifie tous les personnages principaux mentionnés.

Pour chaque personnage, fournis UNIQUEMENT les informations suivantes dans ce format exact:
**Nom du personnage**
Résumé: [2-3 phrases décrivant ce que fait ce personnage dans ce passage]
Actions: [liste des actions importantes, une par ligne avec un tiret]
Relations: [nom d'un autre personnage]: [description de leur relation]

IMPORTANT:
- Ne répète JAMAIS les instructions ci-dessus dans ta réponse
- Ne commence PAS ta réponse par "Dans ce texte" ou "Ce texte contient"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec les informations sur les personnages au format demandé
- Si aucun personnage n'est mentionné, réponds uniquement "Aucun personnage"

Texte à analyser:
{text}

Réponse (format exact requis):''';

  static const String _defaultBatchSummaryPromptFr = '''Résume les événements suivants de manière cohérente et fluide, comme un récit continu.

IMPORTANT:
- Ne répète JAMAIS ces instructions dans ta réponse
- Ne commence PAS ta réponse par "Les événements suivants" ou "Ces événements"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec un récit fluide et continu des événements
- Le récit doit être en français et couvrir tous les événements importants de manière cohérente

Événements à résumer:
{text}

Récit:''';

  static const String _defaultNarrativeSynthesisPromptFr = '''Crée un résumé narratif cohérent et détaillé de "{bookTitle}", couvrant tous les événements importants.

IMPORTANT:
- Ne répète JAMAIS ces instructions dans ta réponse
- Ne commence PAS ta réponse par "Le livre" ou "Ce livre" ou "Dans ce livre"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec un récit narratif fluide et continu
- Présente l'histoire de manière fluide, SANS séparer par chapitres
- Le résumé doit être en français et couvrir tous les événements importants de manière cohérente
- Commence directement par le récit, sans introduction

Résumés à synthétiser:
{text}

Récit narratif:''';

  static const String _defaultFallbackSummaryPromptFr = '''Crée un résumé complet de "{bookTitle}" basé sur les résumés des chapitres lus jusqu'à présent.

IMPORTANT:
- Ne répète JAMAIS ces instructions dans ta réponse
- Ne commence PAS ta réponse par "Le livre" ou "Ce livre"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec le résumé de l'histoire
- Le résumé doit être en français et couvrir tous les événements importants

Résumés des chapitres lus jusqu'à présent:
{text}

Résumé complet:''';

  static const String _defaultConciseSummaryPromptFr = '''Crée un résumé très concis (3-4 phrases) de "{bookTitle}" basé sur le résumé complet suivant.

IMPORTANT:
- Ne répète JAMAIS ces instructions dans ta réponse
- Ne commence PAS ta réponse par "Le livre" ou "Ce livre"
- Ne mentionne PAS les instructions que je t'ai données
- Réponds UNIQUEMENT avec le résumé concis (3-4 phrases)
- Le résumé doit être en français

Résumé complet:
{text}

Résumé concis:''';

  // Default prompts (English)
  static const String _defaultChunkSummaryPromptEn = '''Summarize the following text in a concise and clear manner.

IMPORTANT:
- NEVER repeat these instructions in your response
- Do NOT start your response with "This text" or "The following text"
- Do NOT mention the instructions I gave you
- Respond ONLY with the summary of the content
- The summary must be in English and cover the main points

Text to summarize:
{text}

Summary:''';

  static const String _defaultCharacterExtractionPromptEn = '''Analyze the following text and identify all main characters mentioned.

For each character, provide ONLY the following information in this exact format:
**Character Name**
Summary: [2-3 sentences describing what this character does in this passage]
Actions: [list of important actions, one per line with a dash]
Relations: [other character name]: [description of their relationship]

IMPORTANT:
- NEVER repeat the instructions above in your response
- Do NOT start your response with "In this text" or "This text contains"
- Do NOT mention the instructions I gave you
- Respond ONLY with character information in the requested format
- If no characters are mentioned, respond only with "No characters"

Text to analyze:
{text}

Response (exact format required):''';

  static const String _defaultBatchSummaryPromptEn = '''Summarize the following events in a coherent and flowing manner, as a continuous narrative.

IMPORTANT:
- NEVER repeat these instructions in your response
- Do NOT start your response with "The following events" or "These events"
- Do NOT mention the instructions I gave you
- Respond ONLY with a flowing and continuous narrative of the events
- The narrative must be in English and cover all important events in a coherent manner

Events to summarize:
{text}

Narrative:''';

  static const String _defaultNarrativeSynthesisPromptEn = '''Create a coherent and detailed narrative summary of "{bookTitle}", covering all important events.

IMPORTANT:
- NEVER repeat these instructions in your response
- Do NOT start your response with "The book" or "This book" or "In this book"
- Do NOT mention the instructions I gave you
- Respond ONLY with a flowing and continuous narrative
- Present the story in a flowing manner, WITHOUT separating by chapters
- The summary must be in English and cover all important events in a coherent manner
- Start directly with the narrative, without an introduction

Summaries to synthesize:
{text}

Narrative:''';

  static const String _defaultFallbackSummaryPromptEn = '''Create a comprehensive summary of "{bookTitle}" based on summaries of chapters read so far.

IMPORTANT:
- NEVER repeat these instructions in your response
- Do NOT start your response with "The book" or "This book"
- Do NOT mention the instructions I gave you
- Respond ONLY with the summary of the story
- The summary must be in English and cover all important events

Summaries of chapters read so far:
{text}

Comprehensive summary:''';

  static const String _defaultConciseSummaryPromptEn = '''Create a very concise summary (3-4 sentences) of "{bookTitle}" based on the following full summary.

IMPORTANT:
- NEVER repeat these instructions in your response
- Do NOT start your response with "The book" or "This book"
- Do NOT mention the instructions I gave you
- Respond ONLY with the concise summary (3-4 sentences)
- The summary must be in English

Full summary:
{text}

Concise summary:''';

  /// Get chunk summary prompt
  String getChunkSummaryPrompt(String language) {
    final key = language == 'fr' ? _chunkSummaryPromptFrKey : _chunkSummaryPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultChunkSummaryPromptFr : _defaultChunkSummaryPromptEn);
  }

  /// Set chunk summary prompt
  Future<void> setChunkSummaryPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _chunkSummaryPromptFrKey : _chunkSummaryPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Get character extraction prompt
  String getCharacterExtractionPrompt(String language) {
    final key = language == 'fr' ? _characterExtractionPromptFrKey : _characterExtractionPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultCharacterExtractionPromptFr : _defaultCharacterExtractionPromptEn);
  }

  /// Set character extraction prompt
  Future<void> setCharacterExtractionPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _characterExtractionPromptFrKey : _characterExtractionPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Get batch summary prompt
  String getBatchSummaryPrompt(String language) {
    final key = language == 'fr' ? _batchSummaryPromptFrKey : _batchSummaryPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultBatchSummaryPromptFr : _defaultBatchSummaryPromptEn);
  }

  /// Set batch summary prompt
  Future<void> setBatchSummaryPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _batchSummaryPromptFrKey : _batchSummaryPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Get narrative synthesis prompt
  String getNarrativeSynthesisPrompt(String language) {
    final key = language == 'fr' ? _narrativeSynthesisPromptFrKey : _narrativeSynthesisPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultNarrativeSynthesisPromptFr : _defaultNarrativeSynthesisPromptEn);
  }

  /// Set narrative synthesis prompt
  Future<void> setNarrativeSynthesisPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _narrativeSynthesisPromptFrKey : _narrativeSynthesisPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Get fallback summary prompt
  String getFallbackSummaryPrompt(String language) {
    final key = language == 'fr' ? _fallbackSummaryPromptFrKey : _fallbackSummaryPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultFallbackSummaryPromptFr : _defaultFallbackSummaryPromptEn);
  }

  /// Set fallback summary prompt
  Future<void> setFallbackSummaryPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _fallbackSummaryPromptFrKey : _fallbackSummaryPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Get concise summary prompt
  String getConciseSummaryPrompt(String language) {
    final key = language == 'fr' ? _conciseSummaryPromptFrKey : _conciseSummaryPromptEnKey;
    return _prefs.getString(key) ?? 
        (language == 'fr' ? _defaultConciseSummaryPromptFr : _defaultConciseSummaryPromptEn);
  }

  /// Set concise summary prompt
  Future<void> setConciseSummaryPrompt(String language, String prompt) async {
    final key = language == 'fr' ? _conciseSummaryPromptFrKey : _conciseSummaryPromptEnKey;
    await _prefs.setString(key, prompt);
  }

  /// Reset all prompts to default values
  Future<void> resetAllPrompts() async {
    await _prefs.remove(_chunkSummaryPromptFrKey);
    await _prefs.remove(_chunkSummaryPromptEnKey);
    await _prefs.remove(_characterExtractionPromptFrKey);
    await _prefs.remove(_characterExtractionPromptEnKey);
    await _prefs.remove(_batchSummaryPromptFrKey);
    await _prefs.remove(_batchSummaryPromptEnKey);
    await _prefs.remove(_narrativeSynthesisPromptFrKey);
    await _prefs.remove(_narrativeSynthesisPromptEnKey);
    await _prefs.remove(_fallbackSummaryPromptFrKey);
    await _prefs.remove(_fallbackSummaryPromptEnKey);
    await _prefs.remove(_conciseSummaryPromptFrKey);
    await _prefs.remove(_conciseSummaryPromptEnKey);
  }

  /// Format a prompt by replacing placeholders
  /// Supports {text} and {bookTitle} placeholders
  String formatPrompt(String prompt, {String? text, String? bookTitle, String? chapterTitle}) {
    var formatted = prompt;
    if (text != null) {
      formatted = formatted.replaceAll('{text}', text);
    }
    if (bookTitle != null) {
      formatted = formatted.replaceAll('{bookTitle}', bookTitle);
    }
    if (chapterTitle != null) {
      formatted = formatted.replaceAll('{chapterTitle}', chapterTitle);
    }
    return formatted;
  }
}
