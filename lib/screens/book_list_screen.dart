import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/book.dart';
import '../utils/download_helper.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  List<Book> books = [
    Book(
      title: 'The Rebel',
      coverUrl: 'https://example.com/path/to/cover/rebel.png',
      jsonUrl: 'https://example.com/path/to/json/rebel.json',
      topics: [],  // Provide an empty list for topics
    ),
    Book(
      title: 'Beyond Good and Evil',
      coverUrl: 'https://example.com/path/to/cover/another.png',
      jsonUrl: 'https://example.com/path/to/json/another.json',
      topics: [],  // Provide an empty list for topics
    ),
    Book(
      title: 'Another Book',
      coverUrl: 'https://example.com/path/to/cover/another.png',
      jsonUrl: 'https://example.com/path/to/json/another.json',
      topics: [],  // Provide an empty list for topics
    ),
    // Add more books as needed
  ];

  List<Book> displayedBooks = [];

  @override
  void initState() {
    super.initState();
    displayedBooks = books;
    _checkLocalFiles();
  }

  void searchBooks(String query) {
    final suggestions = books.where((book) {
      final bookTitle = book.title.toLowerCase();
      final input = query.toLowerCase();
      return bookTitle.contains(input);
    }).toList();

    setState(() {
      displayedBooks = suggestions;
    });
  }

  Future<void> _checkLocalFiles() async {
    for (var book in books) {
      String path = 'lib/assets/books/${book.title}.json';
      try {
        // Try to load from assets to see if the file exists
        await rootBundle.loadString(path);
        book.jsonPath = path;
        print('Found ${book.title} in assets.');
      } catch (e) {
        print('Did not find ${book.title} in assets, will download if needed.');
      }
    }
  }

  Future<void> downloadAndNavigate(Book book) async {
    if (book.jsonPath == null) {
      // Ensure the jsonUrl is not null before calling downloadFile
      if (book.jsonUrl != null) {
        final jsonPath = await downloadFile(book.jsonUrl!, 'books/${book.title}.json');
        book.jsonPath = jsonPath?.path;
      } else {
        print('JSON URL is null for book: ${book.title}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load book JSON URL is null.')),
        );
        return;
      }
    }

    if (book.jsonPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailScreen(book: book),
        ),
      );
    } else {
      // Handle the case where the jsonPath is still null (download failed)
      print('Failed to load book JSON.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load book JSON.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: searchBooks,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: displayedBooks.length,
        itemBuilder: (context, index) {
          final book = displayedBooks[index];
          return ListTile(
            title: Text(book.title),
            onTap: () => downloadAndNavigate(book),
          );
        },
      ),
    );
  }
}
