import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/auth/login_page.dart';
import '../features/diner/diner_page.dart';
import '../features/floor/floor_page.dart';
import '../features/hotel/expenses_page.dart';
import '../features/hotel/menu_page.dart';
import '../features/hotel/my_work_page.dart';
import '../features/hotel/orders_page.dart';
import '../features/hotel/overview_page.dart';
import '../features/hotel/tables_page.dart';
import '../features/hotel/team_page.dart';
import '../features/kitchen/kitchen_page.dart';
import '../features/platform/categories_page.dart';
import '../features/platform/hotels_page.dart';
import '../features/platform/overview_page.dart';
import '../features/platform/plans_page.dart';
import '../ui/shell.dart';
import 'auth/session.dart';
import 'theme/tokens.dart';

class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
  }
}

String _home(BuildContext context, Session s) => tabsFor(context, s).firstOrNull?.path ?? '/login';

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) => CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: Motion.fast,
      reverseTransitionDuration: Motion.fast,
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Motion.ease), child: c),
    );

final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _SessionListenable(ref);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: listenable,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc.startsWith('/t/')) return null; // diner pages are public
      final session = ref.read(sessionProvider);
      if (session.isLoading) return null;
      final s = session.value;
      if (s == null) return loc == '/login' ? null : '/login';
      final home = _home(context, s);
      if (loc == '/login' || loc == '/') return home;
      if (s.platform != loc.startsWith('/p/')) return home;
      final allowed = tabsFor(context, s).any((t) => loc.startsWith(t.path));
      return allowed ? null : home;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _Splash()),
      GoRoute(path: '/login', pageBuilder: (_, s) => _fade(s, const LoginPage())),
      GoRoute(path: '/t/:qr', pageBuilder: (_, s) => _fade(s, DinerPage(qrToken: s.pathParameters['qr']!))),
      ShellRoute(
        builder: (_, state, child) => AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/p/overview', pageBuilder: (_, s) => _fade(s, const PlatformOverviewPage())),
          GoRoute(path: '/p/hotels', pageBuilder: (_, s) => _fade(s, const HotelsPage())),
          GoRoute(path: '/p/plans', pageBuilder: (_, s) => _fade(s, const PlansPage())),
          GoRoute(path: '/p/categories', pageBuilder: (_, s) => _fade(s, const CategoriesPage())),
          GoRoute(path: '/h/overview', pageBuilder: (_, s) => _fade(s, const HotelOverviewPage())),
          GoRoute(path: '/h/me', pageBuilder: (_, s) => _fade(s, const MyWorkPage())),
          GoRoute(path: '/h/floor', pageBuilder: (_, s) => _fade(s, const FloorPage())),
          GoRoute(path: '/h/orders', pageBuilder: (_, s) => _fade(s, const OrdersPage())),
          GoRoute(path: '/h/kitchen', pageBuilder: (_, s) => _fade(s, const KitchenPage())),
          GoRoute(path: '/h/menu', pageBuilder: (_, s) => _fade(s, const MenuPage())),
          GoRoute(path: '/h/tables', pageBuilder: (_, s) => _fade(s, const TablesPage())),
          GoRoute(path: '/h/team', pageBuilder: (_, s) => _fade(s, const TeamPage())),
          GoRoute(path: '/h/expenses', pageBuilder: (_, s) => _fade(s, const ExpensesPage())),
        ],
      ),
    ],
  );
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.expand());
}
