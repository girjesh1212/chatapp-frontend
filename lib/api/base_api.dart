import '../models/apirequest.dart';
import '../models/apiresponse.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/config.dart';

class RequestTypes {
  static const get = 'GET';
  static const post = 'POST';
}
class BaseAPI {
  final String baseUrl = Config.strapiBaseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Returns either a response or a null
  Future makeApiCall({required ApiRequestModel request, bool jwtAuthRequired = false}) async {
    String? accessToken = await _storage.read(key: 'accessToken');

    if(jwtAuthRequired == true && accessToken == null){
      return;
    }
    switch(request.type){
      case 'GET': {
        ApiResponseModel res = await _getRequest(request, accessToken);
        if(res.statusCode == 401){
          accessToken = await getNewAccessToken();
          if(accessToken != null) {
            res = await _getRequest(request, accessToken);
          }
        }
        return res;
      }

      case 'POST': {
        ApiResponseModel res = await _postRequest(request, accessToken);
        
        if(res.statusCode == 401){
          accessToken = await getNewAccessToken();
          if(accessToken != null) {
            res = await _postRequest(request, accessToken);
          }
        }
        return res;
      }
      
      default:
        return null;
    }
    
  }

  Future<ApiResponseModel> _getRequest(ApiRequestModel request, String? token) async {
    http.Response response = await http.get(
      Uri.parse('$baseUrl${request.url}'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        'Authorization': '$token',
      },
    );
    return ApiResponseModel(res: response);
  }

  Future<ApiResponseModel> _postRequest(ApiRequestModel request, String? token) async {
    http.Response response = await http.post(
      Uri.parse('$baseUrl${request.url}'),
      headers: <String, String>{
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        'Authorization': '$token',
      },
      body: request.body
    );
    
    return ApiResponseModel(res: response);
  }


  Future getNewAccessToken() async {
    try{
      String? identifier = await _storage.read(key: 'identifier');
      String? password = await _storage.read(key: 'pass');
      
      if(identifier == null || password == null){
        return null;
      }
      ApiRequestModel request = ApiRequestModel(type: 'POST', url: '/auth/local', body: {'identifier': identifier, 'password': password});
      ApiResponseModel response = await makeApiCall(request:request);

      if(response.statusCode != 200){
        return null;
      }
      
      final jwt = response.body['jwt'];
      if(jwt == null){
        return null;
      }
      await _storage.write(key: 'accessToken', value: 'bearer $jwt');
      return jwt;
    }catch(e){
      return null;
    }
    
  }

}