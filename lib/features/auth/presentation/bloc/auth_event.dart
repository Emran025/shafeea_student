part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the application starts to check if a valid session exists.
class AppStarted extends AuthEvent {}

/// Triggered when the user submits the login form.
class LogInRequested extends AuthEvent {
  final String logIn;
  final String password;

  const LogInRequested({required this.logIn, required this.password});

  @override
  List<Object> get props => [logIn, password];
}

/// Triggered when the user requests a password reset link via email.
class ForgetPasswordRequested extends AuthEvent {
  final String email;

  const ForgetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Triggered when the authenticated user wants to change their password.
class ChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

/// Triggered when the user requests to retrieve all locally saved accounts.
/// Typically used when opening the "Switch Account" modal or screen.
class GetAllUsersRequested extends AuthEvent {}

/// Triggered when the user selects a specific account from the list to switch to.
class SwitchUserRequested extends AuthEvent {
  final String userId;

  const SwitchUserRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Triggered when the user explicitly requests to log out.
class LogOutRequested extends AuthEvent {
  final String message;
  final bool deleteCredentials;

  const LogOutRequested({
    required this.message,
    required this.deleteCredentials,
  });

  @override
  List<Object> get props => [message, deleteCredentials];
}


// ... existing events ...

/// Triggered when the user submits the student registration form.
class SubmitStudentRegistration extends AuthEvent {
  final StudentApplicantEntity studentApplicant;

  const SubmitStudentRegistration({required this.studentApplicant});

  @override
  List<Object> get props => [studentApplicant];
}