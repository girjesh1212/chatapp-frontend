import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/auth.dart';
import '../api/base_api.dart';


class AuthProvider extends ChangeNotifier {

  BaseAPI baseApi = BaseAPI();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _username;

  String get username => _username ?? "?"; 

  Future<bool> isLoggedInOnStartup() async {
    String? token = await _storage.read(key: 'accessToken');
    _username = await _storage.read(key: 'username');
    return token != null;
  }
  
  // Logout method
  void logout() async {
    _username = null;
    await _storage.deleteAll();
  }

  Future<Map<String, dynamic>> register({required String username, required String email, required String password }) async {
    try{
      Map<String, dynamic> loginRes = await AuthAPI().register(email: email, username: username, password: password);
      if(loginRes['success'] == false){
        logout();
      }
      return loginRes;
    }catch(e){
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({required String identifier, required String password }) async {
    try{
      Map<String, dynamic>? loginRes = await AuthAPI().login(identifier: identifier, password: password);
      if(loginRes['success'] == false){
        logout();
      }
      return loginRes;
    }catch(e){
      rethrow;
    }
  }

}