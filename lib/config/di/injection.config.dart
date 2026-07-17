// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:device_info_plus/device_info_plus.dart' as _i833;
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shafeea/config/di/injection.dart' as _i31;
import 'package:shafeea/config/di/register_module.dart' as _i644;
import 'package:shafeea/core/api/api_consumer.dart' as _i733;
import 'package:shafeea/core/background/background_job_service.dart' as _i752;
import 'package:shafeea/core/background/workmanager_job_service_impl.dart'
    as _i54;
import 'package:shafeea/core/database/app_database.dart' as _i396;
import 'package:shafeea/core/network/network_info.dart' as _i672;
import 'package:shafeea/core/network/network_info_impl.dart' as _i428;
import 'package:shafeea/core/services/device_info_service.dart' as _i222;
import 'package:shafeea/core/services/dummy_push_notification_service_impl.dart'
    as _i975;
import 'package:shafeea/core/services/push_notification_service.dart' as _i228;
import 'package:shafeea/features/app/cubit/app_setup_cubit.dart' as _i478;
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source.dart'
    as _i234;
import 'package:shafeea/features/auth/data/datasources/auth_local_data_source_impl.dart'
    as _i1018;
import 'package:shafeea/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i672;
import 'package:shafeea/features/auth/data/datasources/auth_remote_data_source_impl.dart'
    as _i287;
import 'package:shafeea/features/auth/data/repositories_impl/auth_repository_impl.dart'
    as _i950;
import 'package:shafeea/features/auth/domain/repositories/auth_repository.dart'
    as _i424;
import 'package:shafeea/features/auth/domain/usecases/auth_check_username_usecase.dart'
    as _i1032;
import 'package:shafeea/features/auth/domain/usecases/auth_suggest_username_usecase.dart'
    as _i822;
import 'package:shafeea/features/auth/domain/usecases/change_password_usecase.dart'
    as _i960;
import 'package:shafeea/features/auth/domain/usecases/check_login_usecase.dart'
    as _i186;
import 'package:shafeea/features/auth/domain/usecases/forget_password_usecase.dart'
    as _i426;
import 'package:shafeea/features/auth/domain/usecases/get_all_users_use_case.dart'
    as _i1045;
import 'package:shafeea/features/auth/domain/usecases/get_schools_usecase.dart'
    as _i577;
import 'package:shafeea/features/auth/domain/usecases/login_usecase.dart'
    as _i250;
import 'package:shafeea/features/auth/domain/usecases/logout_usecase.dart'
    as _i871;
import 'package:shafeea/features/auth/domain/usecases/register_student_usecase.dart'
    as _i268;
import 'package:shafeea/features/auth/domain/usecases/resend_verification_usecase.dart'
    as _i334;
import 'package:shafeea/features/auth/domain/usecases/switch_user_usecase.dart'
    as _i741;
import 'package:shafeea/features/auth/presentation/bloc/auth_bloc.dart'
    as _i708;
import 'package:shafeea/features/daily_tracking/data/datasources/quran_local_data_source.dart'
    as _i750;
import 'package:shafeea/features/daily_tracking/data/datasources/quran_local_data_source_impl.dart'
    as _i117;
import 'package:shafeea/features/daily_tracking/data/datasources/tracking_local_data_source.dart'
    as _i1022;
import 'package:shafeea/features/daily_tracking/data/datasources/tracking_local_data_source_impl.dart'
    as _i348;
import 'package:shafeea/features/daily_tracking/data/repositories/quran_repository_impl.dart'
    as _i210;
import 'package:shafeea/features/daily_tracking/data/repositories/tracking_repository_impl.dart'
    as _i431;
import 'package:shafeea/features/daily_tracking/domain/repositories/quran_repository.dart'
    as _i611;
import 'package:shafeea/features/daily_tracking/domain/repositories/tracking_repository.dart'
    as _i341;
import 'package:shafeea/features/daily_tracking/domain/usecases/generate_follow_up_report_use_case.dart'
    as _i268;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_all_mistakes.dart'
    as _i500;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_error_analysis_chart_data.dart'
    as _i618;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_mistakes_ayahs.dart'
    as _i1010;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_or_create_today_tracking.dart'
    as _i949;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_page_data.dart'
    as _i331;
import 'package:shafeea/features/daily_tracking/domain/usecases/get_surahs_list.dart'
    as _i359;
import 'package:shafeea/features/daily_tracking/domain/usecases/save_draft_mistakes_use_case.dart'
    as _i692;
