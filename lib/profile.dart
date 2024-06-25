import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/inbox.dart';
import 'package:flutter_application_1/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image;
  final picker = ImagePicker();
  String _name = '';
  String _email = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadImageFromDatabase();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? '-';
      _email = prefs.getString('email') ?? '-';
      _role = prefs.getString('role') ?? '-';
      // Memeriksa apakah ada path file gambar tersimpan
      String? imagePath = prefs.getString('profile_image');
      if (imagePath != null) {
        _image = File(imagePath);
      }
    });
  }

  Future<void> _saveImageToDatabase(String imagePath) async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    ));

    try {
      // Asumsikan bahwa email disimpan dalam shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      await conn.query(
        'UPDATE users SET image = ? WHERE email = ?',
        [imagePath, email],
      );
    } finally {
      await conn.close();
    }
  }

  Future<void> _loadImageFromDatabase() async {
    final conn = await mysql.MySqlConnection.connect(mysql.ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    ));

    try {
      // Asumsikan bahwa email disimpan dalam shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      var results = await conn.query(
        'SELECT image FROM users WHERE email = ?',
        [email],
      );

      if (results.isNotEmpty) {
        var row = results.first;
        String? imagePath = row[0];

        if (imagePath != null) {
          setState(() {
            _image = File(imagePath);
          });
        }
      }
    } finally {
      await conn.close();
    }
  }

  Future<void> _getImageFromGallery() async {
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
      _saveImageToDatabase(_image!.path); // Simpan path file gambar ke database
    });
  }

  Future<void> _getImageFromCamera() async {
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    setState(() {
      _image = File(image.path);
      _saveImageToDatabase(_image!.path); // Simpan path file gambar ke database
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              GestureDetector(
                child: const Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Choose Image Source'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _getImageFromGallery();
                                  },
                                  child: const Text('Gallery'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _getImageFromCamera();
                                  },
                                  child: const Text('Camera'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        child: _image != null
                            ? ClipOval(
                                child: Image.file(
                                  _image!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Name: $_name',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Email: $_email',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Role: $_role',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                height: 70,
                width: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      child: GestureDetector(
                        onTap: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: Row(
                          children: [
                            Icon(Icons.logout), // icon logout
                            SizedBox(width: 5),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                                color: Colors.black,
                              ),
                            ), // text logout
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Colors.white,
          child: Container(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  color: const Color.fromARGB(204, 34, 45, 78),
                  icon: const Icon(Icons.home),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                ),
                IconButton(
                  color: const Color.fromARGB(204, 34, 45, 78),
                  icon: const Icon(Icons.message),
                  iconSize: 35,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => InboxPage()),
                    );
                  },
                ),
                IconButton(
                  color: const Color.fromARGB(204, 34, 45, 78),
                  icon: const Icon(Icons.person),
                  iconSize: 40,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfilePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
