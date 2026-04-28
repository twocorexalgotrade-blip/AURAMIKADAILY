import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Address {
  final String label; // 'Home', 'Work', 'Other'
  final String line1;
  final String city;
  final String pinCode;

  const Address({
    required this.label,
    required this.line1,
    required this.city,
    this.pinCode = '',
  });

  Address copyWith({
    String? label,
    String? line1,
    String? city,
    String? pinCode,
  }) =>
      Address(
        label: label ?? this.label,
        line1: line1 ?? this.line1,
        city: city ?? this.city,
        pinCode: pinCode ?? this.pinCode,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'line1': line1,
        'city': city,
        'pinCode': pinCode,
      };

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        label: j['label'] as String,
        line1: j['line1'] as String,
        city: j['city'] as String,
        pinCode: (j['pinCode'] as String?) ?? '',
      );
}

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final String imagePath;
  final List<Address> addresses;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.dob = '',
    this.imagePath = '',
    this.addresses = const [],
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
    String? imagePath,
    List<Address>? addresses,
  }) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dob: dob ?? this.dob,
        imagePath: imagePath ?? this.imagePath,
        addresses: addresses ?? this.addresses,
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
      addresses: _readAddresses(box),
    );
  }

  List<Address> _readAddresses(Box box) {
    final raw = box.get('addresses', defaultValue: '') as String;
    if (raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Address.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  void _persistAddresses(List<Address> addresses) {
    Hive.box(_boxName).put(
      'addresses',
      jsonEncode(addresses.map((a) => a.toJson()).toList()),
    );
  }

  // Re-reads Hive into state AND always sets phone from the auth session.
  void loadFromAuth(String phone) {
    final box = Hive.box(_boxName);
    state = UserProfile(
      name: box.get('name', defaultValue: '') as String,
      email: box.get('email', defaultValue: '') as String,
      phone: phone,
      dob: box.get('dob', defaultValue: '') as String,
      imagePath: box.get('imagePath', defaultValue: '') as String,
      addresses: _readAddresses(box),
    );
    box.put('phone', phone);
  }

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

  void addAddress(Address address) {
    final updated = [...state.addresses, address];
    state = state.copyWith(addresses: updated);
    _persistAddresses(updated);
  }

  void updateAddress(int index, Address address) {
    final updated = [...state.addresses]..[index] = address;
    state = state.copyWith(addresses: updated);
    _persistAddresses(updated);
  }

  void removeAddress(int index) {
    final updated = [...state.addresses]..removeAt(index);
    state = state.copyWith(addresses: updated);
    _persistAddresses(updated);
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
