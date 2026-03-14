import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../Auth/Login/LoginView.dart';
import '../../Auth/NewPassword/NewPasswordView.dart';
import '../../Auth/Signin/SignupView.dart';
import '../../Support/PrivacyPolicyView.dart';
import '../../Support/SupportView.dart';
import '../../Support/TermsView.dart';
import '../Darek/DarekView.dart';
import '../DarekDetails/DarekDetailView.dart';
import '../Dashboard/DashboardView.dart';
import 'Manager.dart';
import 'package:flutter/widgets.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
RouteObserver<PageRoute<dynamic>>();

class TomobilApp extends StatefulWidget {
  const TomobilApp({super.key, required this.manager});
  final Manager manager;

  @override
  State<TomobilApp> createState() => _TomobilAppState();
}

class _TomobilAppState extends State<TomobilApp> {
  late final GoRouter _router = GoRouter(
    debugLogDiagnostics: false,
    observers: [routeObserver],
    errorBuilder: (context, state) => DarekView(manager: widget.manager),
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => SplashScreen(manager: widget.manager),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => DarekView(manager: widget.manager),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginView(manager: widget.manager),
      ),
      GoRoute(
        path: '/support',
        name: 'support',
        builder: (context, state) => SupportView(manager: widget.manager),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => TermsView(manager: widget.manager),
      ),
      GoRoute(
        path: '/privacy',
        name: 'privacy',
        builder: (context, state) => PrivacyPolicyView(manager: widget.manager),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) {
          final ref = (state.uri.queryParameters['ref'] ?? '').trim();
          return SignupView(
            manager: widget.manager,
            referralCode: ref.isNotEmpty ? ref : null,
          );
        },
      ),

      /// Public details
      GoRoute(
        path: '/details/darek/:id',
        name: 'darek_details',
        builder: (context, state) {
          final rawId = state.pathParameters['id'] ?? '';
          final id = Uri.decodeComponent(rawId);

          return DarekDetailView(
            manager: widget.manager,
            item: state.extra as dynamic,
            itemId: id,
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) =>
            AppShell(manager: widget.manager, child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard_root',
            redirect: (_, __) => '/dashboard/accueil',
          ),
          GoRoute(
            path: '/dashboard/accueil',
            name: 'dashboard_accueil',
            builder: (context, state) => DashboardView(
              manager: widget.manager,
              initialPath: state.matchedLocation,
            ),
          ),
          GoRoute(
            path: '/dashboard/profile',
            name: 'dashboard_profile',
            builder: (context, state) => DashboardView(
              manager: widget.manager,
              initialPath: state.matchedLocation,
            ),
          ),
          GoRoute(
            path: '/dashboard/myads',
            name: 'dashboard_myads',
            builder: (context, state) => DashboardView(
              manager: widget.manager,
              initialPath: state.matchedLocation,
            ),
          ),
          GoRoute(
            path: '/dashboard/details/darek/:id',
            name: 'dashboard_darek_details',
            builder: (context, state) {
              final rawId = state.pathParameters['id'] ?? '';
              final id = Uri.decodeComponent(rawId);

              return DarekDetailView(
                manager: widget.manager,
                item: state.extra as dynamic,
                itemId: id,
              );
            },
          ),
        ],
      ),

      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) {
          final uri = state.uri;

          final hostOk = uri.host.isEmpty || uri.host == 'renovily.com';
          final pathOk = uri.path == '/reset-password';
          if (!hostOk || !pathOk) {
            return DarekView(manager: widget.manager);
          }

          final qp = uri.queryParameters;
          final email = qp['email'] ?? '';
          final token = qp['token'] ?? '';

          if (email.isEmpty || token.isEmpty) {
            return DarekView(manager: widget.manager);
          }

          return NewPasswordView(
            manager: widget.manager,
            email: Uri.decodeComponent(email),
            token: token,
          );
        },
      ),
    ],
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isLoggedIn = widget.manager.isAuthenticated;

      if (isLoggedIn && loc.startsWith('/details/darek/')) {
        final rawId = state.pathParameters['id'] ?? '';
        final id = Uri.decodeComponent(rawId);
        if (id.isNotEmpty) {
          return '/dashboard/details/darek/$id';
        }
      }

      final isAuthRoute =
          loc == '/login' || loc == '/signup' || loc == '/signupref';

      final isProtected = loc.startsWith('/dashboard');

      if (!isLoggedIn && isProtected) return '/login';
      if (isLoggedIn && (isAuthRoute || loc == '/home')) return '/dashboard';

      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Tomobil',
      theme: ThemeData(useMaterial3: false),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.manager,
    required this.child,
  });

  final Manager manager;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {},
      child: Scaffold(body: child),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.manager});
  final Manager manager;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await widget.manager.autoLoginManager.bootstrap().timeout(
        const Duration(seconds: 4),
      );
    } catch (_) {}

    if (!mounted) return;

    final start = widget.manager.isAuthenticated
        ? '/dashboard/accueil'
        : '/home';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(start);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}