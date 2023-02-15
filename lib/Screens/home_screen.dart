import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myfirstapp/Screens/webview_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final _textController = TextEditingController();
  String userInput = '';
  Future<dynamic>? _user;
  bool _imageAdded = false;
  bool _isFailed = false;

  Future getImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      final imagePermanent = await saveFilePermanently(image.path);

      setState(() {
        _image = imagePermanent;
        _imageAdded = true;
      });
    } catch (e) {
      log('Failed to load image: $e');
    }
  }

  Future<File> saveFilePermanently(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(imagePath);
    final image = File('${directory.path}/$name');

    return File(imagePath).copy(image.path);
  }

  Future fetchUsersFromGitHub(String user) async {
    try {
      final response =
          await http.get(Uri.parse('https://api.github.com/users/$user'));
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
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 5.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                    hintText: 'Ecrivez un nom',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _textController.clear();
                        setState(() {
                          _user = null;
                        });
                      },
                    )),
                onChanged: (value) => setState(() {
                  _imageAdded = false;
                  _user = fetchUsersFromGitHub(value);
                }),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder(
              future: _user,
              builder: (context, snapshot) {
                if (snapshot.hasData && _user != null) {
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _image != null && _imageAdded
                            ? Image.file(
                                _image!,
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                              )
                            : Image.network(snapshot.data['avatar_url'],
                                width: 150, height: 150),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Nom:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['name'] ?? 'Aucun nom',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Entreprise:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(
                                snapshot.data['company'] ?? 'Aucune entreprise',
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('Followers:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['followers'].toString(),
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text('ID:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['id'].toString(),
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                        ElevatedButton.icon(
                          label: const Text('Voir son Github'),
                          icon: const Icon(Icons.remove_red_eye_outlined),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              WebViewScreen.routeName,
                              arguments:
                                  ScreenArguments(snapshot.data['html_url']),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          label:
                              const Text('Choisir une image de la gallerie.'),
                          icon: const Icon(Icons.image_outlined),
                          onPressed: () {
                            getImage(ImageSource.gallery);
                          },
                        ),
                        ElevatedButton.icon(
                          label:
                              const Text('Prendre une photo avec la camera.'),
                          icon: const Icon(Icons.camera),
                          onPressed: () {
                            getImage(ImageSource.camera);
                          },
                        ),
                      ]);
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
          ]),
        ));
  }
}
