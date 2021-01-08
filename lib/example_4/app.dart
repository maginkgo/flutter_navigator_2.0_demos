import 'package:flutter/material.dart';
import 'root_navigator.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Navigator 2.0 Example 4',
        home: RootNavigator(),
      );
}
