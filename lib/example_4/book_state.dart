import 'dart:async';

import 'book_model_view.dart';

class BookState {
  BookModelView _bookModelView;

  BookModelView get bookModelView => _bookModelView;

  set bookModelView(BookModelView bookModelView) {
    if (_bookModelView != bookModelView) {
      _bookModelView = bookModelView;
      _controller.sink.add(_bookModelView);
    }
  }

  final _controller = StreamController<BookModelView>.broadcast();

  Stream<BookModelView> get bookModelViewStream => _controller.stream;

  BookState(BookModelView value) {
    _bookModelView = value;
  }

  Future<void> close() => _controller.close();
}
