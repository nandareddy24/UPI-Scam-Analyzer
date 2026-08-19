import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/upi_scanner_screen.dart';
import 'screens/phone_scanner_screen.dart';
import 'screens/sms_scanner_screen.dart';
import 'screens/url_scanner_screen.dart';
import 'screens/ocr_scanner_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/apk_scanner_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.asData?.value != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/forgot-password';

      if (isLoading) return null;

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return OtpScreen(
            email: extra['email'] ?? '',
            purpose: extra['purpose'] ?? 'registration',
            newPassword: extra['newPassword'],
          );
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
      ),
      GoRoute(
        path: '/scan-hub',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
      ),
      GoRoute(
        path: '/scan-upi',
        builder: (context, state) => const UpiScannerScreen(),
      ),
      GoRoute(
        path: '/scan-phone',
        builder: (context, state) => const PhoneScannerScreen(),
      ),
      GoRoute(
        path: '/scan-sms',
        builder: (context, state) => const SmsScannerScreen(),
      ),
      GoRoute(
        path: '/scan-url',
        builder: (context, state) => const UrlScannerScreen(),
      ),
      GoRoute(
        path: '/scan-ocr',
        builder: (context, state) => const OcrScannerScreen(),
      ),
      GoRoute(
        path: '/scan-qr',
        builder: (context, state) => const QrScannerScreen(),
      ),
      GoRoute(
        path: '/scan-apk',
        builder: (context, state) => const ApkScannerScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const MainNavigationScreen(initialIndex: 4),
      ),
    ],
  );
});

class ScamShieldApp extends ConsumerWidget {
  const ScamShieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'UPI Scam Analyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
