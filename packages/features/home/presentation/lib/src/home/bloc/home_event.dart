import 'package:home_presentation/src/home/bloc/home_state.dart';

sealed class HomeEvent {
  const HomeEvent();
}

final class HomeSessionCheckRequested extends HomeEvent {
  const HomeSessionCheckRequested();
}

final class HomeLogoutRequested extends HomeEvent {
  const HomeLogoutRequested();
}

final class HomeSessionExpiryRequested extends HomeEvent {
  const HomeSessionExpiryRequested();
}

final class HomeSessionChanged extends HomeEvent {
  const HomeSessionChanged(this.state);
  final HomeState state;
}
