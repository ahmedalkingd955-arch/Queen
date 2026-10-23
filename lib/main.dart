import 'package:flutter/material.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/route/router.dart' as router;
import 'package:shop/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart'; // ضيف السطر ده فوق خالص مع الـ imports

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDNDjs4t7M_6RfJf1kOFgp8pXq3FjDUqSc",
      authDomain: "queen-fashoin.firebaseapp.com",
      projectId: "queen-fashoin",
      storageBucket: "queen-fashoin.firebasestorage.app",
      messagingSenderId: "963246006475",
      appId: "1:963246006475:web:4ebbe2b65e6e659e41bb4e",
      measurementId: "G-DHLDJC4DNN",
    ),
  );
  runApp(const MyApp());
}

// Thanks for using our template. You are using the free version of the template.
// 🔗 Full template: https://theflutterway.gumroad.com/l/fluttershop

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shop Template by The Flutter Way',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: onbordingScreenRoute,
    );
  }
}
