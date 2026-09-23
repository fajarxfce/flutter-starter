import 'package:core_design_system/core_design_system.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HomeOverview extends StatelessWidget {
  const HomeOverview({
    required this.displayName,
    required this.email,
    required this.environment,
    required this.busy,
    required this.onCheckSession,
    required this.onLogout,
    this.message,
    this.onExpireDemoSession,
    super.key,
  });
  final String displayName;
  final String email;
  final String environment;
  final bool busy;
  final String? message;
  final VoidCallback onCheckSession;
  final VoidCallback onLogout;
  final VoidCallback? onExpireDemoSession;
  @override
  Widget build(BuildContext context) => PageBody(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Welcome, $displayName',
          style: FluentTheme.of(context).typography.titleLarge,
        ),
        const SizedBox(height: AppSpacing.small),
        Text(email),
        const SizedBox(height: AppSpacing.medium),
        Align(
          alignment: Alignment.centerLeft,
          child: EnvironmentBadge(label: environment),
        ),
        const SizedBox(height: AppSpacing.large),
        const SectionCard(
          child: BrandHeader(
            subtitle: 'Your workspace is ready. Make it your own.',
          ),
        ),
        const SizedBox(height: AppSpacing.large),
        Wrap(
          spacing: AppSpacing.medium,
          runSpacing: AppSpacing.medium,
          children: [
            FilledButton(
              onPressed: busy ? null : onCheckSession,
              child: const Text('Check session'),
            ),
            Button(
              key: const Key('logout'),
              onPressed: busy ? null : onLogout,
              child: const Text('Sign out'),
            ),
            if (onExpireDemoSession != null)
              Button(
                onPressed: busy ? null : onExpireDemoSession,
                child: const Text('Expire demo session'),
              ),
          ],
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.medium),
          InfoBar(title: const Text('Session'), content: Text(message!)),
        ],
      ],
    ),
  );
}
