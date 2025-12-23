// Test Helper - Shared Mocks and Fixtures for Test Suite
// This file contains all mock classes and test data used across the test suite

import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/network/network_info.dart';
import 'package:shafeea/core/services/device_info_service.dart';
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shafeea/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shafeea/features/auth/domain/repositories/auth_repository.dart';
import 'package:shafeea/features/home/data/datasources/student_local_data_source.dart';
import 'package:shafeea/features/home/domain/repositories/student_repository.dart';
import 'package:shafeea/features/settings/domain/repositories/settings_repository.dart';
import 'package:shafeea/features/daily_tracking/domain/repositories/quran_repository.dart';
import 'package:shafeea/features/daily_tracking/domain/repositories/tracking_repository.dart';

// ============================================================================
// MOCK CLASSES - Auth Feature
// ============================================================================

/// Mock for AuthRepository (Domain Layer)
class MockAuthRepository extends Mock implements AuthRepository {}

/// Mock for AuthRemoteDataSource (Data Layer)
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

/// Mock for AuthLocalDataSource (Data Layer)
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// ============================================================================
// MOCK CLASSES - Home Feature
// ============================================================================

/// Mock for StudentRepository (Domain Layer)
class MockStudentRepository extends Mock implements StudentRepository {}

/// Mock for StudentLocalDataSource (Data Layer)
class MockStudentLocalDataSource extends Mock
    implements StudentLocalDataSource {}

// ============================================================================
// MOCK CLASSES - Settings Feature
// ============================================================================

/// Mock for SettingsRepository (Domain Layer)
class MockSettingsRepository extends Mock implements SettingsRepository {}

// ============================================================================
// MOCK CLASSES - Daily Tracking Feature
// ============================================================================

/// Mock for QuranRepository (Domain Layer)
class MockQuranRepository extends Mock implements QuranRepository {}

/// Mock for TrackingRepository (Domain Layer)
class MockTrackingRepository extends Mock implements TrackingRepository {}

// ============================================================================
// MOCK CLASSES - Core Services
// ============================================================================

/// Mock for NetworkInfo service
class MockNetworkInfo extends Mock implements NetworkInfo {}

/// Mock for DeviceInfoService
class MockDeviceInfoService extends Mock implements DeviceInfoService {}

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

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/// Helper function to register fallback values for Mocktail
/// Call this in setUp() of test files that use complex types
void registerFallbackValues() {
  // Register any custom types that need fallback values here
  // Example: registerFallbackValue(FakeMyCustomType());
}
