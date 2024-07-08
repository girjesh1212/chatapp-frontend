import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponseModel {
  int statusCode = 401;
  Map<String, dynamic> body = {};
  String message = 'Unauthorized';
  String error = '';

  ApiResponseModel({required http.Response res}){
    statusCode = res.statusCode;
    try{
      body = jsonDecode(res.body);
      if(statusCode < 300){
        message = 'Success';
      }
      if(statusCode >= 300 && body['data'] == null){
        message = body['error']['message'];
      }
    }catch(e) {
      body = {};
      error = res.body;
      if(statusCode == 401){
        message = 'You are logged out';
      }
      else if(statusCode == 504){
        message = 'Server timeout';
      }
      else if(statusCode != 401){
        message = 'Client side error';
      }
    }
  }

}
