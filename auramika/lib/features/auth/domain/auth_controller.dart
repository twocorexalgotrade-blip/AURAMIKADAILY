import 'dart:async';
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
  StreamSubscription<User?>? _sub;

  AuthNotifier() : super(const AuthState()) {
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      state = user != null
          ? AuthState(isLoggedIn: true, userId: user.uid)
          : const AuthState();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void login(String userId) {
    state = AuthState(isLoggedIn: true, userId: userId);
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
