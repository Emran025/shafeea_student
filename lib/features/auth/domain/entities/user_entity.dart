
class UserEntity {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final bool isEmailVerified;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    this.isEmailVerified = false,
  });
}
