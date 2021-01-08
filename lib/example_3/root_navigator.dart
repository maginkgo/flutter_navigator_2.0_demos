import 'package:flutter/material.dart';

import 'book_state.dart';
import 'details_page.dart';
import 'home_page.dart';

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
