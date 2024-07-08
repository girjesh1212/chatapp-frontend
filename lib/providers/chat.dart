import 'package:flutter/material.dart';
import '../api/chat.dart';
import '../models/chat.dart';
// ignore: library_prefixes

class ChatProvider extends ChangeNotifier{
  
  final int pageLimit = 50;
  final _chatAPI = ChatApi();

  int lastId = 0;
  bool lastPageFetched = false;
  bool fetchingChats = false;
  List<ChatModel> _chats = [];

  List<ChatModel> get chats => _chats;

  Future<void> fetchChats() async {
    if(fetchingChats == true || lastPageFetched == true){
      return;
    }
    fetchingChats = true;
    notifyListeners();
    final newChats = await _chatAPI.getChats(lastId, pageLimit);
    if(newChats.length < pageLimit){
      lastPageFetched = true; 
    }
    if(newChats.isNotEmpty){
      lastId = newChats.last.id;
      print('lastId is $lastId');
    }
    _chats = [...newChats.reversed, ..._chats];
    fetchingChats = false;
    notifyListeners();
  }

  void addChatToChatsList(ChatModel chat){
    _chats.add(chat);
    notifyListeners();
  }

  void clearChats(){
    _chats.clear();
    lastId = 0;
    notifyListeners();
  }

}