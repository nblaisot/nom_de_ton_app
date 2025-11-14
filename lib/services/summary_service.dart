/// Abstract service for generating book summaries
/// 
/// This interface allows for different implementations:
/// - OpenAISummaryService: Uses OpenAI API
/// - MistralSummaryService: Uses Mistral AI API
abstract class SummaryService {
  /// Generate a summary for the given text content
  /// 
  /// [text] - The text content to summarize
  /// [language] - The language code ('fr' or 'en')
  /// Returns the generated summary
  Future<String> generateSummary(String text, String language);

  /// Check if the service is available and ready to use
  Future<bool> isAvailable();

  /// Get the name of the service for display purposes
  String get serviceName;
}



