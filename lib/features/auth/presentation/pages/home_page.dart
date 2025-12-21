import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xall_call/core/constants/app_constants.dart';
import 'package:xall_call/core/services/ws_notification_service.dart';
import 'package:xall_call/core/services/ws_shared.dart';
import 'package:xall_call/features/call/presentation/widgets/call_notification.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebSocketNotificationService _webSocketNotificationService;
  bool _isWebSocketConnected = false;

  @override
  void initState() {
    super.initState();
    _webSocketNotificationService = WebSocketNotificationService();

    _checkAuthStatus();
  }

  @override
  void dispose() {
    _disconnectWebSocket();
    super.dispose();
  }

  void _checkAuthStatus() {
    // Check auth when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(CheckAuthStatus());
    });
  }

  Future<void> _connectWebSocket(String token, String userId) async {
    try {
      debugPrint('connecting to WebSocket');
      await _webSocketNotificationService.connect(token: token, userId: userId);

      // listen to connection status
      _webSocketNotificationService.statusStream.listen((status) {
        setState(() {
          _isWebSocketConnected = status == WebSocketStatus.connected;
        });

        if (status == WebSocketStatus.connected) {
          debugPrint('homepage => WebSocket connected successfully');
        } else if (status == WebSocketStatus.error) {
          debugPrint('WebSocket connection error');
        }
      });

      // listen for incoming messages
      _webSocketNotificationService.messageStream.listen((message) {
        debugPrint('WebSocket message: ${message.type}');
      });
    } catch (e) {
      debugPrint('Error connecting WebSocket: $e');
    }
  }

  Future<void> _disconnectWebSocket() async {
    try {
      await _webSocketNotificationService.disconnec();
    } catch (e) {
      debugPrint('Error disconnecting WebSocket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // If user becomes unauthenticated, redirect to signin
        if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/signin',
            (route) => false,
          );
        } else if (state is AuthAuthenticated) {
          // Connect WebSocket after successful authentication
          final token =
              state.user.token ??
              html.window.localStorage[AppConstants.tokenKey];
          final userId = state.user.id;
          debugPrint('token: $token, userId: $userId');

          if (token != null) {
            _connectWebSocket(token, userId);
          }
        }
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Dashboard'),
              actions: [
                // WebSocket status indicator
                Icon(
                  _isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isWebSocketConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    _disconnectWebSocket();
                    context.read<AuthBloc>().add(SignOutRequested());
                  },
                ),
              ],
            ),
            body: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                // Show loading while checking auth
                if (state is AuthLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show dashboard only if authenticated
                if (state is AuthAuthenticated) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to Xall Call, ${state.user.username}!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email: ${state.user.email}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),

                        // WebSocket Status
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isWebSocketConnected
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isWebSocketConnected
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _isWebSocketConnected
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isWebSocketConnected
                                    ? 'Call notifications active'
                                    : 'Connecting to call service...',
                                style: TextStyle(
                                  color: _isWebSocketConnected
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            _disconnectWebSocket();
                            context.read<AuthBloc>().add(SignOutRequested());
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                        ),
                      ],
                    ),
                  );
                }

                // If not authenticated, show message and redirect button
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Authentication Required',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      const Text('Please sign in to access the dashboard'),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/signin',
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Go to Sign In'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Call Notification Overlay
          Positioned.fill(
            child: CallNotificationOverlay(
              webSocketNotificationService: _webSocketNotificationService,
            ),
          ),
        ],
      ),
    );
  }
}
