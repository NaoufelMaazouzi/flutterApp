import 'package:flutter/material.dart';
import 'package:myfirstapp/Screens/webview_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AllUsersPage extends StatefulWidget {
  const AllUsersPage({super.key});

  @override
  State<AllUsersPage> createState() => _AllUsersPageState();
}

class _AllUsersPageState extends State<AllUsersPage> {
  Future<dynamic>? _user;
  bool _isFailed = false;

  Future fetchUsersFromGitHub() async {
    try {
      final response =
          await http.get(Uri.parse('https://api.github.com/users'));
      if (response.statusCode != 200) {
        setState(() {
          _isFailed = true;
        });
        throw 'Aucun utilisateur avec ce nom existe';
      }
      return json.decode(response.body);
    } catch (e) {
      log('Failed to fetch user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        future: _user = fetchUsersFromGitHub(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Column(
                  children: <Widget>[
                    Card(
                      child: ListTile(
                        leading: Image.network(
                            snapshot.data[index]['avatar_url'],
                            width: 56,
                            height: 56),
                        title: Text(snapshot.data[index]['login']),
                        subtitle: const Text('Here is a second line'),
                        trailing: IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined),
                            tooltip: 'Increase volume by 10',
                            onPressed: () => Navigator.pushNamed(
                                  context,
                                  WebViewScreen.routeName,
                                  arguments: ScreenArguments(
                                      snapshot.data[index]['html_url']),
                                )),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else if (_user != null && !_isFailed) {
            return const SpinKitWave(
                color: Colors.white, type: SpinKitWaveType.start);
          } else {
            return const Text('Aucun utilisateur avec ce nom existe');
          }
        },
      ),
    );
  }
}
