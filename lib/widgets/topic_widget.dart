import 'package:flutter/material.dart';
import '../models/book.dart';
import '../storage_service.dart';
import '../widgets/section_widget.dart';

class TopicWidget extends StatelessWidget {
  final Topics topics;
  final Book book;
  final StorageService storageService;

  TopicWidget({
    required this.topics,
    required this.book,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(topics.title),
      children: topics.sections.map((section) {
        return SectionWidget(
          section: section,
          book: book,
          topics: topics,
          storageService: storageService,
        );
      }).toList(),
    );
  }
}
