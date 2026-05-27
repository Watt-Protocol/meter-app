import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/providers/app_preferences_providers.dart';
import '../data/providers/auth_providers.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/display_settings_screen.dart';
import '../features/settings/wallet_settings_screen.dart';
import '../features/settings/notifications_settings_screen.dart';
import '../features/wallet/send_screen.dart';
import '../features/wallet/receive_screen.dart';
import '../features/meters/my_meters_screen.dart';
import '../features/history/minting_activity_screen.dart';
import '../features/history/mining_event_detail_screen.dart';
import '../data/models/mining_event.dart';
import '../core/constants/app_colors.dart';
import 'page_transitions.dart';
import 'tab_navigation_provider.dart';

/// Named route paths.
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String meters = '/meters';
  static const String mintingActivity = '/activity';
  static const String displaySettings = '/settings/display';
  static const String walletSettings = '/settings/wallet';
  static const String notificationsSettings = '/settings/notifications';
  static const String walletSend = '/wallet/send';
  static const String walletReceive = '/wallet/receive';
  static String miningDetail(int id) => '/activity/$id';
}

/// Bottom navigation shell for main tab screens.
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();
    _syncTabIndex();
  }

  @override
  void didUpdateWidget(MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.navigationShell.currentIndex !=
        widget.navigationShell.currentIndex) {
      _syncTabIndex();
    }
  }

  void _syncTabIndex() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(tabNavigationProvider.notifier).syncFromRoute(
            widget.navigationShell.currentIndex,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            if (index == navigationShell.currentIndex) return;
            ref.read(tabNavigationProvider.notifier).setIndices(
                  navigationShell.currentIndex,
                  index,
                );
            navigationShell.goBranch(index);
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

/// The GoRouter configuration provider.
final routerProvider = Provider<GoRouter>((ref) {
  Page<void> tabPage(Widget child, GoRouterState state) {
    final nav = ref.read(tabNavigationProvider);
    return tabSlidePage<void>(
      key: state.pageKey,
      child: child,
      fromIndex: nav.previousIndex,
      toIndex: nav.currentIndex,
    );
  }

  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => fadePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                pageBuilder: (context, state) => tabPage(
                  const DashboardScreen(),
                  state,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.history,
                pageBuilder: (context, state) => tabPage(
                  const HistoryScreen(),
                  state,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                pageBuilder: (context, state) => tabPage(
                  const SettingsScreen(),
                  state,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.meters,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const MyMetersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.displaySettings,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const DisplaySettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletSettings,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const WalletSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notificationsSettings,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const NotificationsSettingsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletSend,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const SendScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.walletReceive,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const ReceiveScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.mintingActivity,
        pageBuilder: (context, state) => pushPage(
          key: state.pageKey,
          child: const MintingActivityScreen(),
        ),
      ),
      GoRoute(
        path: '/activity/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final extra = state.extra;
          final event = extra is MiningEvent ? extra : null;
          return pushPage(
            key: state.pageKey,
            child: MiningEventDetailScreen(
              eventId: id,
              initialEvent: event,
            ),
          );
        },
      ),
    ],
    redirect: (context, state) {
      final isLoggedIn =
          ref.read(authRepositoryProvider).isAuthenticated;
      final isOnSplash = state.uri.path == AppRoutes.splash;
      final isOnLogin = state.uri.path == AppRoutes.login;

      if (isOnSplash) return null;

      if (!isLoggedIn) {
        if (isOnLogin) return null;
        return AppRoutes.login;
      }

      if (isOnLogin) {
        return defaultRouteFor(ref.read(defaultScreenProvider));
      }

      return null;
    },
  );
});
