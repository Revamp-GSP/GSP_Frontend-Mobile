import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late MySqlConnection _connection;
  List<Map<String, dynamic>> _projects = [];
  TextEditingController _searchController = TextEditingController();
  double _scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _connectToDB();
  }

  Future<void> _connectToDB() async {
    final settings = ConnectionSettings(
      host: '8dd.h.filess.io',
      port: 3307,
      user: 'TATelkom_smoothpony',
      password: '4a0dac89cd2241531033a2dcfacec6e831894384',
      db: 'TATelkom_smoothpony',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      var results = await _connection.query('SELECT * FROM projects');

      results.forEach((row) {
        _projects.add(Map<String, dynamic>.from(row.fields));
      });

      setState(() {});
    } catch (e) {
      print('Error connecting to database: $e');
    }
  }

  @override
  void dispose() {
    _connection.close();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredProjects = [];

  @override
  Widget build(BuildContext context) {
    _filteredProjects = _projects.where((project) {
      final customerName = project['nama_pelanggan'].toString().toLowerCase();
      final searchText = _searchController.text.toLowerCase();
      return customerName.contains(searchText);
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 195, 211, 227),
      body: Column(
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: Align(
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
              ),
            ],
          ),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                GestureDetector(
                  child: Center(
                    child: Text(
                      'Projects',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 450,
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: LineChart(
                                LineChartData(
                                  minX: 0,
                                  maxX: _filteredProjects.length.toDouble() - 1,
                                  minY: 0,
                                  maxY: 600,
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: SideTitles(
                                      showTitles: true,
                                      getTextStyles: (context, value) =>
                                          const TextStyle(
                                        color: Color(0xff7589a2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      margin: 20,
                                      getTitles: (double value) {
                                        final index =
                                            (value + _scrollPosition).toInt();
                                        if (index >= 0 &&
                                            index < _filteredProjects.length) {
                                          return _filteredProjects[index]
                                              ['nama_pelanggan'];
                                        } else {
                                          return '';
                                        }
                                      },
                                    ),
                                    leftTitles: SideTitles(
                                      showTitles: true,
                                      getTextStyles: (context, value) =>
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
                                    getDrawingHorizontalLine: (value) {
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
                                      spots: _filteredProjects
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
                                        Colors.lightBlueAccent.withOpacity(0.8),
                                      ],
                                      barWidth: 2,
                                      isStrokeCapRound: true,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: _filteredProjects
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
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                    LineChartBarData(
                                      spots: _filteredProjects
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
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                  clipData: FlClipData.all(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ket:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 10,
                                        color: Colors.lightBlueAccent
                                            .withOpacity(0.8),
                                      ),
                                      SizedBox(width: 5),
                                      Text('Nilai Pekerjaan RKAP'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 10,
                                        color: Colors.red.withOpacity(0.8),
                                      ),
                                      SizedBox(width: 5),
                                      Text('Nilai Pekerjaan Aktual'),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 10,
                                        color: Colors.green.withOpacity(0.8),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                          'Nilai Pekerjaan Kontrak Tahun Berjalan'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search by Projects Name',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: FittedBox(
                          child: DataTable(
                            headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Color.fromARGB(255, 252, 252, 252)),
                            columns: [
                              DataColumn(label: Text('No')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Customer ID')),
                              DataColumn(label: Text('Nama Pelanggan')),
                              DataColumn(label: Text('Product ID')),
                              DataColumn(label: Text('Jenis Layanan')),
                              DataColumn(label: Text('Nama Pekerjaan')),
                              DataColumn(label: Text('Nilai Pekerjaan Rekap')),
                              DataColumn(label: Text('Nilai Pekerjaan Aktual')),
                              DataColumn(
                                  label: Text(
                                      'Nilai Pekerjaan Kontrak Tahun Berjalan')),
                              DataColumn(label: Text('Plan Start Date')),
                              DataColumn(label: Text('Plan End Date')),
                              DataColumn(label: Text('Actual Start Date')),
                              DataColumn(label: Text('Actual End Date')),
                              DataColumn(label: Text('Account Marketing')),
                              DataColumn(label: Text('Direktur Utama')),
                              DataColumn(label: Text('Direktur Operasional')),
                              DataColumn(label: Text('Direktur Keamanan')),
                              DataColumn(label: Text('KSKMR')),
                              DataColumn(label: Text('KSHAM')),
                              DataColumn(label: Text('MSDMU')),
                              DataColumn(label: Text('MKAKT')),
                              DataColumn(label: Text('MBILP')),
                              DataColumn(label: Text('MPPTI')),
                              DataColumn(label: Text('MOPTI')),
                              DataColumn(label: Text('MBSAR')),
                              DataColumn(label: Text('MSADB')),
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Updated At')),
                            ],
                            rows: _filteredProjects.map((project) {
                              return DataRow(
                                color: MaterialStateColor.resolveWith(
                                    (states) =>
                                        Color.fromARGB(255, 244, 223, 188)),
                                cells: [
                                  DataCell(Text('${project['id']}')),
                                  DataCell(Text('${project['status']}')),
                                  DataCell(Text('${project['customer_id']}')),
                                  DataCell(
                                      Text('${project['nama_pelanggan']}')),
                                  DataCell(Text('${project['product_id']}')),
                                  DataCell(Text('${project['jenis_layanan']}')),
                                  DataCell(
                                      Text('${project['nama_pekerjaan']}')),
                                  DataCell(Text(
                                      '${project['nilai_perkerjaan_rkap']}')),
                                  DataCell(Text(
                                      '${project['nilai_pekerjaan_aktual']}')),
                                  DataCell(Text(
                                      '${project['nilai_pekerjaan_kontrak_tahun_berjalan']}')),
                                  DataCell(
                                      Text('${project['plan_start_date']}')),
                                  DataCell(Text('${project['plan_end_date']}')),
                                  DataCell(
                                      Text('${project['actual_start_date']}')),
                                  DataCell(
                                      Text('${project['actual_end_date']}')),
                                  DataCell(
                                      Text('${project['account_marketing']}')),
                                  DataCell(Text('${project['dirut']}')),
                                  DataCell(Text('${project['dirop']}')),
                                  DataCell(Text('${project['dirke']}')),
                                  DataCell(Text('${project['kskmr']}')),
                                  DataCell(Text('${project['ksham']}')),
                                  DataCell(Text('${project['msdmu']}')),
                                  DataCell(Text('${project['mkakt']}')),
                                  DataCell(Text('${project['mbilp']}')),
                                  DataCell(Text('${project['mppti']}')),
                                  DataCell(Text('${project['mopti']}')),
                                  DataCell(Text('${project['mbsar']}')),
                                  DataCell(Text('${project['msadb']}')),
                                  DataCell(Text('${project['created_at']}')),
                                  DataCell(Text('${project['updated_at']}')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
