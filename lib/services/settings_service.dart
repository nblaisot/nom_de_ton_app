import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _languageKey = 'selected_language';
  static const String _fontSizeKey = 'font_size';
  static const String _readerFontScaleKey = 'reader_font_scale';
  static const String _horizontalPaddingKey = 'horizontal_padding';
  static const String _verticalPaddingKey = 'vertical_padding';
  static const double _defaultFontSize = 18.0;
  static const double _minFontSize = 12.0;
  static const double _maxFontSize = 32.0;
  static const double _defaultHorizontalPadding = 30.0;
  static const double _defaultVerticalPadding = 50.0;
  static const double _minPadding = 0.0;
  static const double _maxPadding = 100.0;

  /// Get the saved language preference
  Future<Locale?> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null; // null means use system default
  }

  /// Save language preference
  Future<void> saveLanguage(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (locale == null) {
      await prefs.remove(_languageKey);
    } else {
      await prefs.setString(_languageKey, locale.languageCode);
    }
  }

  /// Get current language code (null for system default)
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  /// Get saved font size (default: 18.0)
  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? _defaultFontSize;
  }

  /// Save font size preference
  Future<void> saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    // Clamp font size to valid range
    final clampedSize = fontSize.clamp(_minFontSize, _maxFontSize);
    await prefs.setDouble(_fontSizeKey, clampedSize);
  }

  /// Load the reader font scale preset (-1 = smaller, 0 = normal, 1 = larger)
  Future<int> getReaderFontScalePreset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_readerFontScaleKey) ?? 0;
  }

  /// Persist the reader font scale preset (-1 = smaller, 0 = normal, 1 = larger)
  Future<void> saveReaderFontScalePreset(int preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_readerFontScaleKey, preset.clamp(-1, 1));
  }

  /// Get min font size
  double get minFontSize => _minFontSize;

  /// Get max font size
  double get maxFontSize => _maxFontSize;

  /// Get default font size
  double get defaultFontSize => _defaultFontSize;

  /// Get saved horizontal padding (default: 30.0 pixels)
  Future<double> getHorizontalPadding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_horizontalPaddingKey) ?? _defaultHorizontalPadding;
  }

  /// Save horizontal padding preference
  Future<void> saveHorizontalPadding(double padding) async {
    final prefs = await SharedPreferences.getInstance();
    // Clamp padding to valid range
    final clampedPadding = padding.clamp(_minPadding, _maxPadding);
    await prefs.setDouble(_horizontalPaddingKey, clampedPadding);
  }

  /// Get saved vertical padding (default: 50.0 pixels)
  Future<double> getVerticalPadding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_verticalPaddingKey) ?? _defaultVerticalPadding;
  }

  /// Save vertical padding preference
  Future<void> saveVerticalPadding(double padding) async {
    final prefs = await SharedPreferences.getInstance();
    // Clamp padding to valid range
    final clampedPadding = padding.clamp(_minPadding, _maxPadding);
    await prefs.setDouble(_verticalPaddingKey, clampedPadding);
  }

  /// Get min padding
  double get minPadding => _minPadding;

  /// Get max padding
  double get maxPadding => _maxPadding;

  /// Get default horizontal padding
  double get defaultHorizontalPadding => _defaultHorizontalPadding;

  /// Get default vertical padding
  double get defaultVerticalPadding => _defaultVerticalPadding;
}

