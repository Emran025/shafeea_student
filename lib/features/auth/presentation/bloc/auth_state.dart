part of 'auth_bloc.dart';

/// -----------------------------------------------------------------
/// Enums Definitions
/// -----------------------------------------------------------------

enum AuthStatus { initializing, authenticated, unauthenticated }

enum LogInStatus { initial, loading, success, failure }

enum GetUserStatus { initial, loading, success, failure }

enum ForgetPasswordStatus { initial, submitting, success, failure }

enum ChangePasswordStatus { initial, submitting, success, failure }

/// -----------------------------------------------------------------
/// AuthState Class
/// -----------------------------------------------------------------

final class AuthState extends Equatable {
  // --- General Auth State ---
  final AuthStatus authStatus;
  final UserEntity? user; // Current logged-in user
  final Failure? failure; // General failures

  // --- Login State ---
  final LogInStatus status;

  // --- Get Specific User / Current User Details ---
  final GetUserStatus getUserStatus;
  final UserEntity? selectedUser;
  final Failure? getUserFailure;

  // --- Switch Account / Get All Users State ---
  final List<UserEntity> usersList;
  final GetUserStatus usersListStatus;
  final Failure? usersListFailure;

  // --- Password Operations (Forget & Change) ---
  final ForgetPasswordStatus forgetPasswordStatus;
  final Failure? forgetPasswordFailure;

  final ChangePasswordStatus changePasswordStatus;
  final Failure? changePasswordFailure;


  // --- Shared Success Entity ---
  final SuccessEntity? successEntity;

  // --- Logout State ---
  final Failure? logOutFailure;

  const AuthState({
    // General
    this.authStatus = AuthStatus.initializing,
    this.user,
    this.failure,

    // Login
    this.status = LogInStatus.initial,

    // Get User
    this.getUserStatus = GetUserStatus.initial,
    this.selectedUser,
    this.getUserFailure,

    // Users List (Switch Account)
    this.usersList = const [],
    this.usersListStatus = GetUserStatus.initial,
    this.usersListFailure,

    // Forget Password
    this.forgetPasswordStatus = ForgetPasswordStatus.initial,
    this.forgetPasswordFailure,

    // Change Password
    this.changePasswordStatus = ChangePasswordStatus.initial,
    this.changePasswordFailure,

    // Shared Success
    this.successEntity,

    // Logout
    this.logOutFailure,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    UserEntity? user,
    Failure? failure,
    LogInStatus? status,
    GetUserStatus? getUserStatus,
    UserEntity? selectedUser,
    Failure? getUserFailure,
    List<UserEntity>? usersList,
    GetUserStatus? usersListStatus,
    Failure? usersListFailure,
    ForgetPasswordStatus? forgetPasswordStatus,
    Failure? forgetPasswordFailure,
    ChangePasswordStatus? changePasswordStatus,
    Failure? changePasswordFailure,
    // New Params
    Failure? registrationFailure,
    
    SuccessEntity? successEntity,
    Failure? logOutFailure,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      user: user ?? this.user,
      failure: failure ?? this.failure,
      status: status ?? this.status,
      getUserStatus: getUserStatus ?? this.getUserStatus,
      selectedUser: selectedUser ?? this.selectedUser,
      getUserFailure: getUserFailure ?? this.getUserFailure,
      usersList: usersList ?? this.usersList,
      usersListStatus: usersListStatus ?? this.usersListStatus,
      usersListFailure: usersListFailure ?? this.usersListFailure,
      forgetPasswordStatus: forgetPasswordStatus ?? this.forgetPasswordStatus,
      forgetPasswordFailure: forgetPasswordFailure ?? this.forgetPasswordFailure,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      changePasswordFailure: changePasswordFailure ?? this.changePasswordFailure,

      successEntity: successEntity ?? this.successEntity,
      logOutFailure: logOutFailure ?? this.logOutFailure,
    );
  }

  @override
  List<Object?> get props => [
        authStatus,
        user,
        failure,
        status,
        getUserStatus,
        selectedUser,
        getUserFailure,
        usersList,
        usersListStatus,
        usersListFailure,
        forgetPasswordStatus,
        forgetPasswordFailure,
        changePasswordStatus,
        changePasswordFailure,
        
        successEntity,
        logOutFailure,
      ];
}