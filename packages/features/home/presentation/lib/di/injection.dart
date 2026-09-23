import 'package:get_it/get_it.dart';
import 'package:home_presentation/src/home/session/home_session.dart';
import 'package:injectable/injectable.dart';

@InjectableInit.microPackage(
  ignoreUnregisteredTypes: [GetIt, HomeSession],
  throwOnMissingDependencies: true,
)
void configureHomePresentationPackage() {}
