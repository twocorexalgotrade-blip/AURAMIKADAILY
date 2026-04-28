import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userId;

  const AuthState({this.isLoggedIn = false, this.userId});

  AuthState copyWith({bool? isLoggedIn, String? userId}) => AuthState(
        isLoggedIn: isLoggedIn ?? this.isLoggedIn,
        userId: userId ?? this.userId,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      state = AuthState(isLoggedIn: true, userId: user.uid);
    }
  }

  void login(String userId) {
    state = AuthState(isLoggedIn: true, userId: userId);
  }

  void logout() {
    FirebaseAuth.instance.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
