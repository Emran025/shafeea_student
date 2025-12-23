// test/features/settings/presentation/bloc/settings_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/settings/domain/entities/faq_entity.dart';
import 'package:shafeea/features/settings/domain/entities/settings_entity.dart';
import 'package:shafeea/features/settings/domain/entities/user_profile_entity.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:shafeea/shared/themes/app_theme.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late SettingsBloc settingsBloc;
  late MockGetSettings mockGetSettings;
  late MockSaveTheme mockSaveTheme;
  late MockSetNotificationsPreference mockSetNotificationsPreference;
  late MockSetAnalyticsPreference mockSetAnalyticsPreference;
  late MockGetUserProfile mockGetUserProfile;
  late MockUpdateUserProfile mockUpdateUserProfile;
  late MockGetLatestPolicyUseCase mockGetLatestPolicy;
  late MockExportFollowUpReportsUseCase mockExportFollowUpReportsUseCase;
  late MockImportFollowUpReportsUseCase mockImportFollowUpReportsUseCase;
  late MockGetFaqsUseCase mockGetFaqsUseCase;
  late MockSubmitSupportTicketUseCase mockSubmitSupportTicketUseCase;
  late MockGetTermsOfUseUseCase mockGetTermsOfUseUseCase;

  setUp(() {
    registerFallbackValues();
    mockGetSettings = MockGetSettings();
    mockSaveTheme = MockSaveTheme();
    mockSetNotificationsPreference = MockSetNotificationsPreference();
    mockSetAnalyticsPreference = MockSetAnalyticsPreference();
    mockGetUserProfile = MockGetUserProfile();
    mockUpdateUserProfile = MockUpdateUserProfile();
    mockGetLatestPolicy = MockGetLatestPolicyUseCase();
    mockExportFollowUpReportsUseCase = MockExportFollowUpReportsUseCase();
    mockImportFollowUpReportsUseCase = MockImportFollowUpReportsUseCase();
    mockGetFaqsUseCase = MockGetFaqsUseCase();
    mockSubmitSupportTicketUseCase = MockSubmitSupportTicketUseCase();
    mockGetTermsOfUseUseCase = MockGetTermsOfUseUseCase();

    settingsBloc = SettingsBloc(
      getSettings: mockGetSettings,
      saveTheme: mockSaveTheme,
      setNotificationsPreference: mockSetNotificationsPreference,
      setAnalyticsPreference: mockSetAnalyticsPreference,
      getUserProfile: mockGetUserProfile,
      updateUserProfile: mockUpdateUserProfile,
      getLatestPolicy: mockGetLatestPolicy,
      exportFollowUpReportsUseCase: mockExportFollowUpReportsUseCase,
      importFollowUpReportsUseCase: mockImportFollowUpReportsUseCase,
      getFaqsUseCase: mockGetFaqsUseCase,
      submitSupportTicketUseCase: mockSubmitSupportTicketUseCase,
      getTermsOfUseUseCase: mockGetTermsOfUseUseCase,
    );
  });

  tearDown(() {
    settingsBloc.close();
  });

  const tSettings = SettingsEntity(
    themeType: AppThemeType.light,
    notificationsEnabled: true,
    analyticsEnabled: false,
  );

  const tUser = UserEntity(
    id: 1,
    name: 'Test',
    email: 'test@email.com',
    phone: '123',
  );

  const tUserProfile = UserProfileEntity(user: tUser, activeSessions: []);

  test('initial state should be SettingsInitial', () {
    expect(settingsBloc.state, equals(SettingsInitial()));
  });

  group('LoadInitialSettings', () {
    blocTest<SettingsBloc, SettingsState>(
      'should emit [SettingsLoadSuccess] when data is fetched successfully',
      build: () {
        when(
          () => mockGetSettings(any()),
        ).thenAnswer((_) async => const Right(tSettings));
        return settingsBloc;
      },
      act: (bloc) => bloc.add(LoadInitialSettings()),
      expect: () => [const SettingsLoadSuccess(settings: tSettings)],
    );

    blocTest<SettingsBloc, SettingsState>(
      'should emit [SettingsLoadFailure] when fetching data fails',
      build: () {
        when(
          () => mockGetSettings(any()),
        ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));
        return settingsBloc;
      },
      act: (bloc) => bloc.add(LoadInitialSettings()),
      expect: () => [
        const SettingsLoadFailure(ServerFailure(message: 'error')),
      ],
    );
    group('LoadUserProfile', () {
      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success] when profile is fetched successfully',
        build: () {
          when(
            () => mockGetUserProfile(any()),
          ).thenAnswer((_) async => const Right(tUserProfile));
          return settingsBloc;
        },
        seed: () => const SettingsLoadSuccess(settings: tSettings),
        act: (bloc) => bloc.add(LoadUserProfile()),
        expect: () => [
          const SettingsLoadSuccess(
            settings: tSettings,
            profileStatus: SectionStatus.loading,
          ),
          const SettingsLoadSuccess(
            settings: tSettings,
            profileStatus: SectionStatus.success,
            userProfile: tUserProfile,
          ),
        ],
      );
    });

    group('ThemeChanged', () {
      blocTest<SettingsBloc, SettingsState>(
        'should call saveTheme and re-fetch settings',
        build: () {
          when(
            () => mockSaveTheme(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetSettings(any()),
          ).thenAnswer((_) async => const Right(tSettings));
          return settingsBloc;
        },
        seed: () => const SettingsLoadSuccess(settings: tSettings),
        act: (bloc) => bloc.add(const ThemeChanged(AppThemeType.dark)),
        verify: (_) {
          verify(() => mockSaveTheme(any())).called(1);
          verify(() => mockGetSettings(any())).called(1);
        },
      );
    });

    group('NotificationsPreferenceChanged', () {
      blocTest<SettingsBloc, SettingsState>(
        'should call setNotificationsPreference and re-fetch settings',
        build: () {
          when(
            () => mockSetNotificationsPreference(any()),
          ).thenAnswer((_) async => const Right(null));
          when(
            () => mockGetSettings(any()),
          ).thenAnswer((_) async => const Right(tSettings));
          return settingsBloc;
        },
        seed: () => const SettingsLoadSuccess(settings: tSettings),
        act: (bloc) => bloc.add(const NotificationsPreferenceChanged(true)),
        verify: (_) {
          verify(() => mockSetNotificationsPreference(any())).called(1);
        },
      );
    });

    group('UpdateProfileRequested', () {
      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success] and update profile on success',
        build: () {
          when(
            () => mockUpdateUserProfile(any()),
          ).thenAnswer((_) async => const Right(null));
          return settingsBloc;
        },
        seed: () => const SettingsLoadSuccess(
          settings: tSettings,
          userProfile: tUserProfile,
        ),
        act: (bloc) => bloc.add(const UpdateProfileRequested(tUserProfile)),
        expect: () => [
          const SettingsLoadSuccess(
            settings: tSettings,
            userProfile: tUserProfile,
            actionStatus: ActionStatus.loading,
          ),
          const SettingsLoadSuccess(
            settings: tSettings,
            userProfile: tUserProfile,
            actionStatus: ActionStatus.success,
          ),
        ],
      );
    });

    group('FetchFaqs', () {
      final tFaq = FaqEntity(id: 1, question: 'Q', answer: 'A', viewCount: 0);

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success] and append FAQs',
        build: () {
          when(
            () => mockGetFaqsUseCase(any()),
          ).thenAnswer((_) async => Right([tFaq]));
          return settingsBloc;
        },
        seed: () => const SettingsLoadSuccess(settings: tSettings),
        act: (bloc) => bloc.add(FetchFaqs()),
        expect: () => [
          const SettingsLoadSuccess(
            settings: tSettings,
            faqsStatus: SectionStatus.loading,
          ),
          SettingsLoadSuccess(
            settings: tSettings,
            faqsStatus: SectionStatus.success,
            faqs: [tFaq],
          ),
        ],
      );
    });
  });
}
