import 'dart:async';

import 'package:home_presentation/home_presentation.dart';

class FakeHomeSession implements HomeSession {
  FakeHomeSession([this.state = const HomeState()]);

  final _controller = StreamController<HomeState>.broadcast(sync: true);
  final actions = <String>[];

  @override
  HomeState state;

  @override
  Stream<HomeState> get states => _controller.stream;

  bool get hasListener => _controller.hasListener;

  void update(HomeState value) {
    state = value;
    _controller.add(value);
  }

  @override
  void check() => actions.add('check');

  @override
  void logout() => actions.add('logout');

  @override
  void expire() => actions.add('expire');

  Future<void> close() => _controller.close();
}
