import 'package:flutter/material.dart';
import '../models/book.dart';
import '../storage_service.dart';

class SectionWidget extends StatelessWidget {
  final BookSection section;
  final Book book;
  final Topics topics;
  final StorageService storageService;

  SectionWidget({
    required this.section,
    required this.book,
    required this.topics,
    required this.storageService,
  });

  void _showSummaryDialog(BuildContext context, Book book, Topics topics, BookSection section) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool expanded = false; // Track whether the detailed summary is expanded
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(section.title),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(section.summary),
                    SizedBox(height: 10),
                    if (expanded) Text(section.read),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(expanded ? "Show Less" : "Read More"),
                  onPressed: () {
                    setState(() {
                      expanded = !expanded; // Toggle the expanded state
                    });
                  },
                ),
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text("Finished"),
                  onPressed: () async {
                    // Save the next reading position
                    await storageService.saveNextReadingPosition(book, topics, section);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return section.subsections.isEmpty
        ? ListTile(
      title: Text(section.title),
      onTap: () => _showSummaryDialog(context, book, topics, section),
    )
        : ExpansionTile(
      title: Text(section.title),
      children: section.subsections.map((subsection) {
        return ListTile(
          title: Text(subsection.title),
          onTap: () => _showSummaryDialog(context, book, topics, subsection),
        );
      }).toList(),
    );
  }
}
