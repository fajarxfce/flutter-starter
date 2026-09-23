import 'dart:async';

import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/app_scope.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({this.onResult, super.key});
  final void Function(bool)? onResult;
  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    return BlocProvider(
      create: (_) => services.createLoginBloc(),
      child: LoginView(
        environment: services.config.label,
        isDemo: services.config.isDemo,
        sessionMessage: services.sessionMessage,
        onSignedIn: () {
          services.sessionMessage = null;
          if (onResult != null) {
            onResult!(true);
          } else {
            unawaited(context.router.replaceAll([HomeRoute()]));
          }
        },
      ),
    );
  }
}
