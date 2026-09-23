import 'package:home_presentation/src/home/bloc/home_state.dart';

/// Session capabilities consumed by home, implemented by the composing app.
abstract interface class HomeSession {
  HomeState get state;
  Stream<HomeState> get states;
  void check();
  void logout();
  void expire();
}
