import 'book.dart';

class BookModelView {
  final Book selectedBook;

  BookModelView(this.selectedBook);

  List<Book> books = [
    Book('Stranger in a Strange Land', 'Robert A. Heinlein'),
    Book('Foundation', 'Isaac Asimov'),
    Book('Fahrenheit 451', 'Ray Bradbury'),
  ];
}
