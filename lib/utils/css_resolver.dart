// CSS parsing and style resolution for EPUB content.
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;

import '../screens/reader/document_model.dart';

/// Resolves CSS styles for HTML elements.
class CssResolver {
  CssResolver({
    Map<String, String>? stylesheets,
  }) : _stylesheets = stylesheets ?? {};

  final Map<String, String> _stylesheets;
  final Map<String, _CssRuleSet> _parsedRules = {};

  /// Add a stylesheet by key (e.g., filename or URL).
  void addStylesheet(String key, String css) {
    _stylesheets[key] = css;
    _parseStylesheet(key, css);
  }

  /// Parse all stylesheets.
  void parseAll() {
    for (final entry in _stylesheets.entries) {
      _parseStylesheet(entry.key, entry.value);
    }
  }

  void _parseStylesheet(String key, String css) {
    try {
      final rules = _parseCssRules(css);
      _parsedRules[key] = _CssRuleSet(rules: rules);
    } catch (e) {
      debugPrint('Failed to parse CSS stylesheet $key: $e');
    }
  }

  List<_CssRule> _parseCssRules(String css) {
    final rules = <_CssRule>[];
    // Remove comments
    final cleaned = css.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    
    // Match rule sets: selector { properties }
    final rulePattern = RegExp(r'([^{]+)\{([^}]+)\}', dotAll: true);
    final matches = rulePattern.allMatches(cleaned);
    
    for (final match in matches) {
      final selector = match.group(1)?.trim() ?? '';
      final propertiesStr = match.group(2)?.trim() ?? '';
      
      if (selector.isEmpty) continue;
      
      final properties = <String, String>{};
      // Parse properties: key: value;
      final propPattern = RegExp(r'([^:;]+):\s*([^;]+);?');
      final propMatches = propPattern.allMatches(propertiesStr);
      
      for (final propMatch in propMatches) {
        final key = propMatch.group(1)?.trim().toLowerCase() ?? '';
        final value = propMatch.group(2)?.trim() ?? '';
        if (key.isNotEmpty && value.isNotEmpty) {
          properties[key] = value;
        }
      }
      
      if (properties.isNotEmpty) {
        rules.add(_CssRule(selector: selector, properties: properties));
      }
    }
    
    return rules;
  }

  /// Resolve styles for an element, returning an InlineTextStyle.
  InlineTextStyle resolveStyles(dom.Element element) {
    final style = InlineTextStyle.empty;
    
    // Collect all matching rules in specificity order
    final matches = <_MatchedRule>[];
    
    // Check all parsed stylesheets
    for (final rules in _parsedRules.values) {
      for (final rule in rules.rules) {
        if (_matchesSelector(rule.selector, element)) {
          matches.add(_MatchedRule(rule, _calculateSpecificity(rule.selector)));
        }
      }
    }
    
    // Sort by specificity (higher first)
    matches.sort((a, b) => b.specificity.compareTo(a.specificity));
    
    // Apply rules in order
    var result = style;
    for (final match in matches) {
      result = result.merge(_parseRuleProperties(match.rule.properties));
    }
    
    // Apply inline style (highest priority)
    final inlineStyle = element.attributes['style'];
    if (inlineStyle != null) {
      result = result.merge(_parseInlineStyle(inlineStyle));
    }
    
    return result;
  }

  /// Get text alignment for an element.
  TextAlign? resolveTextAlign(dom.Element element) {
    // Check inline style first
    final inlineStyle = element.attributes['style'];
    if (inlineStyle != null) {
      final align = _extractProperty(inlineStyle, 'text-align');
      if (align != null) {
        switch (align.toLowerCase()) {
          case 'center':
            return TextAlign.center;
          case 'right':
            return TextAlign.right;
          case 'justify':
            return TextAlign.justify;
          case 'left':
          default:
            return TextAlign.left;
        }
      }
    }
    
    // Check CSS rules
    for (final rules in _parsedRules.values) {
      for (final rule in rules.rules) {
        if (_matchesSelector(rule.selector, element)) {
          final align = rule.properties['text-align'];
          if (align != null) {
            switch (align.toLowerCase()) {
              case 'center':
                return TextAlign.center;
              case 'right':
                return TextAlign.right;
              case 'justify':
                return TextAlign.justify;
              case 'left':
              default:
                return TextAlign.left;
            }
          }
        }
      }
    }
    
    return null;
  }

