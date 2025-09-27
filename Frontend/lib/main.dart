import 'package:chatbot/pages/home_page.dart';
import 'package:chatbot/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final key = await SharedPreferences.getInstance();
  final status = key.getBool('statusLogin') ?? false;
  runApp(MyApp(status: status,));
}

class MyApp extends StatelessWidget {
  MyApp({required this.status});
  bool status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Chatbot AI",
      home: status ? HomePage() : LoginPage(),
    );
  }
}