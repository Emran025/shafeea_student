import 'package:dio/dio.dart';
import 'package:shafeea/core/config/app_config.dart';

/// AppKeyInterceptor
///
/// Injects the `X-App-Key` header into every outgoing API request when the
/// application is running in School-Locked Mode.
///
/// ── School-Locked Mode ──────────────────────────────────────────────────────
/// When the APK is built with `--dart-define=APP_KEY=...`, [AppConfig.isSchoolLocked]
/// is true and this interceptor appends the key to every request. The backend
/// (ResolveSchoolFromAppKey middleware) validates this key and automatically
/// scopes all operations to the associated school. Users of this APK cannot
/// register or authenticate against any other school, even with valid credentials.
///
/// ── General Mode ────────────────────────────────────────────────────────────
/// When no APP_KEY is embedded (development builds or the generic APK), this
/// interceptor is a complete no-op. No header is added and the backend treats
/// the request as a General Mode client — full multi-school access as before.
///
/// This design is 100% backward compatible: existing behavior is preserved
/// without any code changes in controllers, repositories, or use-cases.
final class AppKeyInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Only inject the header in School-Locked builds.
    // In General Mode (APP_KEY is empty) this block is skipped entirely.
    if (AppConfig.isSchoolLocked) {
      options.headers['X-App-Key'] = AppConfig.appKey;
    }

    return handler.next(options);
  }
}
