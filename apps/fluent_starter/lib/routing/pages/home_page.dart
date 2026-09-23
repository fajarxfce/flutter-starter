import 'package:auto_route/auto_route.dart';
import 'package:fluent_starter/routing/app_router.gr.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:home_presentation/home_presentation.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => AutoTabsRouter(
    homeIndex: 0,
    routes: [OverviewRoute(), PreferencesRoute()],
    builder: (context, child) {
      final tabs = AutoTabsRouter.of(context);
      return HomeView(
        selectedIndex: tabs.activeIndex,
        onDestinationSelected: tabs.setActiveIndex,
        child: child,
      );
    },
  );
}
