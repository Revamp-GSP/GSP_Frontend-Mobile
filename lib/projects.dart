import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import 'detail_projects.dart';

class ProjectsPage extends StatefulWidget {
  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late MySqlConnection _connection;
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _filteredProjects = [];
  TextEditingController _searchController = TextEditingController();

  List<String> statuses = [
    'Postpone',
    'Follow Up',
    'Implementasi',
    'Payment',
    'Finished'
  ];

  @override
  void initState() {
    super.initState();
    _connectToDB();
  }

  Future<void> _connectToDB() async {
    final settings = ConnectionSettings(
      host: 'loyal.jagoanhosting.com',
      port: 3306,
      user: 'dkbmyid_admin',
      password: 'dbbackend!',
      db: 'dkbmyid_lara622',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      await _fetchProjectsFromDB();
      setState(() {});
    } catch (e) {
      print('Error connecting to database: $e');
    }
  }

  Future<void> _fetchProjectsFromDB() async {
    var results = await _connection.query('SELECT * FROM projects');

    _projects.clear();
    results.forEach((row) {
      _projects.add(Map<String, dynamic>.from(row.fields));
    });
  }

  @override
  void dispose() {
    _connection.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
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
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  height: 300,
                  width: MediaQuery.of(context).size.width * 1.5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      height: 300,
                      width: MediaQuery.of(context).size.width * 1.5,
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
                                getTextStyles: (context, value) => TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                margin:
                                    40, // Ubah nilai margin sesuai kebutuhan Anda
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Postpone';
                                    case 1:
                                      return 'Follow Up';
                                    case 2:
                                      return 'Implementasi';
                                    case 3:
                                      return 'Payment';
                                    case 4:
                                      return 'Finished';
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
                                              project['status'] == statuses[i])
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
                ),
                const SizedBox(height: 10),
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
                            setState(() {
                              _filteredProjects = _projects
                                  .where((project) => project['nama_pekerjaan']
                                      .toLowerCase()
                                      .contains(value.toLowerCase()))
                                  .toList();
                            });
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
                            rows: _searchController.text.isNotEmpty
                                ? _filteredProjects.map((project) {
                                    return DataRow(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => Color.fromARGB(
                                              255, 244, 223, 188)),
                                      cells: [
                                        DataCell(Text('${project['id']}')),
                                        DataCell(Text('${project['status']}')),
                                        DataCell(
                                            Text('${project['customer_id']}')),
                                        DataCell(Text(
                                            '${project['nama_pelanggan']}')),
                                        DataCell(
                                            Text('${project['product_id']}')),
                                        DataCell(Text(
                                            '${project['jenis_layanan']}')),
                                        DataCell(
                                          GestureDetector(
                                            child: Text(
                                              '${project['nama_pekerjaan']}',
                                              style: TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProjectsPage(
                                                    projectId: project['id'],
                                                    namaPekerjaan:
                                                        '${project['nama_pekerjaan']}',
                                                    statusPekerjaan:
                                                        '${project['status']}',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(Text(
                                            '${project['nilai_perkerjaan_rkap']}')),
                                        DataCell(Text(
                                            '${project['nilai_pekerjaan_aktual']}')),
                                        DataCell(Text(
                                            '${project['nilai_pekerjaan_kontrak_tahun_berjalan']}')),
                                        DataCell(Text(
                                            '${project['plan_start_date']}')),
                                        DataCell(Text(
                                            '${project['plan_end_date']}')),
                                        DataCell(Text(
                                            '${project['actual_start_date']}')),
                                        DataCell(Text(
                                            '${project['actual_end_date']}')),
                                        DataCell(Text(
                                            '${project['account_marketing']}')),
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
                                        DataCell(
                                            Text('${project['created_at']}')),
                                        DataCell(
                                            Text('${project['updated_at']}')),
                                      ],
                                    );
                                  }).toList()
                                : _projects.map((project) {
                                    return DataRow(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => Color.fromARGB(
                                              255, 244, 223, 188)),
                                      cells: [
                                        DataCell(Text('${project['id']}')),
                                        DataCell(Text('${project['status']}')),
                                        DataCell(
                                            Text('${project['customer_id']}')),
                                        DataCell(Text(
                                            '${project['nama_pelanggan']}')),
                                        DataCell(
                                            Text('${project['product_id']}')),
                                        DataCell(Text(
                                            '${project['jenis_layanan']}')),
                                        DataCell(
                                          GestureDetector(
                                            child: Text(
                                              '${project['nama_pekerjaan']}',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 24, 97, 158),
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailProjectsPage(
                                                    projectId: project['id'],
                                                    namaPekerjaan:
                                                        '${project['nama_pekerjaan']}',
                                                    statusPekerjaan:
                                                        '${project['status']}',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        DataCell(Text(
                                            '${project['nilai_perkerjaan_rkap']}')),
                                        DataCell(Text(
                                            '${project['nilai_pekerjaan_aktual']}')),
                                        DataCell(Text(
                                            '${project['nilai_pekerjaan_kontrak_tahun_berjalan']}')),
                                        DataCell(Text(
                                            '${project['plan_start_date']}')),
                                        DataCell(Text(
                                            '${project['plan_end_date']}')),
                                        DataCell(Text(
                                            '${project['actual_start_date']}')),
                                        DataCell(Text(
                                            '${project['actual_end_date']}')),
                                        DataCell(Text(
                                            '${project['account_marketing']}')),
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
                                        DataCell(
                                            Text('${project['created_at']}')),
                                        DataCell(
                                            Text('${project['updated_at']}')),
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