  /// Resolve image alignment and sizing.
  ImageStyleInfo? resolveImageStyle(dom.Element imgElement) {
    final info = ImageStyleInfo();
    
    // Check inline style
    final inlineStyle = imgElement.attributes['style'];
    if (inlineStyle != null) {
      final display = _extractProperty(inlineStyle, 'display');
      if (display == 'block') {
        info.isBlock = true;
      }
      final float = _extractProperty(inlineStyle, 'float');
      if (float == 'left' || float == 'right') {
        info.isBlock = false; // Inline with float
      }
      final width = _extractProperty(inlineStyle, 'width');
      final height = _extractProperty(inlineStyle, 'height');
      if (width != null) {
        info.width = _parseSize(width);
      }
      if (height != null) {
        info.height = _parseSize(height);
      }
    }
    
    // Check CSS rules
    for (final rules in _parsedRules.values) {
      for (final rule in rules.rules) {
        if (_matchesSelector(rule.selector, imgElement)) {
          final display = rule.properties['display'];
          if (display == 'block') {
            info.isBlock = true;
          }
          final float = rule.properties['float'];
          if (float == 'left' || float == 'right') {
            info.isBlock = false;
          }
          final width = rule.properties['width'];
          final height = rule.properties['height'];
          if (width != null && info.width == null) {
            info.width = _parseSize(width);
          }
          if (height != null && info.height == null) {
            info.height = _parseSize(height);
          }
        }
      }
    }
    
    return info;
  }

  bool _matchesSelector(String selector, dom.Element element) {
    // Simple selector matching - supports:
    // - Tag names (e.g., "p", "h1")
    // - Classes (e.g., ".title", ".chapter-title")
    // - IDs (e.g., "#header")
    // - Combined (e.g., "p.center", "h1.title")
    
    final normalized = selector.trim().toLowerCase();
    
    // ID selector
    if (normalized.startsWith('#')) {
      final id = normalized.substring(1).split(RegExp(r'[\.\s\[]')).first;
      return element.id.toLowerCase() == id;
    }
    
    // Class selector
    if (normalized.startsWith('.')) {
      final className = normalized.substring(1).split(RegExp(r'[\.\s\[]')).first;
      final elementClasses = element.className.toLowerCase().split(RegExp(r'\s+'));
      return elementClasses.contains(className);
    }
    
    // Tag selector
    final parts = normalized.split(RegExp(r'[\.\s\[]'));
    final tagName = parts.first;
    if (tagName.isEmpty) return false;
    
    final elementTag = element.localName?.toLowerCase() ?? '';
    if (elementTag != tagName) return false;
    
    // Check for class qualifier (e.g., "p.center")
    if (parts.length > 1) {
      for (var i = 1; i < parts.length; i++) {
        final part = parts[i];
        if (part.startsWith('.')) {
          final className = part.substring(1);
          final elementClasses = element.className.toLowerCase().split(RegExp(r'\s+'));
          if (!elementClasses.contains(className)) {
            return false;
          }
        }
      }
    }
    
    return true;
  }

  int _calculateSpecificity(String selector) {
    // Simple specificity: ID > class > tag
    int specificity = 0;
    if (selector.contains('#')) specificity += 1000;
    if (selector.contains('.')) specificity += 100;
    final tagMatch = RegExp(r'^[a-z]+').firstMatch(selector);
    if (tagMatch != null) specificity += 1;
    return specificity;
  }

