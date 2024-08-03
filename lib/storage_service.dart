// lib/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../models/book.dart';
import '../utils/json_parser.dart';

class StorageService {
  static const String _keyBook = 'current_book';
  static const String _keyTopic = 'current_topic';
  static const String _keySection = 'current_section';
  static const String _keySubsection = 'current_subsection';

  Future<void> saveNextReadingPosition(Book book, Topics currentTopic, BookSection currentSection) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentIndex = currentSection.index;

    // Load and parse the JSON data using json_parser
    final path = 'lib/assets/books/${book.title}.json'; // Adjust the path to your JSON file
    final topics = await loadBookTopicsFromJson(path);
    book = Book(title: book.title, topics: topics);

    Topics? nextTopic;
    BookSection? nextSection;

    // Check for the next section within the same topic
    for (var section in currentTopic.sections) {
      // print('Checking section with index: ${section.index}');
      if (section.index == currentIndex + 1) {
        nextSection = section;
        break;
      }
    }

    // If the next section is not found in the current topic, look in the next topics
    if (nextSection == null) {
      bool foundCurrentTopic = false;
      for (var topic in book.topics) {
        if (foundCurrentTopic) {
          for (var section in topic.sections) {
            if (section.index == currentIndex + 1) {
              nextSection = section;
              nextTopic = topic;
              break;
            }
          }
          if (nextSection != null) {
            break;
          }
        }
        if (topic.title == currentTopic.title) {
          foundCurrentTopic = true;
        }
      }
    }

    if (nextSection != null) {
      await prefs.setString(_keyBook, jsonEncode(book.toMap()));
      await prefs.setString(_keyTopic, jsonEncode(nextTopic?.toMap() ?? currentTopic.toMap()));
      await prefs.setString(_keySection, jsonEncode(nextSection.toMap()));
      print('Saving next reading position: ${nextSection.title}');
    } else {
      print('Next section not found.');
    }

    // For debugging: print all section titles in the book
    // print('All section titles in the book:');
    // for (var topic in book.topics) {
    //   for (var section in topic.sections) {
    //     print('  ${section.title} (Index: ${section.index})');
    //   }
    // }
  }

  Future<Map<String, dynamic>?> getReadingPosition() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bookString = prefs.getString(_keyBook);
    String? topicString = prefs.getString(_keyTopic);
    String? sectionString = prefs.getString(_keySection);
    String? subsectionString = prefs.getString(_keySubsection);

    if (bookString != null && topicString != null && sectionString != null) {
      Map<String, dynamic> bookMap = jsonDecode(bookString);
      Map<String, dynamic> topicMap = jsonDecode(topicString);
      Map<String, dynamic> sectionMap = jsonDecode(sectionString);

      print('Loaded reading position:');
      print('Book: ${bookMap['title']}');
      print('Topic: ${topicMap['title']}');
      print('Section: ${sectionMap['title']}');

      return {
        'book': Book.fromMap(bookMap),
        'topic': Topics.fromMap(topicMap),
        'section': BookSection.fromMap(sectionMap),
        'subsection': subsectionString != null ? BookSection.fromMap(jsonDecode(subsectionString)) : null,
      };
    }
    return null;
  }

}
