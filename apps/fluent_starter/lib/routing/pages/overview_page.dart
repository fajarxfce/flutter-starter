import 'package:auth_presentation/auth_presentation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_presentation/home_presentation.dart';

@RoutePage()
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionBloc, SessionState>(
    builder: (context, state) => HomeOverview(
      displayName: state.displayName,
      email: state.email,
      environment: state.environment,
      busy: state.busy,
      message: state.message,
      onCheckSession: () =>
          context.read<SessionBloc>().add(const SessionCheckRequested()),
      onLogout: () =>
          context.read<SessionBloc>().add(const SessionLogoutRequested()),
      onExpireDemoSession: state.isDemo
          ? () =>
                context.read<SessionBloc>().add(const SessionExpiryRequested())
          : null,
    ),
  );
}
