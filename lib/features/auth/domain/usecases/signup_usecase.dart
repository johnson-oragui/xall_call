import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  dynamic execute(
    String email,
    String username,
    String password,
    String confirmPassword,
  ) {
    return repository.signUp(email, username, password, confirmPassword);
  }
}
