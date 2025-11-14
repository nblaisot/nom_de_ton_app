import 'dart:convert';

/// Represents a significant story event extracted from the book.
class SummaryEvent {
  final String title;
  final String description;
  final List<String> involvedCharacters;
  final String? location;
  final DateTime? occurredAt;

  SummaryEvent({
    required this.title,
    required this.description,
    this.involvedCharacters = const [],
    this.location,
    this.occurredAt,
  });

  factory SummaryEvent.fromJson(Map<String, dynamic> json) {
    return SummaryEvent(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      involvedCharacters: (json['involvedCharacters'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      location: json['location'] as String?,
      occurredAt: json['occurredAt'] != null
          ? DateTime.tryParse(json['occurredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'involvedCharacters': involvedCharacters,
      'location': location,
      'occurredAt': occurredAt?.toIso8601String(),
    };
  }
}

/// Represents notes about a character extracted while processing a chunk.
class ChunkCharacterNote {
  final String name;
  final String summary;
  final List<String> notableActions;
  final Map<String, String> relationships;

  ChunkCharacterNote({
    required this.name,
    required this.summary,
    this.notableActions = const [],
    this.relationships = const {},
  });

  factory ChunkCharacterNote.fromJson(Map<String, dynamic> json) {
    final relationships = <String, String>{};
    final relationshipsJson = json['relationships'];
    if (relationshipsJson is Map<String, dynamic>) {
      relationshipsJson.forEach((key, value) {
        relationships[key] = value?.toString() ?? '';
      });
    } else if (relationshipsJson is Map) {
      relationshipsJson.forEach((key, value) {
        relationships[key.toString()] = value?.toString() ?? '';
      });
    }

    return ChunkCharacterNote(
      name: json['name'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      notableActions: (json['notableActions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      relationships: relationships,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'summary': summary,
      'notableActions': notableActions,
      'relationships': relationships,
    };
  }
}

/// Aggregated general summary payload saved in cache for quick rendering.
class GeneralSummaryPayload {
  final String narrative;
  final List<SummaryEvent> keyEvents;

  GeneralSummaryPayload({
    required this.narrative,
    this.keyEvents = const [],
  });

  factory GeneralSummaryPayload.fromJson(Map<String, dynamic> json) {
    return GeneralSummaryPayload(
      narrative: json['narrative'] as String? ?? '',
      keyEvents: (json['keyEvents'] as List?)
              ?.map((e) => SummaryEvent.fromJson(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v))))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'narrative': narrative,
      'keyEvents': keyEvents.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static GeneralSummaryPayload? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return GeneralSummaryPayload.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

/// Payload that captures what happened since the reader last stopped reading.
class SinceLastTimePayload {
  final String recapFromBeginning;
  final String recentHighlights;
  final List<SummaryEvent> recentEvents;

  SinceLastTimePayload({
    required this.recapFromBeginning,
    required this.recentHighlights,
    this.recentEvents = const [],
  });

  factory SinceLastTimePayload.fromJson(Map<String, dynamic> json) {
    return SinceLastTimePayload(
      recapFromBeginning: json['recapFromBeginning'] as String? ?? '',
      recentHighlights: json['recentHighlights'] as String? ?? '',
      recentEvents: (json['recentEvents'] as List?)
              ?.map((e) => SummaryEvent.fromJson(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v))))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recapFromBeginning': recapFromBeginning,
      'recentHighlights': recentHighlights,
      'recentEvents': recentEvents.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static SinceLastTimePayload? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return SinceLastTimePayload.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

/// Relationship descriptor for a character profile.
class CharacterRelationship {
  final String withCharacter;
  final String description;

  CharacterRelationship({
    required this.withCharacter,
    required this.description,
  });

  factory CharacterRelationship.fromJson(Map<String, dynamic> json) {
    return CharacterRelationship(
      withCharacter: json['withCharacter'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withCharacter': withCharacter,
      'description': description,
    };
  }
}

/// Rich profile describing a character in the story.
class CharacterProfile {
  final String name;
  final String overview;
  final List<String> notableEvents;
  final List<CharacterRelationship> relationships;

  CharacterProfile({
    required this.name,
    required this.overview,
    this.notableEvents = const [],
    this.relationships = const [],
  });

  factory CharacterProfile.fromJson(Map<String, dynamic> json) {
    return CharacterProfile(
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      notableEvents: (json['notableEvents'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      relationships: (json['relationships'] as List?)
              ?.map((e) => CharacterRelationship.fromJson(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v))))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'overview': overview,
      'notableEvents': notableEvents,
      'relationships': relationships.map((e) => e.toJson()).toList(),
    };
  }
}

/// Collection of character profiles cached for quick reuse.
class CharacterProfilesPayload {
  final List<CharacterProfile> profiles;

  CharacterProfilesPayload({
    this.profiles = const [],
  });

  factory CharacterProfilesPayload.fromJson(Map<String, dynamic> json) {
    return CharacterProfilesPayload(
      profiles: (json['profiles'] as List?)
              ?.map((e) => CharacterProfile.fromJson(
                  (e as Map).map((k, v) => MapEntry(k.toString(), v))))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profiles': profiles.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  static CharacterProfilesPayload? fromJsonString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      return CharacterProfilesPayload.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

/// Utility helpers for encoding/decoding collections of events and notes.
class StructuredSummaryCodec {
  static String? encodeEvents(List<SummaryEvent>? events) {
    if (events == null) return null;
    return jsonEncode(events.map((e) => e.toJson()).toList());
  }

  static List<SummaryEvent>? decodeEvents(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final raw = jsonDecode(jsonString);
      if (raw is List) {
        return raw
            .map((e) => SummaryEvent.fromJson(
                (e as Map).map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String? encodeCharacterNotes(List<ChunkCharacterNote>? notes) {
    if (notes == null) return null;
    return jsonEncode(notes.map((e) => e.toJson()).toList());
  }

  static List<ChunkCharacterNote>? decodeCharacterNotes(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final raw = jsonDecode(jsonString);
      if (raw is List) {
        return raw
            .map((e) => ChunkCharacterNote.fromJson(
                (e as Map).map((k, v) => MapEntry(k.toString(), v))))
            .toList();
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}

