import 'package:auth_presentation/src/login/bloc/login_bloc.dart';
import 'package:auth_presentation/src/login/bloc/login_event.dart';
import 'package:auth_presentation/src/login/bloc/login_state.dart';
import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<LoginBloc, LoginState>(
    builder: (context, state) {
      final bloc = context.read<LoginBloc>();
      final busy = state.isSubmitting;
      return ScaffoldPage(
        content: PageBody(
          maxWidth: 440,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.page),
              const BrandHeader(subtitle: 'Sign in to your workspace.'),
              const SizedBox(height: AppSpacing.medium),
              Align(
                alignment: Alignment.centerLeft,
                child: EnvironmentBadge(label: state.environment),
              ),
              const SizedBox(height: AppSpacing.large),
              SectionCard(
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InfoLabel(
                        label: 'Email address',
                        child: TextBox(
                          key: const Key('login_email'),
                          enabled: !busy,
                          placeholder: 'you@example.com',
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.username],
                          textInputAction: TextInputAction.next,
                          onChanged: (email) =>
                              bloc.add(LoginEmailChanged(email)),
                        ),
                      ),
                      if (state.emailError != null) Text(state.emailError!),
                      const SizedBox(height: AppSpacing.medium),
                      InfoLabel(
                        label: 'Password',
                        child: TextBox(
                          key: const Key('login_password'),
                          enabled: !busy,
                          obscureText: true,
                          placeholder: 'At least 8 characters',
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.done,
                          onChanged: (password) =>
                              bloc.add(LoginPasswordChanged(password)),
                          onSubmitted: (_) => bloc.add(const LoginSubmitted()),
                        ),
                      ),
                      if (state.passwordError != null)
                        Text(state.passwordError!),
                      const SizedBox(height: AppSpacing.large),
                      FilledButton(
                        key: const Key('login_submit'),
                        onPressed: busy
                            ? null
                            : () => bloc.add(const LoginSubmitted()),
                        child: busy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: ProgressRing(strokeWidth: 2),
                              )
                            : const Text('Sign in'),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: AppSpacing.medium),
                        InfoBar(
                          title: const Text('Unable to sign in'),
                          content: Text(state.error!),
                          severity: InfoBarSeverity.error,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (state.isDemo) ...[
                const SizedBox(height: AppSpacing.large),
                const InfoBar(
                  title: Text('Demo workspace'),
                  content: SelectableText(
                    'Email: demo@example.com\nPassword: Demo123!',
                  ),
                  severity: InfoBarSeverity.info,
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
