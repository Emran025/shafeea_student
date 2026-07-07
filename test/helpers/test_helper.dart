// Test Helper - Shared Mocks and Fixtures for Test Suite
// This file contains all mock classes and test data used across the test suite

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/api/api_consumer.dart';
import 'package:shafeea/core/network/network_info.dart';
import 'package:shafeea/core/services/device_info_service.dart';
import 'package:shafeea/features/auth/domain/usecases/resend_verification_usecase.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/save_draft_mistakes_use_case.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shafeea/core/database/app_database.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shafeea/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shafeea/features/auth/domain/repositories/auth_repository.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shafeea/features/home/data/services/student_sync_service.dart';
import 'package:shafeea/features/daily_tracking/data/datasources/tracking_local_data_source.dart';
import 'package:shafeea/features/daily_tracking/data/datasources/quran_local_data_source.dart';
import 'package:shafeea/features/home/data/datasources/student_local_data_source.dart';
import 'package:shafeea/features/home/data/datasources/student_remote_data_source.dart';
import 'package:shafeea/features/auth/domain/usecases/get_all_users_use_case.dart';
import 'package:shafeea/features/auth/domain/usecases/register_student_usecase.dart';
import 'package:shafeea/features/home/domain/repositories/student_repository.dart';
import 'package:shafeea/features/settings/domain/repositories/settings_repository.dart';
import 'package:shafeea/features/home/domain/entities/tracking_detail_entity.dart';
import 'package:shafeea/core/models/tracking_type.dart';
import 'package:shafeea/features/home/domain/entities/chart_filter.dart';
import 'package:shafeea/features/settings/domain/entities/user_profile_entity.dart';
import 'package:shafeea/features/auth/domain/entities/device_info_entity.dart';
import 'package:shafeea/features/auth/domain/entities/student_applicant.dart';
import 'package:shafeea/core/models/gender.dart';
import 'package:shafeea/shared/themes/app_theme.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/core/entities/tracking_unit.dart';
import 'package:shafeea/features/auth/domain/usecases/login_usecase.dart';
import 'package:shafeea/features/auth/domain/usecases/check_login_usecase.dart';
import 'package:shafeea/features/auth/domain/usecases/logout_usecase.dart';
import 'package:shafeea/features/auth/domain/usecases/forget_password_usecase.dart';
import 'package:shafeea/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:shafeea/features/auth/domain/usecases/switch_user_usecase.dart';
import 'package:shafeea/features/home/domain/usecases/delete_student_usecase.dart';
import 'package:shafeea/features/home/domain/usecases/get_plan_for_the_day.dart';
import 'package:shafeea/features/home/domain/usecases/get_student_by_id.dart';
import 'package:shafeea/features/home/domain/usecases/upsert_student_usecase.dart';
import 'package:shafeea/features/daily_tracking/domain/repositories/quran_repository.dart';
import 'package:shafeea/features/daily_tracking/domain/repositories/tracking_repository.dart';
import 'package:shafeea/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:shafeea/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:shafeea/features/settings/domain/usecases/export_follow_up_reports_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/get_faqs_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/get_latest_policy_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/get_settings.dart';
import 'package:shafeea/features/settings/domain/usecases/get_terms_of_use_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/get_user_profile.dart';
import 'package:shafeea/features/settings/domain/usecases/import_follow_up_reports_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/save_theme.dart';
import 'package:shafeea/features/settings/domain/usecases/set_analytics_preference.dart';
import 'package:shafeea/features/settings/domain/usecases/set_notifications_preference.dart';
import 'package:shafeea/features/settings/domain/usecases/submit_support_ticket_usecase.dart';
import 'package:shafeea/features/settings/domain/usecases/update_user_profile.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/generate_follow_up_report_use_case.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_all_mistakes.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_error_analysis_chart_data.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_mistakes_ayahs.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_or_create_today_tracking.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_page_data.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/get_surahs_list.dart';
import 'package:shafeea/features/daily_tracking/domain/usecases/save_task_progress.dart';
import 'package:shafeea/features/daily_tracking/presentation/view_models/factories/follow_up_report_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// MOCK CLASSES - Auth Feature
// ============================================================================

