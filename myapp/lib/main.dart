import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'login_screen.dart';
<<<<<<< Updated upstream
import 'homepage-modules/homepage.dart';
=======
import 'homepage.dart';
import 'menu.dart';
import 'setupAccount.dart';
>>>>>>> Stashed changes

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlamURe',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      // App routes
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
<<<<<<< Updated upstream
=======
        '/menu': (context) => const MenuPage(),
        '/setupAccount': (context) => const SetupAccountPage(),
>>>>>>> Stashed changes
      },
      initialRoute: '/',
    );
  }
}
