import 'package:flutter/material.dart';
import 'package:myfirstapp/Screens/all_users_screen.dart';
import 'package:myfirstapp/Screens/webview_screen.dart';
import 'package:myfirstapp/Screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApptState();
}

class _MyApptState extends State<MyApp> {
  int _currentIndex = 0;

  setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xff464646), Color(0xffa588d9)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          )),
          child: Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text('Profil Github'),
              ),
              body: const [
                MyHomePage(title: 'Github research'),
                AllUsersPage()
              ][_currentIndex],
              bottomNavigationBar: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setCurrentIndex(index),
                  selectedItemColor: Colors.lightBlue,
                  items: const [
                    BottomNavigationBarItem(
                        icon: Icon(Icons.home), label: 'Accueil'),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.supervised_user_circle_sharp),
                        label: 'Utilisateurs')
                  ]))),
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        WebViewScreen.routeName: (context) => const WebViewScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
