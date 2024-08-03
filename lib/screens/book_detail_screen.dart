import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';
import 'dart:convert';
import '../models/book.dart';
import '../utils/json_parser.dart';
import '../widgets/topic_widget.dart';
import '../storage_service.dart';


class BookDetailScreen extends StatelessWidget {
  final Book book;
  final StorageService storageService = StorageService();

  BookDetailScreen({required this.book});

  Future<List<Topics>> _loadTopics() async {
    String path = 'lib/assets/books/${book.title}.json';
    String contents;

    try {
      contents = await rootBundle.loadString(path);
    } catch (e) {
      print('File not found in assets, trying to load from local storage.');
      if (book.jsonPath != null) {
        final file = File(book.jsonPath!);
        contents = await file.readAsString();
      } else {
        throw Exception('JSON path is null and file not found in assets.');
      }
    }

    final data = json.decode(contents);
    if (data['topics'] == null) {
      throw Exception('Topics are missing in the JSON data');
    }

    return parseTopics(data['topics'] as List);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: FutureBuilder<List<Topics>>(
        future: _loadTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('This book is not available'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No topics available'));
          } else {
            return ListView(
              children: snapshot.data!.map((topics) {
                return TopicWidget(
                  topics: topics,
                  book: book,
                  storageService: storageService,
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
