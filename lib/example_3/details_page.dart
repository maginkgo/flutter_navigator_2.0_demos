import 'package:flutter/material.dart';

import 'book.dart';

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
