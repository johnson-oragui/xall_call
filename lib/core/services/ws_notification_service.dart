import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/widgets.dart';
import 'package:universal_html/html.dart' as html;
import 'package:xall_call/core/config/env_config.dart';
import 'package:xall_call/core/services/ws_shared.dart';

class WebSocketNotificationService {
  static final WebSocketNotificationService _instance =
      WebSocketNotificationService._internal();
  factory WebSocketNotificationService() => _instance;
  WebSocketNotificationService._internal();

  html.WebSocket? _socket;
  final StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<WebSocketStatus> _statusController =
      StreamController<WebSocketStatus>.broadcast();

  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  String? _authToken;
  String? _userId;

  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  Stream<WebSocketStatus> get statusStream => _statusController.stream;

  Future<void> connect({required String token, required String userId}) async {
    _authToken = token;
    _userId = userId;

    if (_socket != null && _socket!.readyState == html.WebSocket.OPEN) {
      return;
    }
    try {
      _updateStatus(WebSocketStatus.connecting);

      final wsUrl = _buildWebSocketUrl(token);
      _socket = html.WebSocket(wsUrl);

      _setUpEventHandlers();
    } catch (e) {
      _handleConnectionError('COnnection failed: $e');
    }
  }

  String _buildWebSocketUrl(String token) {
    final baseUrl = EnvConfig.baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://')
        .replaceFirst('api', '');
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$cleanBaseUrl/ws/notify/?token=$token';
  }

  void _setUpEventHandlers() {
    if (_socket == null) return;

    _socket!.onOpen.listen((html.Event event) {
      _onConnected();
    });

    _socket!.onMessage.listen((html.MessageEvent event) {
      _onMessage(event.data);
    });

    _socket!.onError.listen((html.Event event) {
      _handleConnectionError('WebSocket error');
    });

    _socket!.onClose.listen((html.CloseEvent event) {
      _onDisconnected(event.code!, event.reason);
    });
  }

  void _onConnected() {
    _updateStatus(WebSocketStatus.connected);
    _isReconnecting = false;

    sendMessage('handshake', {
      'user_id': _userId,
      'device': 'web',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _onMessage(dynamic data) {
    try {
      final message = WebSocketMessage.fromJson(json.decode(data));
      _messageController.add(message);

      _handleMessageType(message);
    } catch (e) {
      debugPrint('Error parsing WebSocket message: $e');
    }
  }

  void _handleMessageType(WebSocketMessage message) {
    debugPrint('message received: $message');
    switch (message.type) {
      case 'call_incoming':
        _handleIncomingCall(message.data);
        break;
      case 'call_accepted':
        _handleCallAccepted(message.data);
        break;
      case 'call_rejected':
        _handleCallRejected(message.data);
        break;
      case 'call_ended':
        _handleCallEnded(message.data);
        break;
      case 'call_missed':
        _handleMissedCall(message.data);
        break;
      case 'presence_update':
        _handlePresenceUpdate(message.data);
        break;
    }
  }

  void _handleIncomingCall(Map<String, dynamic> data) {
    // This will trigger a notification in the UI
    debugPrint('Incoming call from: ${data['caller']}');
  }

  void _handleCallAccepted(Map<String, dynamic> data) {
    debugPrint('Call accepted by: ${data['recipient']}');
  }

  void _handleCallRejected(Map<String, dynamic> data) {
    debugPrint('Call rejected by: ${data['recipient']}');
  }

  void _handleCallEnded(Map<String, dynamic> data) {
    debugPrint('Call ended: ${data['duration']} seconds');
  }

  void _handleMissedCall(Map<String, dynamic> data) {
    debugPrint('Missed call from: ${data['caller']}');
  }

  void _handlePresenceUpdate(Map<String, dynamic> data) {
    debugPrint('User ${data['userId']} is now ${data['status']}');
  }

  void sendMessage(String type, Map<String, dynamic> data) {
    if (_socket?.readyState != html.WebSocket.OPEN) {
      debugPrint('Cannot send message: WebSocket not connected');
      return;
    }

    try {
      final message = {
        'type': type,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _socket!.send(json.encode(message));
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
    }
  }

  void sendCallResponse(String callId, String response) {
    sendMessage('call_response', {
      'call_id': callId,
      'response': response,
      'user_id': _userId,
    });
  }

  void sendHeartbeat() {
    sendMessage('heartbeat', {
      'userId': _userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void _onDisconnected(int code, String? reason) {
    _updateStatus(WebSocketStatus.disconnected);
    debugPrint('WebSocket disconnected: $code - $reason');

    if (code != 1000 && !_isReconnecting) {
      _scheduleReconnection();
    }
  }

  void _handleConnectionError(String error) {
    _updateStatus(WebSocketStatus.error);
    print('WebSocket error: $error');

    if (!_isReconnecting) {
      _scheduleReconnection();
    }
  }

  void _scheduleReconnection() {
    if (_isReconnecting) return;

    _isReconnecting = true;

    _reconnectTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_authToken != null && _userId != null) {
        connect(token: _authToken!, userId: _userId!);
      }

      if (_socket?.readyState == html.WebSocket.OPEN) {
        timer.cancel();
        _isReconnecting = false;
      }
    });
  }

  void _updateStatus(WebSocketStatus status) {
    _statusController.add(status);
  }

  Future<void> disconnec() async {
    _reconnectTimer?.cancel();
    _isReconnecting = false;

    if (_socket != null) {
      sendMessage('disconnect', {'user_id': _userId, 'reason': 'user_logout'});
    }

    _socket!.close(1000, 'User initiated disconnect');
    _socket = null;

    _updateStatus(WebSocketStatus.disconnected);
  }

  bool get isConnected => _socket?.readyState == html.WebSocket.OPEN;
}
