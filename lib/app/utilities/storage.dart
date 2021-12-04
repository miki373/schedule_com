import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SCStorage {
  static const _store = FlutterSecureStorage();

  Future<LoginDetails> getLogin() async {
    String? userId = await _store.read(key: 'userId') ?? '';
    String? pin = await _store.read(key: 'pin') ?? '';
    return LoginDetails(isLoggedIn: userId != '' && userId.isNotEmpty, userId: userId, pin: pin);
  }

  Future<void> setLogin({required String userId, required String pin}) async {
    await _store.write(key: 'userId', value: userId);
    await _store.write(key: 'pin', value: pin);
  }

  Future<void> clearAll() async {
    await _store.deleteAll();
  }
}

class LoginDetails {
  final String userId;
  final String pin;
  final bool isLoggedIn;

  const LoginDetails({required this.userId,required this.pin,required this.isLoggedIn});
}