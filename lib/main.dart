import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigator 2.0 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Navigator(
        /// Funaciona similar a un Stack Cada vez que cambie el atributo pages
        /// el Navigator ejecuta una transición entre el último elemento que
        /// agregue y el anterior de forma reactiva.
        /// Para que eso suceda, es necedario hacer un rebuild de la app
        pages: [
          MaterialPage(child: HomePage(), key: ValueKey('home')),
        ],
        onPopPage: (route, result) {
          return route.didPop(result);
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage'),
      ),
    );
  }
}
