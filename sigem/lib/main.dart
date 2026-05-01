import 'package:flutter/material.dart';

import 'core/api/service_locator.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  runApp(const SigemApp());
}

class SigemApp extends StatelessWidget {
  const SigemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGEM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7B6CF5)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
    
  }
}