import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String imagePath;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.imagePath = '',
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? imagePath,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dob: dob ?? this.dob,
        imagePath: imagePath ?? this.imagePath,
      );
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  static const _boxName = 'profile';

  UserProfileNotifier() : super(const UserProfile()) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    state = UserProfile(
      name: box.get('name', defaultValue: '') as String,
      email: box.get('email', defaultValue: '') as String,
      phone: box.get('phone', defaultValue: '') as String,
      dob: box.get('dob', defaultValue: '') as String,
      imagePath: box.get('imagePath', defaultValue: '') as String,
    );
  }

  // Re-reads Hive into state — call after sign-in so the profile populates.
  void reload() => _load();

  void update({
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? imagePath,
  }) {
    state = state.copyWith(
      name: name,
      email: email,
      phone: phone,
      dob: dob,
      imagePath: imagePath,
    );
    final box = Hive.box(_boxName);
    if (name != null) box.put('name', name);
    if (email != null) box.put('email', email);
    if (phone != null) box.put('phone', phone);
    if (dob != null) box.put('dob', dob);
    if (imagePath != null) box.put('imagePath', imagePath);
  }

  // Clears in-memory state only — Hive is kept so the profile reloads on
  // the next sign-in without a backend round-trip.
  void clearState() {
    state = const UserProfile();
  }

  // Full wipe — used on account deletion only.
  void reset() {
    state = const UserProfile();
    Hive.box(_boxName).clear();
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>(
  (ref) => UserProfileNotifier(),
);
