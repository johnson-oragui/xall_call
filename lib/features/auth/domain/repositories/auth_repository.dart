import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn(String email, String password);
  Future<UserEntity> signUp(
    String email,
    String username,
    String password,
    String confirmPassword,
  );
  Future<void> signOut();
  bool isAuthenticated();
  UserEntity? getCurrentUser();
}
