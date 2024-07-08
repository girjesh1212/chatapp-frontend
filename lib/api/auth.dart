import './base_api.dart';
import '../models/apirequest.dart';
import '../models/apiresponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthAPI {

  BaseAPI baseApi = BaseAPI();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register({required String email, required String username, required String password}) async {
    try{
      ApiRequestModel request = ApiRequestModel(type: 'POST', url: '/auth/local/register', body: {'email': email, 'username': username, 'password': password});
      ApiResponseModel response = await baseApi.makeApiCall(request:request);
      if(response.statusCode == 200){
        final jwt = response.body['jwt'];
        final user = response.body['user'];
        await _storage.write(key: 'accessToken', value: 'bearer $jwt');
        await _storage.write(key: 'identifier', value: user['email']);
        await _storage.write(key: 'username', value: user['username']);
        await _storage.write(key: 'password', value: password);
        return {
          'success': true,
          'username': user['username']
        };
      }

      final error = response.body['error'];
      return { 
        'success': false, 
        'message': error['message']
      };
      
    }catch(e){
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login({required String identifier, required String password}) async {
    try{
      ApiRequestModel request = ApiRequestModel(type: 'POST', url: '/auth/local', body: {'identifier': identifier, 'password': password});
      ApiResponseModel response = await baseApi.makeApiCall(request:request);
      
      if(response.statusCode == 200){
        final jwt = response.body['jwt'];
        final user = response.body['user'];
        await _storage.write(key: 'accessToken', value: 'bearer $jwt');
        await _storage.write(key: 'identifier', value: user['email']);
        await _storage.write(key: 'username', value: user['username']);
        await _storage.write(key: 'password', value: password);
        return {
          'success': true,
          'username': user['username']
        };
      }

      final error = response.body['error'];
      return { 
        'success': false, 
        'message': error['message']
      };
    }catch(e){
      rethrow;
    }
  }

}


/**
 
{
    "data": null,
    "error": {
        "status": 400,
        "name": "ApplicationError",
        "message": "Email or Username are already taken",
        "details": {}
    }
}

{
    "jwt": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiaWF0IjoxNzIwMzU2Mzc2LCJleHAiOjE3MjI5NDgzNzZ9.VS1ry0oLIvyU_rYOpS0KeIRJ4TuFTA6sENgpFcUVazw",
    "user": {
        "id": 3,
        "username": "girjesha",
        "email": "girjesha@gmail.com",
        "provider": "local",
        "confirmed": true,
        "blocked": false,
        "createdAt": "2024-07-07T12:46:16.387Z",
        "updatedAt": "2024-07-07T12:46:16.387Z"
    }
}

 */