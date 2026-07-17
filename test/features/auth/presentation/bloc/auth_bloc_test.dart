// test/features/auth/presentation/bloc/auth_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late AuthBloc authBloc;
  late MockLogInUseCase mockLogInUseCase;
  late MockCheckLogInUseCase mockCheckLogInUseCase;
  late MockLogOutUseCase mockLogOutUseCase;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockSwitchUserUseCase mockSwitchUserUseCase;
  late MockGetAllUsersUseCase mockGetAllUsersUseCase;
  late MockRegisterStudentUseCase mockRegisterStudentUseCase;
  late MockResendVerificationEmailUseCase mockResendVerificationEmailUseCase;
  late MockSuggestUsernameUseCase mockSuggestUsernameUseCase;
  late MockCheckUsernameUseCase mockCheckUsernameUseCase;
  late MockGetSchoolsUseCase mockGetSchoolsUseCase;

  setUp(() {
    mockLogInUseCase = MockLogInUseCase();
    mockCheckLogInUseCase = MockCheckLogInUseCase();
    mockLogOutUseCase = MockLogOutUseCase();
    mockForgetPasswordUseCase = MockForgetPasswordUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockSwitchUserUseCase = MockSwitchUserUseCase();
    mockGetAllUsersUseCase = MockGetAllUsersUseCase();
    mockRegisterStudentUseCase = MockRegisterStudentUseCase();
    mockResendVerificationEmailUseCase = MockResendVerificationEmailUseCase();
    mockSuggestUsernameUseCase = MockSuggestUsernameUseCase();
    mockCheckUsernameUseCase = MockCheckUsernameUseCase();
    mockGetSchoolsUseCase = MockGetSchoolsUseCase();

    authBloc = AuthBloc(
      mockLogInUseCase,
      mockCheckLogInUseCase,
      mockLogOutUseCase,
      mockForgetPasswordUseCase,
      mockChangePasswordUseCase,
      mockSwitchUserUseCase,
      mockGetAllUsersUseCase,
      mockRegisterStudentUseCase,
      mockResendVerificationEmailUseCase,
      mockSuggestUsernameUseCase,
      mockCheckUsernameUseCase,
      mockGetSchoolsUseCase,
    );
  });

  group('AuthBloc - LogIn', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tUser = UserEntity(id: 1, name: 'Test', email: tEmail, phone: '123');

    blocTest<AuthBloc, AuthState>(
      'should emit [status: LogInStatus.loading, status: LogInStatus.success] when login is successful',
      build: () {
        when(
          () => mockLogInUseCase.call(credentials: any(named: 'credentials')),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LogInRequested(logIn: tEmail, password: tPassword)),
      expect: () => [
        authBloc.state.copyWith(status: LogInStatus.loading),
        authBloc.state.copyWith(
          status: LogInStatus.success,
          user: tUser,
          authStatus: AuthStatus.authenticated,
        ),
      ],
      verify: (_) {
        verify(
          () => mockLogInUseCase.call(credentials: any(named: 'credentials')),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [status: LogInStatus.loading, status: LogInStatus.failure] when login fails',
      build: () {
        when(
          () => mockLogInUseCase.call(credentials: any(named: 'credentials')),
        ).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Login Failed')),
        );
        return authBloc;
      },
      act: (bloc) =>
          bloc.add(const LogInRequested(logIn: tEmail, password: tPassword)),
      expect: () => [
        authBloc.state.copyWith(status: LogInStatus.loading),
        authBloc.state.copyWith(
          status: LogInStatus.failure,
          failure: const ServerFailure(message: 'Login Failed'),
        ),
      ],
    );
  });

  group('AuthBloc - AppStarted (CheckLogIn)', () {
    const tUser = UserEntity(
      id: 1,
      name: 'Test',
      email: 'test@example.com',
      phone: '123',
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [authStatus: AuthStatus.authenticated] when user is logged in',
      build: () {
        when(
          () => mockCheckLogInUseCase.call(),
        ).thenAnswer((_) async => const Right(tUser));
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        authBloc.state.copyWith(
          user: tUser,
          authStatus: AuthStatus.authenticated,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [authStatus: AuthStatus.unauthenticated] when user is not logged in',
      build: () {
        when(() => mockCheckLogInUseCase.call()).thenAnswer(
          (_) async => const Left(CacheFailure(message: 'No login')),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AppStarted()),
      expect: () => [
        authBloc.state.copyWith(
          user: null,
          authStatus: AuthStatus.unauthenticated,
        ),
      ],
    );
  });
}
