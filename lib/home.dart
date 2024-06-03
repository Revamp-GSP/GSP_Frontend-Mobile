import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/inbox.dart';
import 'package:flutter_application_1/list_customer.dart';
import 'package:flutter_application_1/products.dart';
import 'package:flutter_application_1/projects.dart';
import 'package:mysql1/mysql1.dart' as mysql;
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
  late TextEditingController _taskEditingController;
  late MySqlConnection _connection;
  List<Map<String, dynamic>> _produks = [];
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _customers = [];
  int _totalCustomers = 0;
  List<String> statuses = [
    'Postpone',
    'Follow Up',
    'Implementasi',
    'Payment',
    'Finished'
  ];

  // New variables for To-Do List
  List<String> tasks = [];
  List<bool> taskCompletionStatus = [];
  String newTask = '';

  @override
  void initState() {
    super.initState();
    _connectToDB();
    _taskEditingController = TextEditingController();
  }

  Future<void> _connectToDB() async {
    final settings = mysql.ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    );

    try {
      final connection = await MySqlConnection.connect(settings);
      var results1 = await connection.query('SELECT * FROM produks');
      var results2 = await connection.query('SELECT * FROM projects');
      var results3 = await connection.query(
          'SELECT COUNT(DISTINCT nama_pelanggan) AS total FROM customers');

      await connection.close();

      setState(() {
        _produks = results1.map((row) => row.fields).toList();
        _projects = results2.map((row) => row.fields).toList();
        _totalCustomers = results3.first['total'];
      });
    } catch (e) {
      setState(() {
        _totalCustomers = -1; // Menandakan bahwa ada kesalahan
      });
      print('Error connecting to database: $e');
    }
  }