import 'package:shafeea/features/daily_tracking/domain/usecases/save_task_progress.dart'
    as _i587;
import 'package:shafeea/features/daily_tracking/presentation/bloc/error_analysis_chart_bloc.dart'
    as _i2;
import 'package:shafeea/features/daily_tracking/presentation/bloc/quran_reader_bloc.dart'
    as _i8;
import 'package:shafeea/features/daily_tracking/presentation/bloc/tracking_session_bloc.dart'
    as _i820;
import 'package:shafeea/features/daily_tracking/presentation/view_models/factories/follow_up_report_factory.dart'
    as _i799;
import 'package:shafeea/features/home/data/datasources/student_local_data_source.dart'
    as _i155;
import 'package:shafeea/features/home/data/datasources/student_local_data_source_impl.dart'
    as _i1007;
import 'package:shafeea/features/home/data/datasources/student_remote_data_source.dart'
    as _i183;
import 'package:shafeea/features/home/data/datasources/student_remote_data_source_impl.dart'
    as _i941;
import 'package:shafeea/features/home/data/repositories_impl/student_repository_impl.dart'
    as _i408;
import 'package:shafeea/features/home/data/services/student_sync_service.dart'
    as _i331;
import 'package:shafeea/features/home/data/services/student_sync_service_impl.dart'
    as _i148;
import 'package:shafeea/features/home/domain/repositories/student_repository.dart'
    as _i634;
import 'package:shafeea/features/home/domain/usecases/delete_student_usecase.dart'
    as _i564;
import 'package:shafeea/features/home/domain/usecases/get_plan_for_the_day.dart'
    as _i314;
import 'package:shafeea/features/home/domain/usecases/get_student_by_id.dart'
    as _i1070;
import 'package:shafeea/features/home/domain/usecases/save_student_plan.dart'
    as _i60;
import 'package:shafeea/features/home/domain/usecases/upsert_student_usecase.dart'
    as _i43;
import 'package:shafeea/features/home/presentation/bloc/student_bloc.dart'
    as _i516;
import 'package:shafeea/features/settings/data/datasources/settings_local_data_source.dart'
    as _i950;
import 'package:shafeea/features/settings/data/datasources/settings_local_data_source_impl.dart'
    as _i854;
import 'package:shafeea/features/settings/data/datasources/settings_remote_data_source.dart'
    as _i38;
import 'package:shafeea/features/settings/data/datasources/settings_remote_data_source_impl.dart'
    as _i825;
import 'package:shafeea/features/settings/data/repositories_impl/settings_repository_impl.dart'
    as _i900;
import 'package:shafeea/features/settings/domain/repositories/settings_repository.dart'
    as _i844;
import 'package:shafeea/features/settings/domain/usecases/export_follow_up_reports_usecase.dart'
    as _i42;
import 'package:shafeea/features/settings/domain/usecases/get_faqs_usecase.dart'
    as _i1001;
import 'package:shafeea/features/settings/domain/usecases/get_latest_policy_usecase.dart'
    as _i356;
import 'package:shafeea/features/settings/domain/usecases/get_settings.dart'
    as _i24;
import 'package:shafeea/features/settings/domain/usecases/get_terms_of_use_usecase.dart'
    as _i830;
import 'package:shafeea/features/settings/domain/usecases/get_user_profile.dart'
    as _i117;
import 'package:shafeea/features/settings/domain/usecases/import_follow_up_reports_usecase.dart'
    as _i204;
import 'package:shafeea/features/settings/domain/usecases/save_theme.dart'
    as _i1062;
import 'package:shafeea/features/settings/domain/usecases/set_analytics_preference.dart'
    as _i892;
import 'package:shafeea/features/settings/domain/usecases/set_notifications_preference.dart'
    as _i256;
import 'package:shafeea/features/settings/domain/usecases/submit_support_ticket_usecase.dart'
    as _i402;
import 'package:shafeea/features/settings/domain/usecases/update_user_profile.dart'
    as _i957;
import 'package:shafeea/features/settings/presentation/bloc/settings_bloc.dart'
    as _i790;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:sqflite/sqflite.dart' as _i779;
