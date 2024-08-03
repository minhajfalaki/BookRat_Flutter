import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import '../models/book.dart';

Future<List<Topics>> loadBookTopicsFromJson(String path) async {
  final file = File(path);
  final contents = await rootBundle.loadString(path);
  print("loaded contents $contents");


  if (contents.isEmpty) {
    throw Exception('File is empty');
  }

  final data = json.decode(contents);
  return parseTopics(data['topics'] as List);
}

List<BookSection> parseSections(List<dynamic>? sections) {
  if (sections == null) {
    return [];
  }
  return sections.map((section) {
    return BookSection(
      title: section['title'],
      summary: section['summary'],
      read: section['read'] ?? '',
      subsections: parseSections(section['subsections'] as List?),
      index: section['index'] ?? 0,  // Provide a default value if index is null
    );
  }).toList();
}

List<Topics> parseTopics(List<dynamic> topics) {
  return topics.map((topic) {
    return Topics(
      title: topic['title'],
      summary: topic['summary'],
      sections: parseSections(topic['sections'] as List),
    );
  }).toList();
}