  InlineTextStyle _parseRuleProperties(Map<String, String> properties) {
    final style = InlineTextStyle.empty;
    
    // Font weight
    final fontWeight = properties['font-weight'];
    if (fontWeight != null) {
      final weight = _parseFontWeight(fontWeight);
      if (weight != null) {
        return style.merge(InlineTextStyle(fontWeight: weight));
      }
    }
    
    // Font style
    final fontStyle = properties['font-style'];
    if (fontStyle != null) {
      final styleValue = _parseFontStyle(fontStyle);
      if (styleValue != null) {
        return style.merge(InlineTextStyle(fontStyle: styleValue));
      }
    }
    
    // Font size
    final fontSize = properties['font-size'];
    if (fontSize != null) {
      final scale = _parseFontSize(fontSize);
      if (scale != null) {
        return style.merge(InlineTextStyle(fontScale: scale));
      }
    }
    
    // Color
    final color = properties['color'];
    if (color != null) {
      final colorValue = _parseColor(color);
      if (colorValue != null) {
        return style.merge(InlineTextStyle(color: colorValue));
      }
    }
    
    // Font family
    final fontFamily = properties['font-family'];
    if (fontFamily != null) {
      final family = _parseFontFamily(fontFamily);
      if (family != null) {
        return style.merge(InlineTextStyle(fontFamily: family));
      }
    }
    
    return style;
  }

