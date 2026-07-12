// features/auth/data/datasources/auth_remote_data_source.dart

import 'package:shafeea/features/auth/data/models/user_model.dart';

import '../../../../core/models/success_model.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';

/// Defines remote data operations for authentication.
///
/// All methods throw [ServerException] carrying an [ErrorModel]
/// if the API responds with an error payload.
abstract class AuthRemoteDataSource {
  /// Sends credentials to the `/logIn` endpoint.
  Future<AuthResponseModel> logIn({required LogInRequestModel requestModel});

  /// Requests a password reset code.
  Future<SuccessModel> forgetPassword({required String login});

  /// Checks whether a username is available.
  Future<bool> checkUsernameAvailability({required String username});

  /// Fetches a username suggestion derived from [name] via the public
  /// `/username/suggest` web endpoint. The result is NOT uniqueness-checked.
  Future<String> suggestUsername({required String name});
  Future<SuccessModel> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Requests a password reset code.
  Future<SuccessModel> logOut();

  Future<AuthResponseModel> registerStudent({
    required RegisterRequestModel requestModel,
  });

  /// Resends the email verification link to the authenticated user.
  Future<SuccessModel> resendEmailVerification();

  /// Fetches the authenticated user's latest profile.
  Future<UserModel> getProfile();
}
