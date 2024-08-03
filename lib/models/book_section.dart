class BookSection {
  final String title;
  final List<BookSection> subsections;
  final String summary;

  BookSection({
    required this.title,
    this.subsections = const [],
    this.summary = '',
  });
}
