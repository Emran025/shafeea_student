part of 'auth_bloc.dart';

/// -----------------------------------------------------------------
/// Enums Definitions
/// -----------------------------------------------------------------

enum AuthStatus { initializing, authenticated, unauthenticated }

enum LogInStatus { initial, loading, success, failure }

enum GetUserStatus { initial, loading, success, failure }

enum ForgetPasswordStatus { initial, submitting, success, failure }

enum ChangePasswordStatus { initial, submitting, success, failure }

enum VerificationStatus { initial, loading, success, failure }

enum UsernameSuggestionStatus { initial, loading, loaded, failure }

enum UsernameCheckStatus { initial, loading, loaded, failure }

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

  // --- Verification State ---
  final VerificationStatus verificationStatus;
  final Failure? verificationFailure;

  // --- Username Suggestion State ---
  final UsernameSuggestionStatus usernameSuggestionStatus;
  final String usernameSuggestion;

  // --- Username Check State ---
  final UsernameCheckStatus usernameCheckStatus;
  final bool usernameCheck;
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

    // Verification
    this.verificationStatus = VerificationStatus.initial,
    this.verificationFailure,

    // Username Suggestion
    this.usernameSuggestionStatus = UsernameSuggestionStatus.initial,
    this.usernameSuggestion = '',

    // Username Check
    this.usernameCheckStatus = UsernameCheckStatus.initial,
    this.usernameCheck = false,
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
    VerificationStatus? verificationStatus,
    Failure? verificationFailure,

    // Username Suggestion
    UsernameSuggestionStatus? usernameSuggestionStatus,
    String? usernameSuggestion,

    // Username Check
    UsernameCheckStatus? usernameCheckStatus,
    bool? usernameCheck,
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
      forgetPasswordFailure:
          forgetPasswordFailure ?? this.forgetPasswordFailure,
      changePasswordStatus: changePasswordStatus ?? this.changePasswordStatus,
      changePasswordFailure:
          changePasswordFailure ?? this.changePasswordFailure,

      successEntity: successEntity ?? this.successEntity,
      logOutFailure: logOutFailure ?? this.logOutFailure,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationFailure: verificationFailure ?? this.verificationFailure,

      // Username Suggestion
      usernameSuggestionStatus:
          usernameSuggestionStatus ?? this.usernameSuggestionStatus,
      usernameSuggestion: usernameSuggestion ?? this.usernameSuggestion,

      // Username Check
      usernameCheckStatus:
          usernameCheckStatus ?? this.usernameCheckStatus,
      usernameCheck: usernameCheck ?? this.usernameCheck,
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
    verificationStatus,
    verificationFailure,

    usernameSuggestionStatus,
    usernameSuggestion,

    usernameCheckStatus,
    usernameCheck,
  ];
}
