import 'package:make_my_ride/features/home/home_page.dart';
import 'package:make_my_ride/features/driver/driver_home.dart';
import 'package:make_my_ride/features/driver/presentation/view/driver_ride_history_screen.dart';
import 'package:make_my_ride/features/driver/presentation/view/driver_ride_screen.dart';
import 'package:make_my_ride/features/ride/presentation/view/ride_history.dart';

import 'app_routes.dart';
import 'auth_gate.dart';
import '../../features/auth/presentation/viewmodel/auth_viewmodel.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/view/screens/splash_screen.dart';
import '../../features/auth/presentation/view/screens/login_screen.dart';
import '../../features/auth/presentation/view/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/view/screens/profile_completion_screen.dart';
import '../../features/auth/presentation/view/screens/driver_details_screen.dart';
import '../../features/auth/presentation/view/screens/role_selection_screen.dart';

export 'app_routes.dart';

// ─── Auth Notifier for GoRouter refresh ───────────────────────────────────────

/// A [ChangeNotifier] that bridges Riverpod auth state into GoRouter's
/// [refreshListenable]. Whenever the auth state changes the router
/// re-evaluates its [redirect] logic automatically.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._ref) {
    // Subscribe to auth state changes
    _sub = _ref.listen<AuthState>(
      authViewModelProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _sub;

  AuthState get authState => _ref.read(authViewModelProvider);

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

// Provider so the router can be resolved inside ProviderScope
final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authNotifier,

    // ─── Global redirect logic ─────────────────────────────────────────────
    redirect: (BuildContext context, GoRouterState state) {
      return AuthGate.redirect(
        authState: authNotifier.authState,
        state: state,
      );
    },

    // ─── Route Definitions ─────────────────────────────────────────────────
    routes: [
      // ── Auth Flow ──────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        name: 'completeProfile',
        builder: (context, state) => const ProfileCompletionScreen(),
      ),
      GoRoute(
        path: AppRoutes.chooseRole,
        name: 'chooseRole',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverDetails,
        name: 'driverDetails',
        builder: (context, state) => const DriverDetailsScreen(),
      ),

      // ── Rider Flow ─────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.driverHome,
        name: 'driverHome',
        builder: (context, state) => const DriverHome(),
      ),
      GoRoute(
        path: '${AppRoutes.driverRide}/:rideId',
        name: 'driverRide',
        builder: (context, state) {
          final rideId = state.pathParameters['rideId'] ?? '';
          return DriverRideScreen(rideId: rideId);
        },
      ),
      GoRoute(
        path: AppRoutes.driverRideHistory,
        name: 'driverRideHistory',
        builder: (context, state) => const DriverRideHistoryScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.rideHistory}/:userId',
        name: 'rideHistory',
        builder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return RideHistoryScreen(userId: userId);
        },
      ),
    ],

    // ─── Error page ────────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? '',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
