import 'package:go_router/go_router.dart';
import 'package:shafeea/features/auth/presentation/ui/screens/login_screen.dart';
import 'package:shafeea/features/app/pages/splash_screen.dart';
import 'package:shafeea/features/app/pages/welcome_screen.dart';
import 'package:shafeea/features/home/presentation/ui/screens/home_screen.dart';
import 'package:shafeea/features/auth/presentation/ui/screens/verify_email_screen.dart';
import 'package:shafeea/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/ui/screens/create_student_account_page.dart';
import '../features/home/presentation/ui/screens/student_profile_screen.dart';

/// The main router configuration for the application.
///
/// This GoRouter instance handles all navigation logic, including authentication-based
/// redirects and the definition of all available routes.

// We need to listen to both streams now!
final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final bool loggedIn = authState.authStatus == AuthStatus.authenticated;
    final bool verifying = state.matchedLocation == '/verify_email';
    final bool isEmailVerified = authState.user?.isEmailVerified ?? false;

    if (!loggedIn) {
      // Not logged in: allow access only to public routes
      final bool publicRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/welcome' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/register-student';
      return publicRoute ? null : '/welcome';
    }

    // Logged in: check for email verification
    if (!isEmailVerified) {
       return verifying ? null : '/verify_email';
    }

    // Verified: don't allow access to verify_email or auth screens
    if (verifying || state.matchedLocation == '/login' || state.matchedLocation == '/welcome' || state.matchedLocation == '/register-student') {
      return '/home';
    }

    return null;
  },

  routes: [
    /// Defines the route for the splash screen, shown on app startup.
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),

    /// Defines the route for the welcome screen, the first screen for unauthenticated users.
    GoRoute(
      path: '/welcome',
      name: 'welcome',
      builder: (_, __) => const WelcomeScreen(),
    ),

    /// Defines the route for the login screen.
    GoRoute(
      path: '/login', // Using snake_case for consistency
      name: 'login',
      builder: (_, __) => const LogInScreen(),
    ),

    /// Defines the route for the email verification screen.
    GoRoute(
      path: '/verify_email',
      name: 'verify_email',
      builder: (_, __) => const VerifyEmailScreen(),
    ),

    /// Defines the route for the login screen.
    GoRoute(
      path: '/register-student', // Using snake_case for consistency
      name: 'register-student',
      builder: (_, __) => const CreateStudentAccountPage(),
    ),

    /// Defines the route for the main dashboard for teacher users.
    GoRoute(
      path: '/home',
      name: 'home',
      // Note: Ensure the class name 'Dashboard' is correct.
      // It might be a typo for 'TeacherDashboard'.
      // builder: (_, __) => const SupervisorDashboard(),
      builder: (_, __) => const Dashboard(),
    ),
    GoRoute(
      path: '/profile/:id',
      name: 'profile',
      builder: (context, state) {
        return StudentProfileScreen();
      },
    ),
  ],
);
