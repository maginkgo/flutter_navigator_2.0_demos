import 'dart:async';

class Rx<T> {
  T _value;
  T get value => _value;
  StreamController<T> _controller = StreamController.broadcast();
  Stream<T> get stream => _controller.stream;
  bool get hasListeners => _controller.hasListener;

  Rx(T initalValue) {
    _value = initalValue;
  }

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      _controller.sink.add(_value);
    }
  }

  Future<void> close() => _controller.close();
}
