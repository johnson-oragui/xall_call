import 'package:flutter/rendering.dart';

enum WebSocketStatus { connecting, connected, disconnected, error }

class WebSocketMessage {
  final String type;
  final Map<String, dynamic> data;
  final DateTime? timestamp;

  WebSocketMessage({required this.type, required this.data, this.timestamp});

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    if (json['type'] == null) {
      throw ArgumentError('Message type is required');
    }
    if (json['type'] == 'error') {
      debugPrint('error data from server: $json');
    }
    return WebSocketMessage(
      type: json['type'],
      data: json['data'] ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
