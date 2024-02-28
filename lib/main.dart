import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:realtimechat/chat_page.dart';

import 'firebase_options.dart';
import 'login_screen.dart';

GetStorage getStorage = GetStorage();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: getRoutes(context),
      initialRoute: "/",
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }

  Map<String, Widget Function(BuildContext)> getRoutes(BuildContext context) {
    return {
      '/': (context) => const LoginScreen(),
      '/second': (context) => const MyHomePage(title: "ChatScreen"),
    };
  }
}
