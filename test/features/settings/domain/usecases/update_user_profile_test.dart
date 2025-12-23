// test/features/settings/domain/usecases/update_user_profile_test.dart

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shafeea/core/error/failures.dart';
import 'package:shafeea/features/auth/domain/entities/user_entity.dart';
import 'package:shafeea/features/settings/domain/entities/user_profile_entity.dart';
import 'package:shafeea/features/settings/domain/usecases/update_user_profile.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late UpdateUserProfile useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = UpdateUserProfile(mockRepository);
  });

  const tUser = UserEntity(
    id: 1,
    name: 'Test user',
    email: 'test@email.com',
    phone: '123',
    avatar: 'avatar',
  );

  const tUserProfile = UserProfileEntity(user: tUser, activeSessions: []);

  test('should update user profile via repository', () async {
    // Arrange
    when(
      () => mockRepository.updateUserProfile(any()),
    ).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase(
      const UpdateUserProfileParams(userProfile: tUserProfile),
    );

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.updateUserProfile(tUserProfile)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Failure when profile update fails', () async {
    // Arrange
    when(
      () => mockRepository.updateUserProfile(any()),
    ).thenAnswer((_) async => const Left(ServerFailure(message: 'error')));

    // Act
    final result = await useCase(
      const UpdateUserProfileParams(userProfile: tUserProfile),
    );

    // Assert
    expect(result, const Left(ServerFailure(message: 'error')));
    verify(() => mockRepository.updateUserProfile(tUserProfile)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
