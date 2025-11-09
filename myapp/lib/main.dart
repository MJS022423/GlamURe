// myapp/lib/main.dart
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'login-register-setup/login_screen.dart';
import 'homepage-modules/homepage.dart';
import 'login-register-setup/setupAccount.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    // centralised handling for routes that may carry arguments
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/setup':
        // Accept either a String username or a null argument
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(builder: (_) => SetupAccountPage(username: args));
        }
        return MaterialPageRoute(builder: (_) => const SetupAccountPage());
      default:
        // Fallback to login
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'GlamURe',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
