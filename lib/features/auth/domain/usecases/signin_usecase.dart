import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  dynamic execute(String email, String password) {
    try {
      return repository.signIn(email, password);
    } catch (e) {
      rethrow;
    }
  }
}
