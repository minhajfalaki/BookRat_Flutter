class Book {
  final String title;
  final List<Topics> topics;
  String? coverUrl;
  String? jsonUrl;
  String? coverPath;
  String? jsonPath;

  Book({
    required this.title,
    required this.topics,
    this.coverUrl,
    this.jsonUrl,
    this.coverPath,
    this.jsonPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'topics': topics.map((topics) => topics.toMap()).toList(),
      'coverUrl': coverUrl,
      'jsonUrl': jsonUrl,
      'coverPath': coverPath,
      'jsonPath': jsonPath,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    // print('Parsing Book from Map');
    // print('Title: ${map['title']}');
    // print('Cover URL: ${map['coverUrl']}');
    // print('JSON URL: ${map['jsonUrl']}');

    List<dynamic> topicsList = map['topics'] ?? [];
    // print('Topics List: $topicsList');

    if (topicsList.isEmpty) {
      print('No topics found in the JSON data.');
    } else {
      print('Topics found in the JSON data: ${topicsList.length}');
    }

    return Book(
      title: map['title'],
      topics: List<Topics>.from(topicsList.map((x) => Topics.fromMap(x))),
      coverUrl: map['coverUrl'],
      jsonUrl: map['jsonUrl'],
      coverPath: map['coverPath'],
      jsonPath: map['jsonPath'],
    );
  }
}

class Topics {
  final String title;
  final String summary;
  final List<BookSection> sections;

  Topics({
    required this.title,
    required this.summary,
    required this.sections,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'sections': sections.map((section) => section.toMap()).toList(),
    };
  }

  factory Topics.fromMap(Map<String, dynamic> map) {
    // print('Parsing Topic from Map');
    // print('Title: ${map['title']}');
    // print('Summary: ${map['summary']}');

    List<dynamic> sectionsList = map['sections'] ?? [];
    // print('Sections List: $sectionsList');

    return Topics(
      title: map['title'],
      summary: map['summary'],
      sections: List<BookSection>.from(sectionsList.map((x) => BookSection.fromMap(x))),
    );
  }
}

class BookSection {
  final String title;
  final String summary;
  final String read;
  final List<BookSection> subsections;
  final int index;

  BookSection({
    required this.title,
    required this.summary,
    required this.read,
    this.subsections = const [],
    required this.index,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'summary': summary,
      'read': read,
      'subsections': subsections.map((subsection) => subsection.toMap()).toList(),
      'index': index,
    };
  }

  factory BookSection.fromMap(Map<String, dynamic> map) {
    // print('Parsing BookSection from Map');
    // print('Title: ${map['title']}');
    // print('Summary: ${map['summary']}');

    List<dynamic> subsectionsList = map['subsections'] ?? [];
    // print('Subsections List: $subsectionsList');

    return BookSection(
      title: map['title'],
      summary: map['summary'],
      read: map['read'],
      subsections: List<BookSection>.from(subsectionsList.map((x) => BookSection.fromMap(x))),
      index: map['index'],
    );
  }
}
