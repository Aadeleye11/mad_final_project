import '../models/user.dart';

/// Mock auth repository. Swap the bodies for real API calls
/// (e.g. via an AuthProvider in data/providers/) once a backend exists.
class AuthRepository {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mock rule: any syntactically valid credentials succeed.
    if (password.length < 6) {
      throw AuthException('Invalid email or password.');
    }

    _currentUser = User(
      id: 'u_1',
      name: email.split('@').first,
      email: email,
    );
    return _currentUser!;
  }

  Future<User> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    // Mock rule: pretend this email is already registered.
    if (email.toLowerCase() == 'taken@example.com') {
      throw AuthException('An account with this email already exists.');
    }

    _currentUser = User(id: 'u_1', name: name, email: email);
    return _currentUser!;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
