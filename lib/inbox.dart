import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/home.dart';
import 'package:http/http.dart' as http;

import 'profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: InboxPage(),
    );
  }
}

Future<List<Map<String, dynamic>>> fetchNotifications() async {
  final response = await http
      .get(Uri.parse('https://3dkb.my.id/api/notifications?user_id=7'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to load notifications');
  }
}

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  _InboxPageState createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool hasNewNotification = false; // State to track new notifications
  List<Map<String, dynamic>> notifications = [];
  DateTime dataFetchTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchNotificationsAndCheckNew();
  }

  void fetchNotificationsAndCheckNew() async {
    try {
      List<Map<String, dynamic>> fetchedNotifications =
          await fetchNotifications();
      setState(() {
        notifications = fetchedNotifications;
        hasNewNotification = notifications.any((notification) {
          DateTime notificationTime =
              DateTime.parse(notification['created_at']);
          return notificationTime.isAfter(dataFetchTime);
        });
      });
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  void markAllAsRead() {
    setState(() {
      hasNewNotification = false;
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
                  'Inbox Notifications',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                height: 55,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        // Handle search button press
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No notifications found.'));
                  } else {
                    var filteredNotifications =
                        snapshot.data!.where((notification) {
                      var projectName = notification['data']['project_name']
                              ?.toString()
                              .toLowerCase() ??
                          "";
                      return projectName.contains(searchQuery);
                    }).toList();

                    if (filteredNotifications.isEmpty) {
                      return Center(
                          child: Text('No notifications match your search.'));
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        var notification = filteredNotifications[index];
                        var message = notification['data']['message'];
                        var projectId = notification['data']['project_id'];
                        var projectName = notification['data']['project_name'];
                        var changes = notification['data']['changes'];
                        var createdAt = notification['created_at'];

                        bool isNew =
                            DateTime.parse(createdAt).isAfter(dataFetchTime);

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(message),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (projectId != null)
                                  Text('Project ID: $projectId'),
                                if (projectName != null)
                                  Text('Project Name: $projectName'),
                                if (changes != null)
                                  ...changes.entries.map((change) {
                                    var field = change.key;
                                    var oldValue = change.value['old'];
                                    var newValue = change.value['new'];
                                    return Text(
                                        '$field changed from $oldValue to $newValue');
                                  }).toList(),
                                Text(
                                    'Received At: ${dataFetchTime.toString()}'),
                                if (isNew)
                                  Text('New!',
                                      style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 30),
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
                Stack(
                  children: [
                    IconButton(
                      color: const Color.fromARGB(204, 34, 45, 78),
                      icon: const Icon(Icons.message),
                      iconSize: 35,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => InboxPage()),
                        ).then((_) {
                          markAllAsRead();
                        });
                      },
                    ),
                    if (hasNewNotification)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 12,
                            minHeight: 12,
                          ),
                          child: Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
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
