import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketService {
  static final SocketService _instance = SocketService._();
  factory SocketService() => _instance;

  SocketService._();

  late WebSocketChannel _channel;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get stream => _controller.stream;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));

    _channel.stream.listen((data) {
      //printD(data.toString());
      _controller.add(jsonDecode(data));
    });
  }

  void send(Map<String, dynamic> data) {
    _channel.sink.add(jsonEncode(data));
  }

  void dispose() {
    _channel.sink.close();
    _controller.close();
  }
}
