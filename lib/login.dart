import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/register.dart';
import 'package:mysql1/mysql1.dart' as mysql;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  SharedPreferences? prefs; // Tambahkan tanda tanya (?) agar nullable

  _launchURL() async {
    const url = 'https://register.com/register';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _signIn() async {
    // Memeriksa apakah email dan password kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login tidak berhasil"),
            content: Text("Tolong isi email dan password dengan benar"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return; // Menghentikan eksekusi lebih lanjut jika email atau password kosong
    }

    final settings = mysql.ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    );

    final conn = await mysql.MySqlConnection.connect(settings);

    var results = await conn.query(
      'SELECT * FROM users WHERE email = ? AND password = ?',
      [
        _emailController.text,
        _hashPassword(_passwordController.text),
      ],
    );

    if (results.isNotEmpty) {
      final row = results.first;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', row['name']);
      await prefs.setString('email', row['email']);
      await prefs.setString('role', row['role']);

      // Cek jika 'image' tidak null sebelum menyimpan ke SharedPreferences
      if (row['image'] != null) {
        await prefs.setString('profile_image_base64', row['image']);
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Login tidak berhasil"),
            content: Text("Email atau password yang diisi tidak terdaftar"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }

    await conn.close();
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 65,
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
            Positioned(
              top: 200,
              left: 30,
              right: 30,
              child: Container(
                height: 400,
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
              child: Text(
                'Sign in',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 295,
              left: 50,
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
            Positioned(
              top: 330,
              left: 50,
              right: 50,
              child: DottedBorder(
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
                    controller: _emailController,
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
            ),
            Positioned(
              top: 390,
              left: 50,
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
                        controller: _passwordController,
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
              top: 490,
              left: 250,
              right: 50,
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: Text(
                      'Sign In',
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
            Positioned(
              top: 545,
              left: 90,
              child: Text(
                'Dont have any account?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
            ),
            Positioned(
              top: 545,
              left: 260,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
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
