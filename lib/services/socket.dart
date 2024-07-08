import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/config.dart';

class SocketService {
  late IO.Socket socket;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> connect() async {
    String accessToken = await _storage.read(key: 'accessToken') ?? "";
    socket = IO.io(Config.socketBaseUrl, IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect()  // disable auto-connection
        .setQuery({'token': accessToken})
        .build());

    // Connect to the socket
    socket.connect();

    // Handle connection events
    socket.onConnect((_) {
      debugPrint('socket connected');
    });

    socket.onDisconnect((_) {
      debugPrint('disconnected');
    });
  }

  IO.Socket getClient(){
    return socket;
  }

  void sendMessageToServer({String event = 'message', required String message}){
    socket.emit(event, message);
  }
  

  void disconnect() {
    socket.disconnect();
  }
}
