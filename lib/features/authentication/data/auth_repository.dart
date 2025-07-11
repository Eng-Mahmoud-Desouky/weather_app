import 'auth_service.dart';
import 'user_model.dart';

abstract class AuthRepository {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;

  AuthRepositoryImpl(this._authRemoteDataSource);

  @override
  Future<UserModel> signIn(String email, String password) async {
    return await _authRemoteDataSource.signIn(email, password);
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    return await _authRemoteDataSource.signUp(email, password, name);
  }

  @override
  Future<void> signOut() async {
    await _authRemoteDataSource.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return await _authRemoteDataSource.getCurrentUser();
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _authRemoteDataSource.authStateChanges;
  }
}
