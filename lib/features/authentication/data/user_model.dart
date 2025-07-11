import 'package:firebase_auth/firebase_auth.dart' as firebase;

class UserModel {
  final String name;
  final String email;
  final String uid;

  UserModel({required this.name, required this.email, required this.uid});

  factory UserModel.fromFirebaseUser(firebase.User user, {String? name}) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: name ?? user.displayName ?? '',
    );
  }
}
