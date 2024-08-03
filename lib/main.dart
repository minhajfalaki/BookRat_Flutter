import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'screens/book_list_screen.dart';
import 'notification_controller.dart';
import 'SubsectionScreen.dart';
import 'package:path_provider/path_provider.dart';
import 'utils/json_parser.dart';
import 'models/book.dart';
import 'storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  AwesomeNotifications().initialize(
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9D50DD),
        ledColor: Colors.white,
        playSound: true,
        enableLights: true,
        enableVibration: true,
        importance: NotificationImportance.High,
        icon: 'resource://drawable/res_app_icon',
      )
    ],
  );

  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
  );

  runApp(MyApp());
  requestNotificationPermissions();
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Books App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BookListScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/subsection') {
          final args = settings.arguments as Map<String, dynamic>;
          final subsection = args['subsection'] as BookSection;
          final book = args['book'] as Book;
          final section = args['section'] as BookSection;
          final topic = args['topics'] as Topics; // Ensure topic is passed in arguments
          return MaterialPageRoute(
            builder: (context) {
              return SubsectionScreen(
                book: book,
                section: section,
                topics: topic, // Pass the topic
              );
            },
          );
        }
        return null;
      },
    );
  }
}

void requestNotificationPermissions() async {
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    // Request permission to send notifications
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }
  // After requesting permission, schedule the daily notification
  scheduleDailyNotification();
}


void scheduleDailyNotification() {
  final indiaTimeZone = tz.getLocation('Asia/Kolkata');
  final now = tz.TZDateTime.now(indiaTimeZone);
  var scheduledDate = tz.TZDateTime(indiaTimeZone, now.year, now.month, now.day, 21, 30);

  // If the scheduled time has already passed today, schedule for tomorrow
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(Duration(days: 1));
  }

  print('Scheduling notification for: $scheduledDate (local: ${scheduledDate.toLocal()})');

  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Daily Notification',
      body: 'This is a daily notification at 11:21 PM IST',
      notificationLayout: NotificationLayout.Default,
      payload: {"navigate": "true"},
    ),
    schedule: NotificationCalendar(
      hour: 21,
      minute: 30,
      second: 0,
      repeats: true,
      timeZone: indiaTimeZone.name,
    ),
  );
}


class ReadingPage extends StatefulWidget {
  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  late StorageService _storageService;
  Book? _currentBook;
  Topics? _currentTopic;
  BookSection? _currentSection;
  BookSection? _currentSubsection;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService();
    _loadReadingPosition();
  }

  Future<void> _loadReadingPosition() async {
    var position = await _storageService.getReadingPosition();
    setState(() {
      _currentBook = position?['book'];
      _currentTopic = position?['topics'];
      _currentSection = position?['section'];
      _currentSubsection = position?['subsection'];
    });
  }

  Future<void> _saveReadingPosition() async {
    if (_currentBook != null && _currentTopic != null && _currentSection != null && _currentSubsection != null) {
      await _storageService.saveNextReadingPosition(_currentBook!, _currentTopic!, _currentSection!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
