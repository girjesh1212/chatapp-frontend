
import 'dart:convert';

class ApiRequestModel {
  final String type, url;
  String? body;
  Map<String, dynamic>? params;
  Map<String, dynamic>? query;

  ApiRequestModel({required this.type, required this.url, Map<String, dynamic>? body, this.params, this.query}){
    if(body != null){
      this.body = jsonEncode(body);
    }
  }

}
