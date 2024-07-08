class ChatModel {
  final int id;
  final String text;
  final bool isUser;

  ChatModel({required this.id, required this.text, required this.isUser});

  @override
  String toString(){
    return '$id $text $isUser';
  }
}
