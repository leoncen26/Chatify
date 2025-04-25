import 'package:chatify_app/pages/home_page.dart';
import 'package:chatify_app/pages/registration_page.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import './pages/login_page.dart';
import './services/navigation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatify',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color.fromRGBO(42, 117, 188, 1),
        colorScheme: const ColorScheme.dark(
        primary: Color.fromRGBO(42, 117, 188, 1), 
        secondary: Color.fromRGBO(42, 117, 188, 1), 
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(28, 27, 27, 1)
        ),
        routes: {
          'login': (context) => LoginPage(),
          'register': (context) => RegistrationPage(),
          'home': (context) => HomePage(),
        },
        initialRoute: 'login',
    );
  }
}
