import 'package:flutter/material.dart';

import 'book.dart';
import 'book_state.dart';

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
