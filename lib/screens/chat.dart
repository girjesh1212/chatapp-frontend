import 'dart:convert';
import 'package:chatapp/models/chat.dart';
import 'package:chatapp/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../services/socket.dart';
import '../providers/chat.dart';
import './widgets.dart';

class ChatScreen extends StatefulWidget {
  final String username ;
  const ChatScreen({super.key, required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();
  final _focusNode = FocusNode();
  SocketService socketService = SocketService();

  void _goToBottomPage() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients){
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollListener(){
    final chatProvider = context.read<ChatProvider>();
    if (chatProvider.lastPageFetched == false
      && chatProvider.fetchingChats == false
      && _scrollController.position.pixels < (_scrollController.position.minScrollExtent + 50 )) {
        double oldMaxScrollExtent = _scrollController.position.maxScrollExtent;
        chatProvider.fetchChats().then((_) {
          if(_scrollController.hasClients){
            double newMaxScrollExtent = _scrollController.position.maxScrollExtent;
            double scrollOffset = newMaxScrollExtent - oldMaxScrollExtent;
            _scrollController.jumpTo(_scrollController.position.pixels + scrollOffset);
          }
        });
     }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await context.read<ChatProvider>().fetchChats();
      await socketService.connect();
      
      socketService.getClient().on('returnMessage', (data) {
        final jsonData = jsonDecode(data);
        final ChatModel rightChat = ChatModel(id: jsonData['id'], text: jsonData['msg'], isUser: true);
        final ChatModel leftChat = ChatModel(id: jsonData['id'], text: jsonData['msg'], isUser: false);
        context.read<ChatProvider>().addChatToChatsList(rightChat);
        _goToBottomPage();
        _textEditingController.clear();
        Future.delayed(const Duration(milliseconds: 500), () {
          context.read<ChatProvider>().addChatToChatsList(leftChat);
          _goToBottomPage();
        });
      });

      _scrollController.addListener(_scrollListener);
      _goToBottomPage();

    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 2,
        title: Text('Chat between Server and ${widget.username}', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              context.read<ChatProvider>().clearChats();
              Navigator.pushReplacement( context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }, 
          )
        ]
      ),
      body: Column(
        children: [
          // Chat list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, value, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  physics: const BouncingScrollPhysics(),
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: value.chats.length,
                  itemBuilder: (context, index) {
                    ChatModel chat = value.chats[index];
                    return Chat(chat: chat);
                  }
                );
              }
            )
          ),
      
          // Typing box
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(
                width: 1,
                color: Colors.grey.shade300.withOpacity(0.5),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    scrollPadding: EdgeInsets.zero,
                    autofocus: true,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      border: InputBorder.none,
                      isDense: true,
                      isCollapsed: true,
                      hintText: 'Type something',
                      hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          socketService.sendMessageToServer(message: _textEditingController.text.trim());
                          _focusNode.requestFocus();
                        },
                      )
                    ),
                    onSubmitted: (value) {
                      socketService.sendMessageToServer(message: _textEditingController.text.trim());
                      _focusNode.requestFocus();
                    },
                    onTapOutside: (event){
                      FocusManager.instance.primaryFocus?.unfocus();
                    }
                  )
                )
              ],
            ),
          )
        ]
      ),
    );
  }
}
