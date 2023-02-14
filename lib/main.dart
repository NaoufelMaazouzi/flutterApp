import 'package:flutter/material.dart';
import 'package:myfirstapp/Screens/webview_screen.dart';
import 'package:myfirstapp/Screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        WebViewScreen.routeName: (context) => const WebViewScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Github research'),
    );
  }
}
