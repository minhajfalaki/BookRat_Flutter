import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'main.dart';
import 'storage_service.dart';
import 'models/book.dart';
import 'utils/json_parser.dart';
import 'SubsectionScreen.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Handle notification created
  }

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Handle notification displayed
  }

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Handle notification dismissed
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final payload = receivedAction.payload ?? {};
    if (payload["navigate"] == "true") {
      await navigateToSavedPosition();
    }
  }

  static Future<void> navigateToSavedPosition() async {
    StorageService storageService = StorageService();
    var position = await storageService.getReadingPosition();
    print('Reading position: $position');

    if (position != null) {
      Book book = position['book'];
      Topics topic = position['topic'];
      BookSection section = position['section'];


      // final directory = await getApplicationDocumentsDirectory();
      final path = 'lib/assets/books/${book.title}.json';
      print("Book name is ${book.title}");
      try {
        final contents = await rootBundle.loadString(path);
        print("Loaded contents: $contents");

        // Manually parse JSON
        final data = json.decode(contents);
        final List<Topics> topics = (data['topics'] as List)
            .map((topic) => Topics.fromMap(topic))
            .toList();

        print('Parsed topics from JSON: ${topics.length}');
        for (var t in topics) {
          print('Topic: ${t.title}');
        }

        Topics? foundTopic;
        BookSection? foundSection;

        for (var t in topics) {
          if (t.title == topic.title) {
            foundTopic = t;
            for (var s in t.sections) {
              if (s.index == section.index) {
                foundSection = s;
                break;
              }
            }
            if (foundSection != null) {
              break;
            }
          }
        }

        if (foundTopic != null && foundSection != null) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => SubsectionScreen(
              book: Book(title: book.title, topics: topics),
              section: foundSection!,
              topics: foundTopic!,
            ),
          ));
          print('Navigation successful');
        } else {
          print('Topic or section not found');
        }
      } catch (e) {
        print('Error loading or parsing JSON file: $e');
      }
    } else {
      print('No saved reading position found');
    }
  }
}