import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xall_call/core/services/ws_notification_service.dart';
import 'package:xall_call/core/services/ws_shared.dart';

class CallNotificationOverlay extends StatefulWidget {
  final WebSocketNotificationService webSocketNotificationService;

  const CallNotificationOverlay({
    super.key,
    required this.webSocketNotificationService,
  });

  @override
  State<CallNotificationOverlay> createState() =>
      _CallNotificationOverlayState();
}

class _CallNotificationOverlayState extends State<CallNotificationOverlay> {
  WebSocketMessage? _currentCall;
  Timer? _callTimer;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    _listenToWebSocket();
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    widget.webSocketNotificationService.messageStream.listen(null).cancel();
    super.dispose();
  }

  void _listenToWebSocket() {
    widget.webSocketNotificationService.messageStream.listen((message) {
      if (message.type == 'call_incoming') {
        _showIncomingCall(message);
        return;
      }
      if (message.type == 'call_ended') {
        _dismissCall();
        return;
      }
    });
  }

  void _showIncomingCall(WebSocketMessage message) {
    setState(() {
      _currentCall = message;
      _callDuration = 0;
    });

    // Start call duration timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });

      // Auto-dismiss after 10 seconds
      if (_callDuration >= 10) {
        _onMissedCall();
        timer.cancel();
      }
    });
  }

  void _dismissCall() {
    _callTimer?.cancel();
    setState(() {
      _currentCall = null;
      _callDuration = 0;
    });
  }

  void _onAcceptCall() {
    if (_currentCall == null) return;

    widget.webSocketNotificationService.sendCallResponse(
      _currentCall!.data['call_id'],
      'accept',
    );
    _dismissCall();

    Navigator.pushNamed(context, '/call', arguments: _currentCall!.data);
  }

  void _onRejectCall() {
    if (_currentCall == null) return;

    widget.webSocketNotificationService.sendCallResponse(
      _currentCall!.data['call_id'],
      'reject',
    );

    _dismissCall();
  }

  void _onMissedCall() {
    if (_currentCall == null) return;

    widget.webSocketNotificationService.sendMessage('call_missed', {
      'call_id': _currentCall!.data['call_id'],
      'user_id': _currentCall!.data['user_id'],
    });

    _dismissCall();
  }

  @override
  Widget build(BuildContext context) {
    // if no call, do not show
    if (_currentCall == null) {
      return const SizedBox.shrink();
    }
    final String callerName =
        _currentCall!.data['username'] ?? 'Unknown Caller';
    final String callerAvatar =
        _currentCall!.data['user_image'] ??
        callerName.toString().substring(0, 2);
    final String callType = _currentCall!.data['call_type'] ?? 'audio';

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: callerAvatar.length > 2
                    ? NetworkImage(callerAvatar)
                    : null,
                child: callerAvatar.length == 2
                    ? Text(
                        callerAvatar,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              //call info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      callType == 'video' ? '📹 Video Call' : '📞 Audio Call',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Ringing... $_callDuration',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Action Button
              Row(
                children: [
                  // Reject Button
                  InkWell(
                    onTap: _onRejectCall,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Accept Button
                  InkWell(
                    onTap: _onAcceptCall,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        callType == 'video' ? Icons.videocam : Icons.call,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
