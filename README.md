### Xall Call

A modern, production-ready Flutter web application for real-time call notifications with secure user authentication.

## Features

- ** Secure Authentication** - Email/username & password authentication with JWT tokens
- ** WebSocket Integration** - Real-time call notifications and messaging
- ** Responsive Design** - Works seamlessly across all screen sizes
- ** Clean Architecture** - Modular, testable, and scalable codebase
- ** Modern UI** - Beautiful Flutter Material 3 design with light/dark themes
- ** State Management** - Bloc pattern for predictable state management
- ** Persistent Storage** - localStorage for web-based data persistence

##  Prerequisites

- **Flutter SDK** (>= 3.0.0)
- **Dart** (>= 3.0.0)
- **Web Browser** (Chrome, Firefox, Edge, or Safari)
- **Backend Server** (Django/DRF with WebSocket support)

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/johnson-oragui/xall_call
   cd xall-call
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Copy `.env.example` to `.env`
   - Update environment variables:
   ```env
   # Development
   BASE_URL=http://localhost:8000/api/v1
   
   # Production
   # BASE_URL=https://api-xall-call.techjohnson.tech/api/v1
   ```

4. **Run the application**
   ```bash
   # Development mode
   flutter run -d chrome --dart-define=ENVIRONMENT=development
   
   # Production mode
   flutter run -d chrome --dart-define=ENVIRONMENT=production
   ```

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/           # App constants and configuration
│   ├── styles/             # Themes, colors, and text styles
│   ├── widgets/            # Reusable UI components
│   └── utils/              # Helper functions and validators
├── features/
│   └── auth/
│       ├── data/           # Data layer (models, datasources, repositories)
│       ├── domain/         # Business logic (entities, usecases, repositories)
│       └── presentation/   # UI layer (pages, bloc, widgets)
├── features/call/
│   └── presentation/       # Call notification and WebSocket integration
└── core/services/          # WebSocket and storage services
```

## 🔐 Authentication Flow

1. **Sign Up** - Create new account with email, username, and password
2. **Sign In** - Authenticate with email/username and password
3. **Token Storage** - JWT tokens stored securely in localStorage
4. **Auto-login** - Tokens persist across browser sessions
5. **Protected Routes** - Authentication required for dashboard access

## 📡 WebSocket Integration

The app establishes a WebSocket connection after successful authentication to enable real-time features:

### Connection Flow:
1. **Authentication** - User signs in successfully
2. **Token Validation** - JWT token sent to WebSocket endpoint
3. **Connection** - WebSocket connection established
4. **Heartbeat** - Regular pings to maintain connection
5. **Reconnection** - Automatic reconnection on disconnect

### Call Notifications:
- **Incoming Call** - Overlay notification with caller info
- **Call Actions** - Accept/Reject/Missed call handling
- **Call Status** - Real-time call state updates
- **Presence** - User online/offline status

## 🎨 UI Components

### Reusable Widgets:
- `CustomTextField` - Form input with validation
- `LoadingButton` - Button with loading state
- `CallNotificationOverlay` - Incoming call notification
- `AuthGuard` - Route protection wrapper

### Pages:
- `SignInPage` - User authentication
- `SignUpPage` - Account creation
- `HomePage` - Dashboard with WebSocket status
- `CallScreen` - Ongoing call interface

## ⚙️ Configuration

### Environment Variables
Configure via `--dart-define` flags or `.env` file:

```bash
# Development
flutter run -d chrome --dart-define=ENVIRONMENT=development

# Staging
flutter run -d chrome --dart-define=ENVIRONMENT=staging

# Production
flutter run -d chrome --dart-define=ENVIRONMENT=production
```

### API Configuration
Update `lib/core/config/environment.dart`:

```dart
static void initialize(Environment env) {
  switch (env) {
    case Environment.development:
      _apiBaseUrl = 'http://localhost:8000/api/v1';
      break;
    case Environment.production:
      _apiBaseUrl = 'https://api.xallcall.com/api/v1';
      break;
  }
}
```

## 🧪 Testing

Run tests with:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
```

## 📦 Build & Deployment

### Build for Web:
```bash
# Development build
flutter build web --dart-define=ENVIRONMENT=development

# Production build (optimized)
flutter build web --dart-define=ENVIRONMENT=production --release
```

### Deployment Options:
1. **Firebase Hosting**
   ```bash
   firebase init hosting
   firebase deploy --only hosting
   ```

2. **Netlify**
   - Connect repository
   - Build command: `flutter build web`
   - Publish directory: `build/web`

3. **Vercel**
   - Import project
   - Framework preset: Other
   - Output directory: `build/web`

## 🔧 Backend Integration

### Required Endpoints:
```
POST   /api/v1/auth/signin                               # User authentication
POST   /api/v1/auth/signup                               # User registration
POST   /api/v1/auth/signout                              # User logout
WS     /ws/calls/call_id/?token=tokenhere                # WebSocket endpoint
WS     /ws/notify/?token=tokenhere                       # WebSocket endpoint
```

### WebSocket Requirements:
- **Authentication** via JWT token in query params
- **Message Format**:
  ```json
  {
    "type": "call_incoming",
    "data": {
      "callId": "uuid",
      "caller": "user_id",
      "callerName": "John Doe",
      "callType": "audio|video"
    },
    "timestamp": "2024-01-01T12:00:00Z"
  }
  ```

## 🚨 Troubleshooting

### Common Issues:

1. **CORS Errors**
   ```
   ClientException: Failed to fetch
   ```
   **Solution**: Configure CORS on your backend server:
   ```python
   # Django settings.py
   CORS_ALLOWED_ORIGINS = [
       "http://localhost:3000",  # Flutter dev server
   ]
   ```

2. **WebSocket Connection Failed**
   ```
   WebSocket connection error
   ```
   **Solution**: Check backend WebSocket server is running and accessible.

3. **Authentication Token Issues**
   ```
   AuthUnauthenticated error
   ```
   **Solution**: Clear browser localStorage and sign in again.

### Debug Mode:
Enable detailed logging:
```dart
// Add to main.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    print('${bloc.runtimeType} $change');
  }
}

void main() {
  Bloc.observer = SimpleBlocObserver();
  runApp(MyApp());
}
```

## 📚 API Reference

### Authentication
- `POST /auth/signin` - Authenticate user
- `POST /auth/signup` - Register new user
- `POST /auth/signout` - Logout user

### WebSocket Events
- `call_incoming` - New incoming call
- `call_accepted` - Call was accepted
- `call_rejected` - Call was rejected
- `call_ended` - Call ended
- `call_missed` - Missed call notification
- `presence_update` - User status change

## 🔗 Dependencies

| Package | Purpose | Version |
|---------|---------|---------|
| `flutter_bloc` | State management | ^8.1.3 |
| `equatable` | Value equality | ^2.0.5 |
| `http` | HTTP requests | ^1.1.0 |
| `get_it` | Dependency injection | ^7.6.4 |
| `shared_preferences` | Local storage | ^2.2.2 |
| `js` | JavaScript interop | ^0.6.7 |

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

### Code Style:
- Follow Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Bloc library for state management
- Django Channels for WebSocket support
- All contributors and testers
