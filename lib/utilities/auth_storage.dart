import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rimes_interview_projects/utilities/validators.dart';

class AuthStorage {

  
  static const _storage = FlutterSecureStorage();

  static const _userregisterKey ="userregistered";
  static const _uidKey = 'uid';
  static const _jwtKey = 'jwt_token';

  /// ✅ Save JWT & UID
  static Future<void> saveAuthData(String uid, String token) async {
    await _storage.write(key: "uid", value: uid);
    await _storage.write(key: "jwt_token", value: token);
  }

  static Future<void> setuserExist() async {
    await _storage.write(key: _userregisterKey, value: "true");
  
  }

  static Future<bool> userExist() async {
    final value =await _storage.read(key: _userregisterKey);
   return value =="true";
  
  }


  /// ✅ Get JWT
  static Future<String?> getToken() async {
    return await _storage.read(key: "jwt_token");
  }

  /// ✅ Get UID
  static Future<String?> getUid() async {
    return await _storage.read(key: _uidKey);
  }

  /// ✅ Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// ✅ Clear all auth data (Logout)
  static Future<void> logout() async {
    await _storage.delete(key: "uid");
    await _storage.delete(key: "jwt_token");
  }

  static Future<void> saveUid(String uid) async =>
      await _storage.write(key: _uidKey, value: uid);

 


}