// Method to show dialog for adding tasks
  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Task'),
          content: TextField(
            onChanged: (value) {
              newTask = value;
            },
            decoration: InputDecoration(hintText: 'Masukkan task baru'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  setState(() {
                    tasks.add(newTask);
                    taskCompletionStatus
                        .add(false); // Add default completion status
                    newTask = ''; // Reset newTask value
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Tambah'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  // Method to handle checking/unchecking tasks
  void toggleTaskCompletion(int index) {
    setState(() {
      taskCompletionStatus[index] = !taskCompletionStatus[index];
    });
  }

  // Method to handle deleting tasks
  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      taskCompletionStatus.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> _filteredProduks = _produks;

    // Menghitung seberapa sering setiap service muncul dalam data
    Map<String, int> serviceFrequency = {};
    _filteredProduks.forEach((produk) {
      String serviceName = produk['nama_service'];
      serviceFrequency.update(serviceName, (value) => value + 1,
          ifAbsent: () => 1);
    });

    // Define a list of fixed colors
    final List<Color> fixedColors = [
      Color(0xFFAED581), // Light Green
      Color(0xFF4FC3F7), // Light Blue
      Color(0xFFFFF176), // Light Yellow
      Color(0xFFBA68C8), // Light Purple
      Color(0xFFFF8A65), // Light Orange
      Color(0xFF81C784), // Green
      Color(0xFF64B5F6), // Blue
      Color(0xFFFFD54F), // Yellow
      Color(0xFFDCE775), // Lemon Green
      Color(0xFF9575CD), // Purple
    ];

    // Membuat list dari data untuk chart
    List<PieChartSectionData> sections = [];
    int colorIndex = 0; // Index to keep track of color for each section
    serviceFrequency.forEach((serviceName, frequency) {
      sections.add(
        PieChartSectionData(
          color:
              fixedColors[colorIndex % fixedColors.length], // Use fixed colors
          value: frequency.toDouble(),
          title: '$serviceName\n($frequency)',
          radius: 115, // Atur besar kecilnya donut chart di sini
          titleStyle: TextStyle(
            fontSize:
                12, // Atur ukuran font agar tidak melebihi batas donut chart
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

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
              const SizedBox(height: 20),
              Container(
                height: 510,
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
                            height: 550, // Atur tinggi sesuai kebutuhan Anda
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
                          Positioned(
                            top: 40,
                            left: 0,
                            right: 10,
                            child: SizedBox(
                              height: 300,
                              width: 400,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: _projects.length.toDouble(),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: SideTitles(
                                        showTitles: true,
                                        getTextStyles: (context, value) =>
                                            TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        margin: 50,
                                        getTitles: (double value) {
                                          switch (value.toInt()) {
                                            case 0:
                                              return 'Pp'; // Postpone
                                            case 1:
                                              return 'FU'; // Follow Up
                                            case 2:
                                              return 'Imp'; // Implementasi
                                            case 3:
                                              return 'Pb'; // Pembayaran
                                            case 4:
                                              return 'S'; // Selesai
                                            default:
                                              return '';
                                          }
                                        },
                                      ),
                                      leftTitles: SideTitles(showTitles: false),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      for (var i = 0; i < statuses.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              y: _projects
                                                  .where((project) =>
                                                      project['status'] ==
                                                      statuses[i])
                                                  .length
                                                  .toDouble(),
                                              colors: [Colors.blue],
                                            ),
                                          ],
                                          showingTooltipIndicators: [0],
                                        ),
                                    ],
                                    barTouchData: BarTouchData(
                                      touchTooltipData: BarTouchTooltipData(
                                        tooltipBgColor: Colors.transparent,
                                        getTooltipItem:
                                            (group, groupIndex, rod, rodIndex) {
                                          final totalCount = _projects
                                              .where((project) =>
                                                  project['status'] ==
                                                  statuses[group.x.toInt()])
                                              .length;
                                          return BarTooltipItem(
                                            '$totalCount',
                                            TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            children: [],
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 350,
                            left: 20,
                            right: 20,
                            child: Text(
                              'Ket:\n' +
                                  'Pp: Postpone\n' +
                                  'FU: Follow Up\n' +
                                  'Imp: Implementasi\n' +
                                  'Pb: Pembayaran\n' +
                                  'S: Selesai',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
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
                                        builder: (context) => ProjectsPage()),
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
                            top: 40,
                            left: 20,
                            child: SizedBox(
                              height: 320,
                              width: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: sections,
                                  borderData: FlBorderData(show: false),
                                  centerSpaceRadius: 33,
                                  sectionsSpace: 1,
                                  startDegreeOffset: 180,
                                ),
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
                      //box3

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
                          // Add this Text widget to display the total number of customers
                          Positioned(
                            top: 50,
                            left: 20,
                            child: Text(
                              'Total: ${_totalCustomers}', // Assuming `_produks` contains customer data
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
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
                height: 750,
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
                    // Teks Kalender
                    Text(
                      'Calendar',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        color: Colors.black,
                      ),
                    ),
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
                    Container(
                      width: 300,
                      height: 300, // Atur tinggi sesuai kebutuhan Anda
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
                      child: Padding(
                        padding: const EdgeInsets.all(
                            16.0), // Tambahkan padding jika diperlukan
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              // Menempatkan teks di tengah
                              child: Text(
                                'My Task',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5, // Jarak antara teks dan to-do list
                            ),
                            Expanded(
                              // Gunakan Expanded untuk memberikan ruang bagi daftar tugas
                              child: ListView(
                                children: [
                                  // To-Do List
                                  Column(
                                    children:
                                        tasks.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      String task = entry.value;
                                      return ListTile(
                                        leading: IconButton(
                                          // Menggunakan IconButton sebagai ganti Checkbox
                                          icon: Icon(Icons
                                              .edit), // Menggunakan icon edit
                                          onPressed: () {
                                            _taskEditingController.text =
                                                task; // Mengatur teks pada TextField ketika tombol edit ditekan
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Edit Task'),
                                                content: TextField(
                                                  controller:
                                                      _taskEditingController, // Menggunakan controller untuk mengontrol teks
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        'Masukkan task baru',
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        tasks[index] =
                                                            _taskEditingController
                                                                .text; // Mengupdate nilai task
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text('Simpan'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        title: Text(task),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            deleteTask(index);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            // Form untuk menambahkan task baru
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _showAddTaskDialog(context);
                                },
                                child: Text('Tambah Task'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
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
}
