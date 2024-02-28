import 'package:flutter/material.dart';
import 'package:realtimechat/main.dart';

import 'chat_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController token = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Column(
          children: [
            TextField(
              controller: token,
            ),
            FilledButton(
                onPressed: () async {
                  await getStorage.write("token", token.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyHomePage(
                                title: 'ChatPage',
                              )));
                },
                child: Text("Login")),
            if (getStorage.read("token") != null) Text("${getStorage.read("token")} not null")
          ],
        ),
      ),
    );
  }
}