  InlineTextStyle _parseInlineStyle(String inlineStyle) {
    final properties = <String, String>{};
    final parts = inlineStyle.split(';');
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) continue;
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex > 0) {
        final key = trimmed.substring(0, colonIndex).trim().toLowerCase();
        final value = trimmed.substring(colonIndex + 1).trim();
        properties[key] = value;
      }
    }
    return _parseRuleProperties(properties);
  }

  String? _extractProperty(String style, String property) {
    final regex = RegExp('$property\\s*:\\s*([^;]+)', caseSensitive: false);
    final match = regex.firstMatch(style);
    return match?.group(1)?.trim();
  }

  FontWeight? _parseFontWeight(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'bold':
      case '700':
        return FontWeight.bold;
      case 'normal':
      case '400':
        return FontWeight.normal;
      case '100':
        return FontWeight.w100;
      case '200':
        return FontWeight.w200;
      case '300':
        return FontWeight.w300;
      case '500':
        return FontWeight.w500;
      case '600':
        return FontWeight.w600;
      case '800':
        return FontWeight.w800;
      case '900':
        return FontWeight.w900;
      default:
        return null;
    }
  }

  FontStyle? _parseFontStyle(String value) {
    final normalized = value.toLowerCase().trim();
    switch (normalized) {
      case 'italic':
      case 'oblique':
        return FontStyle.italic;
      case 'normal':
        return FontStyle.normal;
      default:
        return null;
    }
  }

  double? _parseFontSize(String value) {
    // Parse font-size and return a scale factor relative to base size
    // For now, assume base is 1em = 16px, and return scale
    final normalized = value.trim().toLowerCase();
    
    // Percentage
    if (normalized.endsWith('%')) {
      final percent = double.tryParse(normalized.substring(0, normalized.length - 1));
      if (percent != null) {
        return percent / 100.0;
      }
    }
    
    // Em units
    if (normalized.endsWith('em')) {
      final em = double.tryParse(normalized.substring(0, normalized.length - 2));
      if (em != null) {
        return em;
      }
    }
    
    // Rem units
    if (normalized.endsWith('rem')) {
      final rem = double.tryParse(normalized.substring(0, normalized.length - 3));
      if (rem != null) {
        return rem;
      }
    }
    
    // Pixels (convert to scale assuming 16px base)
    if (normalized.endsWith('px')) {
      final px = double.tryParse(normalized.substring(0, normalized.length - 2));
      if (px != null) {
        return px / 16.0;
      }
    }
    
    // Absolute sizes
    final absoluteSizes = {
      'xx-small': 0.625,
      'x-small': 0.75,
      'small': 0.875,
      'medium': 1.0,
      'large': 1.125,
      'x-large': 1.5,
      'xx-large': 2.0,
    };
    return absoluteSizes[normalized];
  }

  Color? _parseColor(String value) {
    final normalized = value.trim().toLowerCase();
    
    // Hex colors
    if (normalized.startsWith('#')) {
      final hex = normalized.substring(1);
      if (hex.length == 6) {
        final r = int.tryParse(hex.substring(0, 2), radix: 16);
        final g = int.tryParse(hex.substring(2, 4), radix: 16);
        final b = int.tryParse(hex.substring(4, 6), radix: 16);
        if (r != null && g != null && b != null) {
          return Color.fromRGBO(r, g, b, 1.0);
        }
      } else if (hex.length == 3) {
        final r = int.tryParse(hex[0] + hex[0], radix: 16);
        final g = int.tryParse(hex[1] + hex[1], radix: 16);
        final b = int.tryParse(hex[2] + hex[2], radix: 16);
        if (r != null && g != null && b != null) {
          return Color.fromRGBO(r, g, b, 1.0);
        }
      }
    }
    
    // RGB/RGBA
    final rgbMatch = RegExp(r'rgba?\(([^)]+)\)').firstMatch(normalized);
    if (rgbMatch != null) {
      final values = rgbMatch.group(1)!.split(',').map((v) => v.trim()).toList();
      if (values.length >= 3) {
        final r = int.tryParse(values[0]);
        final g = int.tryParse(values[1]);
        final b = int.tryParse(values[2]);
        final a = values.length > 3 ? double.tryParse(values[3]) : 1.0;
        if (r != null && g != null && b != null && a != null) {
          return Color.fromRGBO(r, g, b, a);
        }
      }
    }
    
    // Named colors (basic set)
    final namedColors = {
      'black': Color.fromRGBO(0, 0, 0, 1.0),
      'white': Color.fromRGBO(255, 255, 255, 1.0),
      'red': Color.fromRGBO(255, 0, 0, 1.0),
      'green': Color.fromRGBO(0, 128, 0, 1.0),
      'blue': Color.fromRGBO(0, 0, 255, 1.0),
    };
    return namedColors[normalized];
  }

  String? _parseFontFamily(String value) {
    // Extract first font family name (before comma)
    final parts = value.split(',');
    if (parts.isEmpty) return null;
    var family = parts.first.trim();
    // Remove quotes
    if (family.startsWith('"') && family.endsWith('"')) {
      family = family.substring(1, family.length - 1);
    } else if (family.startsWith("'") && family.endsWith("'")) {
      family = family.substring(1, family.length - 1);
    }
    return family.isEmpty ? null : family;
  }

  double? _parseSize(String value) {
    // Parse width/height values (px, em, %, etc.)
    final normalized = value.trim().toLowerCase();
    
    if (normalized.endsWith('px')) {
      return double.tryParse(normalized.substring(0, normalized.length - 2));
    }
    
    if (normalized.endsWith('em')) {
      final em = double.tryParse(normalized.substring(0, normalized.length - 2));
      return em != null ? em * 16.0 : null; // Assume 1em = 16px
    }
    
    if (normalized.endsWith('%')) {
      // Percentage - would need context to resolve, return null for now
      return null;
    }
    
    return double.tryParse(normalized);
  }
}


class _CssRule {
  _CssRule({required this.selector, required this.properties});
  
  final String selector;
  final Map<String, String> properties;
}

class _CssRuleSet {
  _CssRuleSet({required this.rules});
  
  final List<_CssRule> rules;
}

class _MatchedRule {
  _MatchedRule(this.rule, this.specificity);
  
  final _CssRule rule;
  final int specificity;
}

class ImageStyleInfo {
  bool isBlock = false;
  double? width;
  double? height;
}

