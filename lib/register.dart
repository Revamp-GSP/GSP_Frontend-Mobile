import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:url_launcher/url_launcher.dart';

import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterPage(),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  _launchURL() async {
    Uri _url = Uri.parse('https://www.educative.io');
    if (await canLaunch(_url.toString())) {
      await launch(_url.toString());
    } else {
      throw 'Could not launch $_url';
    }
  }

  Future<void> _registerUser(
      String name, String email, String password, String role) async {
    String hashedPassword = _hashPassword(password);

    final settings = mysql.ConnectionSettings(
      host: '8dd.h.filess.io',
      port: 3307,
      user: 'TATelkom_smoothpony',
      password: '4a0dac89cd2241531033a2dcfacec6e831894384',
      db: 'TATelkom_smoothpony',
    );

    final conn = await mysql.MySqlConnection.connect(settings);

    await conn.query('''
      INSERT INTO users (name, email, password, role)
      VALUES (?, ?, ?, ?)
    ''', [name, email, hashedPassword, role]);

    await conn.close();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    String username = '';
    String email = '';
    String password = '';
    String role = '';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 195, 211, 227),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 65,
              child: GestureDetector(
                child: Text(
                  'App Monitor Project',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200,
              left: 30,
              right: 30,
              child: Stack(
                children: [
                  Container(
                    height: 540,
                    width: 400,
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
                  ),
                ],
              ),
            ),
            Positioned(
              top: 130,
              left: 130,
              child: Image.asset(
                'assets/images/logocircle.png',
                width: 140,
                height: 140,
              ),
            ),
            Positioned(
              top: 255,
              left: 160,
              child: GestureDetector(
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 295,
              left: 50,
              child: GestureDetector(
                child: Text(
                  'Username',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 330,
              left: 50,
              right: 50,
              child: Stack(
                children: [
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(252, 226, 183, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        onChanged: (value) => username = value,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukkan Username',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 390,
              left: 50,
              child: GestureDetector(
                child: Text(
                  'Email',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 420,
              left: 50,
              right: 50,
              child: Stack(
                children: [
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(252, 226, 183, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        onChanged: (value) => email = value,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukkan Email',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 480,
              left: 50,
              child: GestureDetector(
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 510,
              left: 50,
              right: 50,
              child: Stack(
                children: [
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(252, 226, 183, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: TextField(
                        onChanged: (value) => password = value,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Masukkan Password',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.visibility),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 573,
              left: 50,
              child: GestureDetector(
                child: Text(
                  'Role/Jabatan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 605,
              left: 50,
              right: 50,
              child: Stack(
                children: [
                  DottedBorder(
                    color: Colors.black,
                    strokeWidth: 1,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(10),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromRGBO(252, 226, 183, 1),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: DropdownButtonFormField<String>(
                        items: [
                          DropdownMenuItem<String>(
                            value: 'Business Development',
                            child: Text('Business Development'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Officer Business Administration',
                            child: Text('Officer Business Administration'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'IT Service Administration',
                            child: Text('IT Service Administration'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            role = value;
                          }
                        },
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Pilih Role/Jabatan',
                          hintStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 680,
              left: 250,
              right: 50,
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ElevatedButton(
                    onPressed: () {
                      _registerUser(username, email, password, role);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(204, 34, 45, 78),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
