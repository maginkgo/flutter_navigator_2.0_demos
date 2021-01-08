import 'package:flutter/widgets.dart';

import 'book.dart';

class BookState extends Notification {
  final Book selectedBook;

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];

  BookState(this.selectedBook);
}
