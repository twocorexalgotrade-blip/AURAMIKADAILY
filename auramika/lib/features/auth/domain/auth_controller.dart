import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
    // Restore persisted session synchronously so the UI never flickers on cold start.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      debugPrint('[Auth] init → restoring session uid=${currentUser.uid}');
      state = AuthState(isLoggedIn: true, userId: currentUser.uid);
    }

    // Only handle sign-outs from the stream. Sign-ins are handled explicitly
    // via login() so that the OTP create-account flow (which calls
    // signInWithCredential then may immediately sign out for existing numbers)
    // does not cause a premature isLoggedIn=true flash.
    _sub = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('[Auth] authStateChanges → user=${user?.uid ?? 'null'}');
      if (user == null) {
        state = const AuthState();
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void login(String userId) {
    debugPrint('[Auth] login → userId=$userId');
    state = AuthState(isLoggedIn: true, userId: userId);
  }

  Future<void> logout() async {
    debugPrint('[Auth] logout → signing out userId=${state.userId}');
    await FirebaseAuth.instance.signOut();
    state = const AuthState();
    debugPrint('[Auth] logout → complete');
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
