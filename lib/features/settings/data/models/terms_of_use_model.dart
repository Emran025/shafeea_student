import 'dart:convert';
import 'dart:developer';

import '../../domain/entities/privacy_policy_entity.dart';
import '../../domain/entities/terms_of_use_entity.dart';

class TermsOfUseModel {
  final String version;
  final String lastUpdated;
  final List<String> summary;
  final List<SectionModel> sections;
  final String? changelog;
  final bool isActive;

  TermsOfUseModel({
    required this.version,
    required this.lastUpdated,
    required this.summary,
    required this.sections,
    this.changelog,
    required this.isActive,
  });

  /// Creates a [TermsOfUseModel] from a JSON map.
  ///
  /// This factory includes logic to handle "double-encoded" JSON strings
  /// (where a JSON array is stored as a string inside the JSON object).
  factory TermsOfUseModel.fromJson(Map<String, dynamic> json) {
    log("Parsing TermsOfUseModel: $json");

    // Helper to decode fields if they are strings containing JSON
    dynamic parseJsonField(dynamic field) {
      if (field is String) {
        try {
          return jsonDecode(field);
        } catch (e) {
          // If decoding fails, return the original field or handle accordingly
          return field;
        }
      }
      return field;
    }

    // 1. Parse Summary
    final summaryRaw = json['summary'] ?? [];
    final parsedSummary = parseJsonField(summaryRaw);
    final summaryList = parsedSummary is List
        ? List<String>.from(parsedSummary.map((e) => e.toString()))
        : <String>[];

    // 2. Parse Sections
    final sectionsRaw = json['sections'] ?? [];
    final parsedSections = parseJsonField(sectionsRaw);
    final sectionsList = parsedSections is List
        ? parsedSections
              .map(
                (sectionJson) =>
                    SectionModel.fromMap(sectionJson as Map<String, dynamic>),
              )
              .toList()
        : <SectionModel>[];

    return TermsOfUseModel(
      version: json['version'] as String? ?? '',
      lastUpdated: json['last_updated'] as String? ?? '',
      summary: summaryList,
      sections: sectionsList,
      changelog: json['changelog'] as String?,
      // Handle boolean or integer representation of boolean (0/1)
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  /// Maps the data model to the domain entity.
  ///
  /// Uses [DateTime.tryParse] to prevent crashes if the date string is invalid.
  TermsOfUseEntity toEntity() {
    return TermsOfUseEntity(
      version: version,
      lastUpdated: DateTime.tryParse(lastUpdated) ?? DateTime.now(),
      summary: summary,
      sections: sections.map((model) => model.toEntity()).toList(),
      changelog: changelog,
      isActive: isActive,
    );
  }
}

/// Represents a single section of the privacy policy or terms of use within the data layer.
///
/// This class acts as a data transfer object (DTO) that can be easily
/// serialized to and deserialized from a map structure (like JSON). It serves
/// as an intermediary between the raw data source and the pure domain [SectionEntity].
class SectionModel {
  /// The title of the policy section (e.g., "Data We Collect").
  final String title;

  /// The detailed content of the policy section.
  final String content;

  /// Creates a [SectionModel] instance.
  SectionModel({required this.title, required this.content});

  /// Creates a [SectionModel] instance from a map.
  ///
  /// This factory handles cases where 'content' might be a String or a List of Strings.
  /// If it is a List, it joins the items with newlines.
  factory SectionModel.fromMap(Map<String, dynamic> map) {
    // robustly handle the content field
    dynamic contentData = map['content'];
    String parsedContent = '';

    if (contentData is List) {
      // If the server sends a list of paragraphs, join them into one string
      parsedContent = contentData.map((e) => e.toString()).join('\n\n');
    } else {
      // If it's already a string or null
      parsedContent = contentData?.toString() ?? '';
    }

    return SectionModel(
      title: map['title'] as String? ?? '',
      content: parsedContent,
    );
  }

  /// Converts the [SectionModel] instance into a map.
  ///
  /// This is useful for encoding the object into a JSON-compatible format before
  /// storing or transmitting the data.
  Map<String, dynamic> toMap() {
    return {'title': title, 'content': content};
  }

  /// Maps the data-layer [SectionModel] to a domain-layer [SectionEntity].
  ///
  /// This method provides a clean way to convert the data representation
  /// into the pure, immutable business object used by the rest of the application.
  SectionEntity toEntity() {
    return SectionEntity(title: title, content: content);
  }
}
