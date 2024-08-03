import 'package:flutter/material.dart';
import '../models/book.dart';
import '../storage_service.dart';
import '../screens/book_detail_screen.dart';
import 'notification_controller.dart';

class SubsectionScreen extends StatelessWidget {
  final Book book;
  final BookSection section;
  final Topics topics;
  final StorageService storageService = StorageService();

  SubsectionScreen({
    required this.book,
    required this.section,
    required this.topics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
      ),
      backgroundColor: Colors.blue,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.grey[200]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Displaying content for ${section.read}',
                  style: TextStyle(fontSize: 24), // Increase font size
                ),
                SizedBox(height: 20), // Add some space between text and button
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Save the next reading position
                      await storageService.saveNextReadingPosition(book, topics, section);

                      // Navigate to the BookListScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => BookDetailScreen(book: book)),
                      );
                    },
                    child: Text('Finished'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
