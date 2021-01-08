import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'book_model_view.dart';
import 'book_state.dart';
import 'details_page.dart';
import 'home_page.dart';

class RootNavigator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BookState>(
      create: (_) => BookState(BookModelView(null)),
      builder: (context, child) {
        return StreamBuilder<BookModelView>(
          stream: context.watch<BookState>().bookModelViewStream,
          initialData: BookModelView(null),
          builder: (context, snapshot) {
            final _state = snapshot.data;
            return Navigator(
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

                context.read<BookState>().bookModelView = BookModelView(null);

                return true;
              },
            );
          },
        );
      },
    );
  }
}