import 'package:workmanager/workmanager.dart' as _i500;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final blocModule = _$BlocModule();
    final registerModule = _$RegisterModule();
    gh.factory<_i478.AppSetupCubit>(() => blocModule.appSetupCubit());
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i799.FollowUpReportFactory>(
      () => _i799.FollowUpReportFactory(),
    );
    gh.lazySingleton<_i396.AppDatabase>(() => registerModule.appDatabase);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => registerModule.connectionChecker,
    );
    gh.lazySingleton<_i833.DeviceInfoPlugin>(
      () => registerModule.deviceInfoPlugin,
    );
    gh.lazySingleton<_i500.Workmanager>(() => registerModule.workmanager);
    gh.lazySingleton<_i752.BackgroundJobService>(
      () => _i54.WorkmanagerJobServiceImpl(),
    );
    gh.lazySingleton<_i750.QuranLocalDataSource>(
      () => _i117.QuranLocalDataSourceImpl(),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dioForTokenRefreshInstance(),
      instanceName: 'DioForTokenRefresh',
    );
    gh.lazySingleton<_i228.PushNotificationService>(
      () => _i975.DummyPushNotificationServiceImpl(),
    );
    gh.lazySingleton<_i611.QuranRepository>(
      () => _i210.QuranRepositoryImpl(
        localDataSource: gh<_i750.QuranLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i234.AuthLocalDataSource>(
      () => _i1018.AuthLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        secureStorage: gh<_i558.FlutterSecureStorage>(),
      ),
    );
    gh.lazySingleton<_i950.SettingsLocalDataSource>(
      () => _i854.SettingsLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
        appDatabase: gh<_i396.AppDatabase>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => registerModule.dio(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i361.Dio>(instanceName: 'DioForTokenRefresh'),
      ),
    );
    gh.lazySingleton<_i222.DeviceInfoService>(
      () => _i222.DeviceInfoServiceImpl(
        deviceInfoPlugin: gh<_i833.DeviceInfoPlugin>(),
        pushNotificationService: gh<_i228.PushNotificationService>(),
      ),
    );
    await gh.factoryAsync<_i779.Database>(
      () => registerModule.database(gh<_i396.AppDatabase>()),
      preResolve: true,
    );
    gh.lazySingleton<_i1010.GetMistakesAyahs>(
      () => _i1010.GetMistakesAyahs(repository: gh<_i611.QuranRepository>()),
    );
    gh.lazySingleton<_i331.GetPageData>(
      () => _i331.GetPageData(repository: gh<_i611.QuranRepository>()),
    );
    gh.lazySingleton<_i359.GetSurahsList>(
      () => _i359.GetSurahsList(repository: gh<_i611.QuranRepository>()),
    );
    gh.lazySingleton<_i672.NetworkInfo>(
      () => _i428.NetworkInfoImpl(
        connectionChecker: gh<_i161.InternetConnection>(),
      ),
    );
    gh.lazySingleton<_i733.ApiConsumer>(
      () => registerModule.apiConsumer(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i38.SettingsRemoteDataSource>(
      () => _i825.SettingsRemoteDataSourceImpl(api: gh<_i733.ApiConsumer>()),
    );
    gh.lazySingleton<_i155.StudentLocalDataSource>(
      () => _i1007.StudentLocalDataSourceImpl(
        database: gh<_i779.Database>(),
        authLocalDataSource: gh<_i234.AuthLocalDataSource>(),
      ),
    );
    gh.factory<_i8.QuranReaderBloc>(
      () => blocModule.quranReaderBloc(
        gh<_i359.GetSurahsList>(),
        gh<_i1010.GetMistakesAyahs>(),
        gh<_i331.GetPageData>(),
      ),
    );
    gh.lazySingleton<_i1022.TrackingLocalDataSource>(
      () => _i348.TrackingLocalDataSourceImpl(
        gh<_i396.AppDatabase>(),
        gh<_i750.QuranLocalDataSource>(),
        gh<_i234.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i341.TrackingRepository>(
      () => _i431.TrackingRepositoryImpl(
        localDataSource: gh<_i1022.TrackingLocalDataSource>(),
        studentLocalDataSource: gh<_i155.StudentLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i183.StudentRemoteDataSource>(
      () => _i941.StudentRemoteDataSourceImpl(
        apiConsumer: gh<_i733.ApiConsumer>(),
      ),
    );
    gh.lazySingleton<_i672.AuthRemoteDataSource>(
      () => _i287.AuthRemoteDataSourceImpl(gh<_i733.ApiConsumer>()),
    );
    gh.lazySingleton<_i268.GenerateFollowUpReportUseCase>(
      () => _i268.GenerateFollowUpReportUseCase(
        gh<_i341.TrackingRepository>(),
        gh<_i799.FollowUpReportFactory>(),
      ),
    );
    gh.lazySingleton<_i500.GetAllMistakes>(
      () => _i500.GetAllMistakes(gh<_i341.TrackingRepository>()),
    );
    gh.lazySingleton<_i618.GetErrorAnalysisChartData>(
      () => _i618.GetErrorAnalysisChartData(gh<_i341.TrackingRepository>()),
    );
    gh.lazySingleton<_i949.GetOrCreateTodayTrackingDetails>(
      () =>
          _i949.GetOrCreateTodayTrackingDetails(gh<_i341.TrackingRepository>()),
    );
    gh.lazySingleton<_i692.SaveDraftMistakesUseCase>(
      () => _i692.SaveDraftMistakesUseCase(gh<_i341.TrackingRepository>()),
    );
    gh.lazySingleton<_i587.SaveTaskProgress>(
      () => _i587.SaveTaskProgress(gh<_i341.TrackingRepository>()),
    );
    gh.lazySingleton<_i331.StudentSyncService>(
      () => _i148.StudentSyncServiceImpl(
        remoteDataSource: gh<_i183.StudentRemoteDataSource>(),
        localDataSource: gh<_i155.StudentLocalDataSource>(),
        authLocalDataSource: gh<_i234.AuthLocalDataSource>(),
        networkInfo: gh<_i672.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i844.SettingsRepository>(
      () => _i900.SettingsRepositoryImpl(
        localDataSource: gh<_i950.SettingsLocalDataSource>(),
        remoteDataSource: gh<_i38.SettingsRemoteDataSource>(),
        networkInfo: gh<_i672.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i634.StudentRepository>(
      () => _i408.StudentRepositoryImpl(
        localDataSource: gh<_i155.StudentLocalDataSource>(),
        trackingLocalDataSource: gh<_i1022.TrackingLocalDataSource>(),
        remoteDataSource: gh<_i183.StudentRemoteDataSource>(),
        syncService: gh<_i331.StudentSyncService>(),
      ),
    );
    gh.lazySingleton<_i356.GetLatestPolicyUseCase>(
      () => _i356.GetLatestPolicyUseCase(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i24.GetSettings>(
      () => _i24.GetSettings(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i117.GetUserProfile>(
      () => _i117.GetUserProfile(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i1062.SaveTheme>(
      () => _i1062.SaveTheme(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i892.SetAnalyticsPreference>(
      () => _i892.SetAnalyticsPreference(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i256.SetNotificationsPreference>(
      () => _i256.SetNotificationsPreference(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i957.UpdateUserProfile>(
      () => _i957.UpdateUserProfile(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i424.AuthRepository>(
      () => _i950.AuthRepositoryImpl(
        remoteDataSource: gh<_i672.AuthRemoteDataSource>(),
        localDataSource: gh<_i234.AuthLocalDataSource>(),
        studentLocalDataSource: gh<_i155.StudentLocalDataSource>(),
        deviceInfoService: gh<_i222.DeviceInfoService>(),
        networkInfo: gh<_i672.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i1045.GetAllUsersUseCase>(
      () => _i1045.GetAllUsersUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i268.RegisterStudentUseCase>(
      () => _i268.RegisterStudentUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i741.SwitchUserUseCase>(
      () => _i741.SwitchUserUseCase(gh<_i424.AuthRepository>()),
    );
    gh.factory<_i426.ForgetPasswordUseCase>(
      () => _i426.ForgetPasswordUseCase(gh<_i424.AuthRepository>()),
    );
    gh.factory<_i250.LogInUseCase>(
      () => _i250.LogInUseCase(gh<_i424.AuthRepository>()),
    );
    gh.factory<_i871.LogOutUseCase>(
      () => _i871.LogOutUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i960.ChangePasswordUseCase>(
      () => _i960.ChangePasswordUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i186.CheckLogInUseCase>(
      () => _i186.CheckLogInUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i334.ResendVerificationEmailUseCase>(
      () => _i334.ResendVerificationEmailUseCase(gh<_i424.AuthRepository>()),
    );
    gh.factory<_i2.ErrorAnalysisChartBloc>(
      () => blocModule.errorAnalysisChartBloc(
        gh<_i618.GetErrorAnalysisChartData>(),
      ),
    );
    gh.factory<_i820.TrackingSessionBloc>(
      () => blocModule.trackingSession(
        gh<_i949.GetOrCreateTodayTrackingDetails>(),
        gh<_i500.GetAllMistakes>(),
        gh<_i268.GenerateFollowUpReportUseCase>(),
        gh<_i587.SaveTaskProgress>(),
        gh<_i692.SaveDraftMistakesUseCase>(),
      ),
    );
    gh.factory<_i42.ExportFollowUpReportsUseCase>(
      () => _i42.ExportFollowUpReportsUseCase(gh<_i634.StudentRepository>()),
    );
    gh.factory<_i204.ImportFollowUpReportsUseCase>(
      () => _i204.ImportFollowUpReportsUseCase(gh<_i634.StudentRepository>()),
    );
    gh.lazySingleton<_i1001.GetFaqsUseCase>(
      () => _i1001.GetFaqsUseCase(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i830.GetTermsOfUseUseCase>(
      () => _i830.GetTermsOfUseUseCase(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i402.SubmitSupportTicketUseCase>(
      () => _i402.SubmitSupportTicketUseCase(gh<_i844.SettingsRepository>()),
    );
    gh.lazySingleton<_i564.DeleteStudentUseCase>(
      () => _i564.DeleteStudentUseCase(gh<_i634.StudentRepository>()),
    );
    gh.lazySingleton<_i314.GetPlanForTheDay>(
      () => _i314.GetPlanForTheDay(gh<_i634.StudentRepository>()),
    );
    gh.lazySingleton<_i1070.GetStudentById>(
      () => _i1070.GetStudentById(gh<_i634.StudentRepository>()),
    );
    gh.lazySingleton<_i60.SaveStudentPlan>(
      () => _i60.SaveStudentPlan(gh<_i634.StudentRepository>()),
    );
    gh.lazySingleton<_i43.UpsertStudent>(
      () => _i43.UpsertStudent(gh<_i634.StudentRepository>()),
    );
    gh.factory<_i516.StudentBloc>(
      () => blocModule.studentBloc(
        gh<_i43.UpsertStudent>(),
        gh<_i564.DeleteStudentUseCase>(),
        gh<_i1070.GetStudentById>(),
        gh<_i314.GetPlanForTheDay>(),
        gh<_i60.SaveStudentPlan>(),
      ),
    );
    gh.lazySingleton<_i1032.CheckUsernameUseCase>(
      () => _i1032.CheckUsernameUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i822.SuggestUsernameUseCase>(
      () => _i822.SuggestUsernameUseCase(gh<_i424.AuthRepository>()),
    );
    gh.lazySingleton<_i577.GetSchoolsUseCase>(
      () => _i577.GetSchoolsUseCase(gh<_i424.AuthRepository>()),
    );
    gh.factory<_i790.SettingsBloc>(
      () => blocModule.settingsBloc(
        gh<_i24.GetSettings>(),
        gh<_i1062.SaveTheme>(),
        gh<_i256.SetNotificationsPreference>(),
        gh<_i892.SetAnalyticsPreference>(),
        gh<_i117.GetUserProfile>(),
        gh<_i957.UpdateUserProfile>(),
        gh<_i356.GetLatestPolicyUseCase>(),
        gh<_i204.ImportFollowUpReportsUseCase>(),
        gh<_i42.ExportFollowUpReportsUseCase>(),
        gh<_i1001.GetFaqsUseCase>(),
        gh<_i402.SubmitSupportTicketUseCase>(),
        gh<_i830.GetTermsOfUseUseCase>(),
      ),
    );
    gh.factory<_i708.AuthBloc>(
      () => blocModule.authBloc(
        gh<_i250.LogInUseCase>(),
        gh<_i186.CheckLogInUseCase>(),
        gh<_i871.LogOutUseCase>(),
        gh<_i426.ForgetPasswordUseCase>(),
        gh<_i960.ChangePasswordUseCase>(),
        gh<_i1045.GetAllUsersUseCase>(),
        gh<_i741.SwitchUserUseCase>(),
        gh<_i268.RegisterStudentUseCase>(),
        gh<_i334.ResendVerificationEmailUseCase>(),
        gh<_i822.SuggestUsernameUseCase>(),
        gh<_i1032.CheckUsernameUseCase>(),
        gh<_i577.GetSchoolsUseCase>(),
      ),
    );
    return this;
  }
}

class _$BlocModule extends _i31.BlocModule {}

class _$RegisterModule extends _i644.RegisterModule {}
