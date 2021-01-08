import 'package:flutter/material.dart';

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

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Navigator 2.0 Demo',
        home: RootNavigator(),
      );
}

class RootNavigator extends StatefulWidget {
  @override
  _RootNavigatorState createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  BookState _state = BookState(null);

  bool update(BookState state) {
    setState(() => _state = state);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<BookState>(
      onNotification: (state) => update(state),
      child: Navigator(
        pages: [
          MaterialPage(
            key: ValueKey('HomePage'),
            child: HomePage(
              books: _state.books,
            ),
          ),
          if (_state.selectedBook != null)
            MaterialPage(
              key: ValueKey(_state.selectedBook),
              child: DetailsPage(book: _state.selectedBook),
            )
        ],
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          return update(BookState(null));
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<Book> books;

  HomePage({@required this.books});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: [
            for (var book in books)
              ListTile(
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () {
                  BookState(book)..dispatch(context);
                },
              )
          ],
        ),
      );
}

class DetailsPage extends StatelessWidget {
  final Book book;

  DetailsPage({@required this.book});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (book != null) ...[
                Text(
                  book.title,
                  style: Theme.of(context).textTheme.headline6,
                ),
                Text(
                  book.author,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ],
            ],
          ),
        ),
      );
}
