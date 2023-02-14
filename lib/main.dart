import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';
import 'package:myfirstapp/widget/custom_button.dart';

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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'teeeest'),
    );
  }
}

// class User {
//   String name;
//   int id;
//   User({required this.name, required this.id});
// }

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
        throw 'Aucun utilisateur avec ce nom existe';
        // Future.error('Aucun utilisateur avec ce nom existe');
      }
      return json.decode(response.body);
    } catch (e) {
      log('Failed to fetch user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 5.0),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                    hintText: 'Entrez votre nom',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _textController.clear();
                      },
                    )),
              ),
            ),
            MaterialButton(
                onPressed: () {
                  setState(() {
                    _imageAdded = false;
                    _user = fetchUsersFromGitHub(_textController.text);
                  });
                },
                color: Colors.blue,
                child: const Text(
                  'Rechercher',
                  style: TextStyle(color: Colors.white),
                )),
            const SizedBox(height: 20),
            FutureBuilder(
              future: _user,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data);
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
                          children: [
                            const Text('Nom:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['name'] ?? 'Aucun nom',
                                style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Entreprise:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(
                                snapshot.data['company'] ?? 'Aucune entreprise',
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('Followers:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['followers'].toString(),
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                        Row(
                          children: [
                            const Text('ID:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(snapshot.data['id'].toString(),
                                style: const TextStyle(fontSize: 20))
                          ],
                        ),
                      ]);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else if (_user != null) {
                  return const CircularProgressIndicator();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            const SizedBox(height: 40),
            if (_user != null)
              customButton(
                  title: 'Choisir une image de la gallerie.',
                  icon: Icons.image_outlined,
                  onClick: () => getImage(ImageSource.gallery)),
            if (_user != null)
              customButton(
                  title: 'Prendre une photo avec la camera.',
                  icon: Icons.camera,
                  onClick: () => getImage(ImageSource.camera))
          ]),
        ));
  }
}
