import 'package:fl_chart/fl_chart.dart'; // Import package fl_chart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/inbox.dart';
import 'package:flutter_application_1/list_customer.dart';
import 'package:flutter_application_1/products.dart';
import 'package:flutter_application_1/projects.dart';
import 'package:mysql1/mysql1.dart';
import 'package:table_calendar/table_calendar.dart';

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> tasks = ['Task 1', 'Task 2', 'Task 3'];

  void addTask(String newTask) {
    setState(() {
      tasks.add(newTask);
    });
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
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
              const SizedBox(height: 10),
              Container(
                height: 400,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 35), // Jarak awal

                      // Kotak 1
                      Stack(
                        children: [
                          Container(
                            width: 350,
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Projects',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 250,
                                  padding: const EdgeInsets.all(8.0),
                                  child:
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                    future: fetchProjectsFromDatabase(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      } else {
                                        final projects = snapshot.data!;
                                        return LineChart(
                                          LineChartData(
                                            // Define your chart data here
                                            titlesData: FlTitlesData(
                                              show: true,
                                              bottomTitles: SideTitles(
                                                showTitles: true,
                                                getTextStyles:
                                                    (context, value) =>
                                                        const TextStyle(
                                                  color: Color(0xff7589a2),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                margin: 20,
                                                getTitles: (double value) {
                                                  final index = value.toInt();
                                                  if (index >= 0 &&
                                                      index < projects.length) {
                                                    return projects[index]
                                                        ['nama_pelanggan'];
                                                  } else {
                                                    return '';
                                                  }
                                                },
                                              ),
                                              leftTitles: SideTitles(
                                                showTitles: true,
                                                getTextStyles:
                                                    (context, value) =>
                                                        const TextStyle(
                                                  color: Color(0xff7589a2),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                margin: 32,
                                                reservedSize: 14,
                                                getTitles: (value) {
                                                  if (value == 0) {
                                                    return '0';
                                                  } else if (value % 100 == 0) {
                                                    return '${value.toInt()}';
                                                  } else {
                                                    return '';
                                                  }
                                                },
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: true,
                                              border: Border.all(
                                                color: const Color(0xff37434d),
                                                width: 1,
                                              ),
                                            ),
                                            gridData: FlGridData(
                                              show: true,
                                              drawVerticalLine: true,
                                              horizontalInterval: 100,
                                              getDrawingHorizontalLine:
                                                  (value) {
                                                return FlLine(
                                                  color: Colors.grey,
                                                  strokeWidth: 0.5,
                                                );
                                              },
                                              verticalInterval: 1,
                                              getDrawingVerticalLine: (value) {
                                                return FlLine(
                                                  color: Colors.grey,
                                                  strokeWidth: 0.5,
                                                );
                                              },
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots: projects
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final index = entry.key;
                                                  final project = entry.value;
                                                  return FlSpot(
                                                    index.toDouble(),
                                                    double.tryParse(
                                                            '${project['nilai_perkerjaan_rkap']}') ??
                                                        0.0,
                                                  );
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.lightBlueAccent
                                                      .withOpacity(0.8),
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                belowBarData:
                                                    BarAreaData(show: false),
                                              ),
                                              LineChartBarData(
                                                spots: projects
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final index = entry.key;
                                                  final project = entry.value;
                                                  return FlSpot(
                                                    index.toDouble(),
                                                    double.tryParse(
                                                            '${project['nilai_pekerjaan_aktual']}') ??
                                                        0.0,
                                                  );
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.red.withOpacity(0.8),
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                belowBarData:
                                                    BarAreaData(show: false),
                                              ),
                                              LineChartBarData(
                                                spots: projects
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final index = entry.key;
                                                  final project = entry.value;
                                                  return FlSpot(
                                                    index.toDouble(),
                                                    double.tryParse(
                                                            '${project['nilai_pekerjaan_kontrak_tahun_berjalan']}') ??
                                                        0.0,
                                                  );
                                                }).toList(),
                                                isCurved: true,
                                                colors: [
                                                  Colors.green.withOpacity(0.8),
                                                ],
                                                barWidth: 2,
                                                isStrokeCapRound: true,
                                                belowBarData:
                                                    BarAreaData(show: false),
                                              ),
                                            ],
                                            clipData: FlClipData.none(),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectsPage()),
                                        );
                                      },
                                      child: Text(
                                        'View',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(204, 34, 45, 78),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 35), // Jarak antara kotak
                      // Kotak 2

                      Stack(
                        children: [
                          Container(
                            width: 350,
                            height: 400, // Atur tinggi sesuai kebutuhan Anda
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
                          Positioned(
                            top: 10,
                            left: 20,
                            child: Text(
                              'Products',
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
                            bottom: 10,
                            right: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductsPage()),
                                  );
                                },
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(204, 34, 45, 78),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 35), // Jarak antara kotak

                      // Kotak 3
                      Stack(
                        children: [
                          Container(
                            width: 350,
                            height: 400,
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
                          Positioned(
                            top: 10,
                            left: 20,
                            child: Text(
                              'List Customer',
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
                            bottom: 10,
                            right: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            List_CustomerPage()),
                                  );
                                },
                                child: Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(204, 34, 45, 78),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 40), // Jarak akhir
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                width: 350,
                height: 790,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    // Kalender
                    TableCalendar(
                      firstDay: DateTime.utc(2022, 1, 1),
                      lastDay: DateTime.utc(2025, 12, 31),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(formatButtonVisible: false),
                      calendarStyle: const CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // My Task/To Do List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
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
                            // Baris header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10), // Perkecil jarak vertikal
                              height: 60,
                              decoration: const BoxDecoration(
                                color: const Color.fromARGB(204, 34, 45, 78),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // Ganti dengan MainAxisAlignment.center
                                children: [
                                  const Text(
                                    "Today’s Tasks",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AddTaskDialog(
                                          onTaskAdded: addTask,
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Daftar task
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10), // Perkecil jarak vertikal
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  return TaskTile(
                                    taskTitle: tasks[index],
                                    isChecked: false,
                                    checkboxCallback: (checkboxState) {
                                      setState(() {
                                        // tasks[index].toggleDone();
                                      });
                                    },
                                    longPressCallback: () {
                                      setState(() {
                                        removeTask(index);
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
                  onPressed: () {},
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

  Future<List<Map<String, dynamic>>> fetchProjectsFromDatabase() async {
    final settings = ConnectionSettings(
      host: '8dd.h.filess.io',
      port: 3307,
      user: 'TATelkom_smoothpony',
      password: '4a0dac89cd2241531033a2dcfacec6e831894384',
      db: 'TATelkom_smoothpony',
    );

    try {
      final _connection = await MySqlConnection.connect(settings);
      var results = await _connection.query('SELECT * FROM projects');
      await _connection.close();

      // Mengonversi setiap ResultRow menjadi Map<String, dynamic>
      return results.map((row) => row.fields).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}

class AddTaskDialog extends StatelessWidget {
  final Function(String) onTaskAdded;

  const AddTaskDialog({required this.onTaskAdded});

  @override
  Widget build(BuildContext context) {
    String newTaskTitle = '';

    return AlertDialog(
      title: const Text('Add Task'),
      content: TextField(
        autofocus: true,
        onChanged: (newText) {
          newTaskTitle = newText;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onTaskAdded(newTaskTitle);
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class TaskTile extends StatelessWidget {
  final bool isChecked;
  final String taskTitle;
  final Function(bool?) checkboxCallback;
  final Function() longPressCallback;

  TaskTile({
    required this.isChecked,
    required this.taskTitle,
    required this.checkboxCallback,
    required this.longPressCallback,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: longPressCallback,
      title: Text(
        taskTitle,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
          decoration: isChecked ? TextDecoration.lineThrough : null,
        ),
      ),
      trailing: Checkbox(
        activeColor: const Color.fromARGB(204, 34, 45, 78),
        value: isChecked,
        onChanged: checkboxCallback,
      ),
    );
  }
}
