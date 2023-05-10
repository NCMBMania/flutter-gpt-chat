import 'package:flutter/material.dart';
import './chat.dart';
import 'package:ncmb/ncmb.dart';

void main() {
  NCMB('9170ffcb91da1bbe0eff808a967e12ce081ae9e3262ad3e5c3cac0d9e54ad941',
      '333e123045a62a2a4abeecc0481332e6ab8953457772850e3e4efa0eea77840c');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