/// Mock for AuthRepository (Domain Layer)
class MockApiConsumer extends Mock implements ApiConsumer {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock for AuthRemoteDataSource (Data Layer)
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

/// Mock for AuthLocalDataSource (Data Layer)
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockTrackingLocalDataSource extends Mock
    implements TrackingLocalDataSource {}

class MockStudentSyncService extends Mock implements StudentSyncService {}

// ============================================================================
// MOCK CLASSES - Auth Use Cases
// ============================================================================

class MockLogInUseCase extends Mock implements LogInUseCase {}

class MockCheckLogInUseCase extends Mock implements CheckLogInUseCase {}

class MockLogOutUseCase extends Mock implements LogOutUseCase {}

class MockForgetPasswordUseCase extends Mock implements ForgetPasswordUseCase {}

class MockChangePasswordUseCase extends Mock implements ChangePasswordUseCase {}

class MockRegisterStudentUseCase extends Mock
    implements RegisterStudentUseCase {}

class MockGetAllUsersUseCase extends Mock implements GetAllUsersUseCase {}

class MockSwitchUserUseCase extends Mock implements SwitchUserUseCase {}

class MockResendVerificationEmailUseCase extends Mock
    implements ResendVerificationEmailUseCase {}

// ============================================================================
// MOCK CLASSES - Home Feature
// ============================================================================

/// Mock for StudentRepository (Domain Layer)
class MockStudentRepository extends Mock implements StudentRepository {}

/// Mock for StudentLocalDataSource (Data Layer)
class MockStudentLocalDataSource extends Mock
    implements StudentLocalDataSource {}

class MockDeleteStudentUseCase extends Mock implements DeleteStudentUseCase {}

class MockGetPlanForTheDay extends Mock implements GetPlanForTheDay {}

class MockGetStudentById extends Mock implements GetStudentById {}

class MockUpsertStudent extends Mock implements UpsertStudent {}

class MockQuranLocalDataSource extends Mock implements QuranLocalDataSource {}

class MockStudentRemoteDataSource extends Mock
    implements StudentRemoteDataSource {}

// ============================================================================
// MOCK CLASSES - Settings Feature
// ============================================================================

/// Mock for SettingsRepository (Domain Layer)
class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSettingsRemoteDataSource extends Mock
    implements SettingsRemoteDataSource {}

class MockSettingsLocalDataSource extends Mock
    implements SettingsLocalDataSource {}

class MockGetSettings extends Mock implements GetSettings {}

class MockSaveTheme extends Mock implements SaveTheme {}

class MockSetNotificationsPreference extends Mock
    implements SetNotificationsPreference {}

class MockSetAnalyticsPreference extends Mock
    implements SetAnalyticsPreference {}

class MockGetUserProfile extends Mock implements GetUserProfile {}

class MockUpdateUserProfile extends Mock implements UpdateUserProfile {}

class MockGetLatestPolicyUseCase extends Mock
    implements GetLatestPolicyUseCase {}

class MockExportFollowUpReportsUseCase extends Mock
    implements ExportFollowUpReportsUseCase {}

class MockImportFollowUpReportsUseCase extends Mock
    implements ImportFollowUpReportsUseCase {}

class MockGetFaqsUseCase extends Mock implements GetFaqsUseCase {}

class MockSubmitSupportTicketUseCase extends Mock
    implements SubmitSupportTicketUseCase {}

class MockGetTermsOfUseUseCase extends Mock implements GetTermsOfUseUseCase {}

// ============================================================================
// MOCK CLASSES - Daily Tracking Feature
// ============================================================================

/// Mock for QuranRepository (Domain Layer)
class MockQuranRepository extends Mock implements QuranRepository {}

/// Mock for TrackingRepository (Domain Layer)
class MockTrackingRepository extends Mock implements TrackingRepository {}

class MockGetOrCreateTodayTrackingDetails extends Mock
    implements GetOrCreateTodayTrackingDetails {}

class MockSaveTaskProgress extends Mock implements SaveTaskProgress {}
class MocksaveDraftMistakes extends Mock implements SaveDraftMistakesUseCase {}

class MockGetAllMistakes extends Mock implements GetAllMistakes {}

class MockGetErrorAnalysisChartData extends Mock
    implements GetErrorAnalysisChartData {}

class MockGetMistakesAyahs extends Mock implements GetMistakesAyahs {}

class MockGetPageData extends Mock implements GetPageData {}

class MockGetSurahsList extends Mock implements GetSurahsList {}

class MockGenerateFollowUpReportUseCase extends Mock
    implements GenerateFollowUpReportUseCase {}

class MockFollowUpReportFactory extends Mock implements FollowUpReportFactory {}

// ============================================================================
// MOCK CLASSES - Core Services
// ============================================================================

/// Mock for NetworkInfo service
class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockInternetConnection extends Mock implements InternetConnection {}

/// Mock for DeviceInfoService
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class MockDatabase extends Mock implements Database {}

class MockAppDatabase extends Mock implements AppDatabase {}

// ============================================================================
// TEST FIXTURES - Sample Data
// ============================================================================

/// Sample User JSON data for testing
const Map<String, dynamic> tUserJson = {
  'id': 1,
  'name': 'فارس عبد الجبار',
  'email': 'fares.abduljabbar@example.com',
  'phone': '+1234567890',
  'avatar': 'https://example.com/avatar.png',
};

/// Sample Auth Response JSON data for testing
const Map<String, dynamic> tAuthResponseJson = {
  'access_token': 'test_access_token_123456',
  'refreshToken': 'test_refresh_token_abcdef',
  'role': 1,
  'user': tUserJson,
};

/// Sample Login Request JSON
const Map<String, dynamic> tLoginRequestJson = {
  'login': 'test@example.com',
  'password': 'Password123!',
  'device_name': 'Test Device',
  'device_id': 'test-device-id-12345',
  'device_type': 'Android',
  'device_os_version': '13',
  'app_version': '1.0.0',
};

/// Sample Success Response JSON
const Map<String, dynamic> tSuccessJson = {
  'status': 'success',
  'message': 'Operation completed successfully',
};

/// Sample Error Response JSON
const Map<String, dynamic> tErrorJson = {
  'status': 'error',
  'message': 'Something went wrong',
};

/// Sample Student JSON data for testing
const Map<String, dynamic> tStudentJson = {
  'id': 'student-uuid-123',
  'name': 'Ahmed Ali',
  'age': 12,
  'guardian_phone': '+966501234567',
  'notes': 'Test student notes',
  'created_at': '2024-01-01T00:00:00.000Z',
  'updated_at': '2024-01-01T00:00:00.000Z',
};

/// Sample FAQ JSON data for testing
const Map<String, dynamic> tFaqJson = {
  'id': 1,
  'question': 'How to use the app?',
  'answer': 'Follow the onboarding guide...',
  'category': 'general',
};

const tDeviceInfoEntity = DeviceInfoEntity(
  deviceId: 'test-device-id-12345',
  deviceModel: 'Pixel 6',
  manufacturer: 'Google',
  osVersion: '13',
  appVersion: '1.0.0',
  timezone: 'UTC',
  locale: 'en_US',
  pushNotificationToken: 'fcm_token_123',
);

const tStudentApplicant = StudentApplicantEntity(
  name: 'Ahmed Ali',
  email: 'ahmed@example.com',
  password: 'SecurePass123!',
  bio: 'Student bio information',
  qualifications: 'High school diploma',
  memorizationLevel: 5,
  gender: Gender.male,
  birthDate: '2005-01-15',
  phone: '+966501234567',
  phoneZone: '+966',
  whatsapp: '+966501234567',
  whatsappZone: '+966',
  country: 'Saudi Arabia',
  residence: 'Riyadh',
);

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Helper function to register fallback values for Mocktail
/// Call this in setUp() of test files that use complex types
void registerFallbackValues() {
  registerFallbackValue(SaveThemeParams(themeType: AppThemeType.light));
  registerFallbackValue(
    const SetNotificationsPreferenceParams(isEnabled: true),
  );
  registerFallbackValue(const SetAnalyticsPreferenceParams(isEnabled: true));
  registerFallbackValue(
    UpdateUserProfileParams(
      userProfile: UserProfileEntity(
        user: const UserEntity(id: 1, name: '', email: '', phone: ''),
        activeSessions: const [],
      ),
    ),
  );
  registerFallbackValue(GetFaqsParams(page: 1));
  registerFallbackValue(
    SaveTaskProgressParams(
      detail: TrackingDetailEntity(
        id: 1,
        uuid: 'uuid',
        trackingId: '1',
        trackingTypeId: TrackingType.memorization,
        fromTrackingUnitId: TrackingUnitDetail(1, 1, '', 1, 1, '', 1, 1),
        toTrackingUnitId: TrackingUnitDetail(1, 1, '', 1, 1, '', 1, 1),
        actualAmount: 1,
        comment: '',
        status: '',
        score: 1,
        gap: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        mistakes: const [],
      ),
    ),
  );
  registerFallbackValue(const GetAllMistakesParams());
  registerFallbackValue(
    const GetErrorAnalysisChartDataParams(
      filter: ChartFilter(timePeriod: 'month'),
    ),
  );
  registerFallbackValue(const GetMistakesAyahsParams(ayahsNumbers: []));
  registerFallbackValue(const GetPageDataParams(pageNumber: 1));
}
