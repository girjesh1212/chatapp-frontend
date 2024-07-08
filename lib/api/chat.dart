import '../models/chat.dart';
import './base_api.dart';
import '../models/apirequest.dart';
import '../models/apiresponse.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChatApi {

  BaseAPI baseApi = BaseAPI();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<ChatModel>> getChats(int lastId, pageLimit) async {
    try{
      List<ChatModel> chats = [];
      String username = await _storage.read(key: 'username') ?? "";
      var url = '/chats?sort=id:desc&pagination[pageSize]=$pageLimit&filters[username][\$eq]=$username';
      if(lastId > 0){
        url = '$url&filters[id][\$lt]=$lastId';
      }
      ApiRequestModel request = ApiRequestModel(type: 'GET', url: url);
      ApiResponseModel response = await baseApi.makeApiCall(request:request);

      if (response.statusCode == 200) {
        final arr = response.body['data'];
        // Add cards in list
        arr.forEach((item) {
            ChatModel chatRight = ChatModel(
              id: item['id'],
              text: item['attributes']['msg'],
              isUser: true,
            );
            ChatModel chatLeft = ChatModel(
              id: item['id'],
              text: item['attributes']['msg'],
              isUser: false,
            );
            chats.add(chatLeft);
            chats.add(chatRight);
        });
      }
      return chats;
    }catch(e){
      return [];
    }
  
  }

}
